import ArticleList
import Combine
import Nimble
import Quick
import Utils

class MockArticleProvider {
  // MARK: Internal

  typealias MockResult = Result<Articles, Error>

  func then(_ result: MockResult) {
    nextHandlers.append(result)
  }

  // MARK: Private

  private var nextHandlers = [MockResult]()
}

extension MockArticleProvider: ArticleProvidable {
  func fetch() -> ArticleFetchPublisher {
    let next: MockResult
    if nextHandlers.isEmpty == false {
      next = nextHandlers.removeFirst()
    } else {
      next = .failure(ArticleRepositoryError.unableToLoadData)
    }

    switch next {
      case let .success(articles):
        return Just(articles)
          .setFailureType(to: Error.self)
          .eraseToAnyPublisher()
      case let .failure(error):
        return Fail(outputType: Articles.self, failure: error)
          .eraseToAnyPublisher()
    }
  }

  func provide<S>(
    withDelay delay: S.SchedulerTimeType.Stride,
    on scheduler: S,
    withRetry count: Int
  ) -> ArticleFetchPublisher where S: Scheduler {
    fetch()
  }
}
