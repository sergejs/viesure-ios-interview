@testable import ArticleList
import Combine
import Nimble
import Quick
import SnapshotTesting
import Utils

class ArticleListCoordinatorSpec: QuickSpec {
  var disposeBag = DisposeBag()
  let mockHttp = MockHTTPClient()
  let cacheUrl = URL(string: "cacheUrl")!

  override func spec() {
    describe("ArticleListCoordinator") {
      context("On start ") {
        it("On fist monitor start return loading list ") {
          let data = MockedData.articles.data

          let storage = MemoryStorage()

          expect {
            let decoder = ArticleDecoder.shared
            let articles = try decoder.decode(Articles.self, from: data)
            try storage.encode(articles, to: self.cacheUrl)
          }.notTo(throwError())

          let directory = NSTemporaryDirectory()
          let filename = UUID().uuidString
          let url = URL(fileURLWithPath: directory).appendingPathComponent(filename)

          let sut = ArticleListCoordinatorFactory.makeCoordinator(
            httpClient: self.mockHttp,
            storage: storage,
            cacheUrl: url
          )
          let view = sut.start()

          assertSnapshot(matching: view.toVC(), as: .image)
        }

        it("On fist monitor start should publish data from storage") {
          let data = MockedData.articles.data

          self.mockHttp.then { request, result in
            let response = HTTPResponse(
              request: request,
              response: HTTPURLResponse(),
              body: data
            )
            result(.success(response))
          }

          let storage = MemoryStorage()

          expect {
            let decoder = ArticleDecoder.shared
            let articles = try decoder.decode(Articles.self, from: data)
            try storage.encode(articles, to: self.cacheUrl)
          }.notTo(throwError())

          let directory = NSTemporaryDirectory()
          let filename = UUID().uuidString
          let url = URL(fileURLWithPath: directory).appendingPathComponent(filename)

          let sut = ArticleListCoordinator(
            httpClient: self.mockHttp,
            storage: storage,
            cacheUrl: url
          )
          _ = sut.start()
          sut.viewModel.onAppear()
          expect(sut.viewModel.articles.count).toEventually(equal(60), timeout: .seconds(3))
        }
      }
    }
  }
}
