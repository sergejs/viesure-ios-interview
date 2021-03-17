@testable import ArticleList
import Combine
import Nimble
import Quick
import Utils

class ArticlePublihserSpec: QuickSpec {
  var disposeBag = DisposeBag()
  let cacheUrl = URL(string: "cacheUrl")!

  override func spec() {
    describe("ArticlePublihser") {
      context("Easy paths") {
        it("On fist monitor start should publish data from storage") {
          let storage = MemoryStorage()
          let data = MockedData.articles.data
          expect {
            let decoder = ArticleDecoder.shared
            let articles = try decoder.decode(Articles.self, from: data)
            try storage.encode(articles, to: self.cacheUrl)
          }.notTo(throwError())

          let sut = ArticlePublisherFactory.makeArticlePublisher(
            repository: MockArticleProvider(),
            storage: storage,
            cacheUrl: self.cacheUrl
          )
          var loadedArticles: [Articles?] = []

          sut
            .fetchLocalIfPossible()
            .sink(
              receiveCompletion: { _ in },
              receiveValue: { loadedArticles.append($0) }
            )
            .store(in: &self.disposeBag)

          expect(loadedArticles.count).toEventually(equal(1), timeout: .seconds(3))
          expect(loadedArticles.last??.count).toEventually(equal(60), timeout: .seconds(3))
        }

        it("On fetch should publish error - no mocked data") {
          let sut = ArticlePublisherFactory.makeArticlePublisher(
            repository: MockArticleProvider(),
            storage: MemoryStorage(),
            cacheUrl: self.cacheUrl
          )

          var articles: Articles?
          var receivedError: ArticleRepositoryError?

          sut.startMonitor()
            .sink(
              receiveCompletion: {
                if case let .failure(error) = $0 {
                  receivedError = error
                }
              },
              receiveValue: { articles = $0 }
            )
            .store(in: &self.disposeBag)

          expect(articles?.count).toEventually(beNil(), timeout: .seconds(3))
          expect(receivedError).toEventually(equal(.unableToLoadData), timeout: .seconds(3))
        }

        it("On fetch should publish data from mock") {
          let storage = MemoryStorage()
          let data = MockedData.articles.data
          let mockArticleProvider = MockArticleProvider()
          expect {
            let decoder = ArticleDecoder.shared

            let articles = try decoder.decode(Articles.self, from: data)
            mockArticleProvider.then(.success(articles))
          }.notTo(throwError())

          let sut = ArticlePublisherFactory.makeArticlePublisher(
            repository: mockArticleProvider,
            storage: storage,
            cacheUrl: self.cacheUrl
          )

          var loadedArticles: [Articles?] = []
          sut
            .startMonitor()
            .sink(
              receiveCompletion: { _ in },
              receiveValue: { loadedArticles.append($0) }
            )
            .store(in: &self.disposeBag)

          expect(loadedArticles.count).toEventually(equal(1), timeout: .seconds(15))
          expect(loadedArticles.last??.count).toEventually(equal(60), timeout: .seconds(15))

          var storedArticles: Articles?
          expect {
            storedArticles = try storage.decode(from: self.cacheUrl)
          }.notTo(throwError())

          expect(storedArticles?.count).to(equal(60))
        }

        it("On start monitor should publish data from mock") {
          let storage = MemoryStorage()
          let data = MockedData.articles.data
          let mockArticleProvider = MockArticleProvider()
          expect {
            let decoder = ArticleDecoder.shared

            let articles = try decoder.decode(Articles.self, from: data)
            mockArticleProvider.then(.success(articles))
          }.notTo(throwError())

          let sut = ArticlePublisherFactory.makeArticlePublisher(
            repository: mockArticleProvider,
            storage: storage,
            cacheUrl: self.cacheUrl,
            timerPublisher: Just(Date()).eraseToAnyPublisher()
          )

          var loadedArticles: [Articles?] = []
          sut
            .startMonitor()
            .sink(
              receiveCompletion: { _ in },
              receiveValue: { loadedArticles.append($0) }
            )
            .store(in: &self.disposeBag)

          expect(loadedArticles.count).toEventually(equal(1), timeout: .seconds(3))
          expect(loadedArticles.last??.count).toEventually(equal(60), timeout: .seconds(3))

          var storedArticles: Articles?
          expect {
            storedArticles = try storage.decode(from: self.cacheUrl)
          }.notTo(throwError())

          expect(storedArticles?.count).to(equal(60))
        }
      }
    }
  }
}

extension ArticleRepositoryError: Equatable {
  public static func == (lhs: ArticleRepositoryError, rhs: ArticleRepositoryError) -> Bool {
    switch (lhs, rhs) {
      case (.unableToLoadData, .unableToLoadData): return true
      case (.wrongUrl, .wrongUrl): return true
      case (.unableToParse, .unableToParse): return true
      case (.failedToFetch, .failedToFetch): return true
      case (.problemCacheStorage, .problemCacheStorage): return true
      default: return false
    }
  }
}
