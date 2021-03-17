import Combine
import Foundation
import Utils

public enum ArticleRepositoryError: Error {
  case wrongUrl
  case unableToParse(error: Error?)
  case failedToFetch(error: Error?)
  case problemCacheStorage
  case unableToLoadData

  // MARK: Internal

  var description: String {
    switch self {
      case .wrongUrl: return "Wrong URL, please try again."
      case .unableToParse: return "Wrong Response, please try again."
      case .failedToFetch,
           .unableToLoadData: return "Unable to fetch, please try again."
      case .problemCacheStorage: return "Problems with local cache, please try again."
    }
  }
}

public typealias ArticleFetchPublisher = AnyPublisher<[Article], Error>

public protocol ArticleProvidable {
  func fetch() -> ArticleFetchPublisher
  func provide<S>(
    withDelay delay: S.SchedulerTimeType.Stride,
    on scheduler: S,
    withRetry count: Int
  ) -> ArticleFetchPublisher where S: Scheduler
}

public enum ArticleProviderFactory {
  public static func makeProvider(
    client: HTTPClientRequestDispatcher = HTTPClient(session: URLSession.shared)
  ) -> ArticleProvidable {
    ArticleRepository(client: client)
  }
}

public final class ArticleRepository: ArticleProvidable {
  // MARK: Lifecycle

  public init(
    client: HTTPClientRequestDispatcher
  ) {
    self.client = client
  }

  // MARK: Private

  private static let url = "https://run.mocky.io/v3/de42e6d9-2d03-40e2-a426-8953c7c94fb8"

  private var disposeBag = DisposeBag()
  private let client: HTTPClientRequestDispatcher
}

public extension ArticleRepository {
  func provide<S>(
    withDelay delay: S.SchedulerTimeType.Stride,
    on scheduler: S,
    withRetry count: Int
  ) -> ArticleFetchPublisher where S: Scheduler {
    var retriesLeft = count
    return fetch()
      .catch { error -> ArticleFetchPublisher in
        if error.isRecoverableError, retriesLeft > 0 {
          retriesLeft -= 1
          return Fail(error: error)
            .delay(for: delay, scheduler: scheduler)
            .eraseToAnyPublisher()
        }
        return Fail(error: error)
          .eraseToAnyPublisher()
      }
      .retry(times: count) { $0.isRecoverableError }
      .eraseToAnyPublisher()
  }

  func fetch() -> ArticleFetchPublisher {
    Deferred {
      Future<[Article], Error> { [weak self] promise in
        guard
          let self = self,
          let components = URLComponents(string: Self.url)
        else {
          promise(.failure(ArticleRepositoryError.wrongUrl))
          return
        }
        let request = HTTPRequest(urlComponents: components)
        self.client.execute(request: request) { [weak self] result in
          switch result {
            case let .success(response):
              self?.process(
                response.body,
                completion: promise
              )
            case let .failure(error):
              promise(.failure(ArticleRepositoryError.failedToFetch(error: error)))
          }
        }
      }
    }
    .eraseToAnyPublisher()
  }

  private func process(
    _ data: Data?,
    completion: @escaping (Result<Articles, Error>) -> Void
  ) {
    guard
      let data = data
    else {
      completion(.failure(ArticleRepositoryError.unableToParse(error: nil)))
      return
    }

    do {
      let articles = try ArticleDecoder
        .shared
        .decode(LossyArray<Article>.self, from: data)
        .wrappedValue
        .sorted(by: { (lhs, rhs) -> Bool in
          lhs.releaseDate < rhs.releaseDate
        })

      completion(.success(articles))
    } catch {
      completion(.failure(ArticleRepositoryError.unableToParse(error: error)))
    }
  }
}

private extension Error {
  var isRecoverableError: Bool {
    guard
      case let .failedToFetch(error) = (self as? ArticleRepositoryError),
      let httpError = error as? HTTPError
    else {
      return false
    }

    if httpError.response?.status.code == 500 {
      return true
    }

    if case .invalidResponse = httpError.code,
       let underlyingError = httpError.underlyingError as NSError?,
       underlyingError.domain == "NSURLErrorDomain",
       underlyingError.code == NSURLErrorNotConnectedToInternet {
      return true
    }

    return false
  }
}
