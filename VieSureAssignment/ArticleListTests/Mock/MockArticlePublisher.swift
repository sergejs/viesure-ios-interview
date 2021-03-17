import ArticleList
import Combine
import Utils

class MockArticlePublisher: ArticlePublishable {
  // MARK: Lifecycle

  init(shouldFail: Bool = false) {
    self.shouldFail = shouldFail
  }

  // MARK: Internal

  let shouldFail: Bool
  var stopCount = 0
  var startCoung = 0

  func startMonitor() -> AnyPublisher<Articles, ArticleRepositoryError> {
    startCoung += 1
    if shouldFail {
      return Fail(
        outputType: Articles.self,
        failure: ArticleRepositoryError.failedToFetch(error: nil)
      )
      .eraseToAnyPublisher()
    }
    return Just([] as Articles)
      .setFailureType(to: ArticleRepositoryError.self)
      .eraseToAnyPublisher()
  }

  func stopMonitor() {
    stopCount += 1
  }

  func fetchLocalIfPossible() -> AnyPublisher<Articles, ArticleRepositoryError> {
    Just([] as Articles).setFailureType(to: ArticleRepositoryError.self).eraseToAnyPublisher()
  }
}
