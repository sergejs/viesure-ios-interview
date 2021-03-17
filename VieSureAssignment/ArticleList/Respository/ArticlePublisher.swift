import Combine
import Foundation
import Utils

public typealias TimerPubliser = AnyPublisher<Date, Never>

public protocol ArticlePublishable {
  func startMonitor() -> AnyPublisher<Articles, ArticleRepositoryError>
  func stopMonitor()
  func fetchLocalIfPossible() -> AnyPublisher<Articles, ArticleRepositoryError>
}

public enum ArticlePublisherFactory {
  // MARK: Public

  public static func makeArticlePublisher(
    repository: ArticleProvidable,
    storage: Storable,
    cacheUrl: URL,
    timerPublisher: TimerPubliser = ArticlePublisherFactory.makeTimerPublisher()
  ) -> ArticlePublishable {
    ArticlePublisher(
      repository: repository,
      storage: storage,
      cacheUrl: cacheUrl,
      timerPublisher: timerPublisher
    )
  }

  public static func makeTimerPublisher() -> TimerPubliser {
    Timer.publish(
      every: ArticlePublisherFactory.monitorInterval,
      on: .main,
      in: .default
    )
    .autoconnect()
    .merge(with: Just(Date()))
    .eraseToAnyPublisher()
  }

  // MARK: Private

  private static let monitorInterval: TimeInterval = 10
}

private final class ArticlePublisher: ArticlePublishable {
  // MARK: Lifecycle

  init(
    repository: ArticleProvidable,
    storage: Storable,
    cacheUrl: URL,
    timerPublisher: TimerPubliser
  ) {
    self.cacheUrl = cacheUrl
    self.storage = storage
    self.repository = repository
    self.timerPublisher = timerPublisher
  }

  // MARK: Public

  public func fetchLocalIfPossible() -> AnyPublisher<Articles, ArticleRepositoryError> {
    makeFetchLocalCancellable()
      .setFailureType(to: ArticleRepositoryError.self)
      .eraseToAnyPublisher()
  }

  // MARK: Internal

  func startMonitor() -> AnyPublisher<Articles, ArticleRepositoryError> {
    Publishers.Merge(timerPublisher, Just(Date()))
      .setFailureType(to: ArticleRepositoryError.self)
      .compactMap { [weak self] _ in self }
      .flatMap { $0.tryFetchArticles() }
      .removeDuplicates()
      .eraseToAnyPublisher()
  }

  func stopMonitor() {
    fetchMonitor?.cancel()
  }

  // MARK: Private

  private static let retryCount = 3
  private static let retryDelay: TimeInterval = 2

  private let timerPublisher: TimerPubliser

  private var cacheUrl: URL
  private let repository: ArticleProvidable
  private let storage: Storable

  private var fetchMonitor: AnyCancellable?
  private var disposeBag = DisposeBag()

  private func tryFetchArticles() -> AnyPublisher<Articles, ArticleRepositoryError> {
    Deferred {
      Future<Articles, ArticleRepositoryError> { [weak self] promise in
        guard
          let self = self
        else {
          promise(.failure(.unableToLoadData))
          return
        }

        self.repository
          .provide(
            withDelay: .seconds(Self.retryDelay),
            on: DispatchQueue.main,
            withRetry: Self.retryCount
          )
          .removeDuplicates()
          .sink { result in
            if case let .failure(underlyingError) = result,
               let error = underlyingError as? ArticleRepositoryError {
              promise(.failure(error))
            }
          } receiveValue: { [weak self] articles in
            self?.cache(articles)
            if let cacheUrl = self?.cacheUrl {
              try? self?.storage.encode(articles, to: cacheUrl)
            }

            promise(.success(articles))
          }
          .store(in: &self.disposeBag)
      }
    }
    .eraseToAnyPublisher()
  }

  private func cache(_ articles: Articles) {
    guard
      !articles.isEmpty
    else {
      return
    }

    try? storage.encode(articles, to: cacheUrl)
  }

  private func makeFetchLocalCancellable() -> AnyPublisher<Articles, Never> {
    Deferred {
      Future { [weak self] promise in
        guard
          let self = self
        else {
          promise(.success([]))
          return
        }

        do {
          let articles: Articles? = try self.storage.decode(from: self.cacheUrl)
          promise(.success(articles ?? []))
        } catch {
          promise(.success([]))
        }
      }
    }
    .eraseToAnyPublisher()
  }
}
