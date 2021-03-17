@testable import ArticleList
import Nimble
import Quick
import Utils

class ArticleRepositoryRetrySpec: QuickSpec {
  var disposeBag = DisposeBag()
  let mockHttp = MockHTTPClient()
  var sut: ArticleProvidable?

  override func spec() {
    describe("HTTPClient") {
      context("Failure") {
        it("Should fail on four 404") {
          self.sut = ArticleProviderFactory.makeProvider(client: self.mockHttp)

          self.mockHttp.then { request, result in
            let url = request.url
            let urlResponse = HTTPURLResponse(url: url!, statusCode: 500, httpVersion: nil, headerFields: nil)!
            let response = HTTPResponse(request: request, response: urlResponse, body: Data())
            let error = HTTPError(code: .serverError, request: request, response: response, underlyingError: nil)

            result(.failure(error))
          }

          self.mockHttp.then { request, result in
            let url = request.url
            let urlResponse = HTTPURLResponse(url: url!, statusCode: 500, httpVersion: nil, headerFields: nil)!
            let response = HTTPResponse(request: request, response: urlResponse, body: Data())
            let error = HTTPError(code: .serverError, request: request, response: response, underlyingError: nil)

            result(.failure(error))
          }

          self.mockHttp.then { request, result in
            let url = request.url
            let urlResponse = HTTPURLResponse(url: url!, statusCode: 404, httpVersion: nil, headerFields: nil)!
            let response = HTTPResponse(request: request, response: urlResponse, body: Data())
            let error = HTTPError(code: .clientError, request: request, response: response, underlyingError: nil)

            result(.failure(error))
          }

          self.mockHttp.then { request, result in
            let url = request.url
            let urlResponse = HTTPURLResponse(url: url!, statusCode: 500, httpVersion: nil, headerFields: nil)!
            let response = HTTPResponse(request: request, response: urlResponse, body: Data())
            let error = HTTPError(code: .serverError, request: request, response: response, underlyingError: nil)

            result(.failure(error))
          }
          var articles: Articles?
          var failedToFetch = false

          self.sut?
            .provide(withDelay: .seconds(2), on: DispatchQueue.global(), withRetry: 3)
            .sink(
              receiveCompletion: {
                if
                  case let .failure(error) = $0,
                  case ArticleRepositoryError.failedToFetch = error {
                  failedToFetch = true
                }
              },
              receiveValue: { articles = $0 }
            )
            .store(in: &self.disposeBag)

          expect(failedToFetch).toEventually(equal(true), timeout: .seconds(15))
          expect(articles?.count).toEventually(beNil(), timeout: .seconds(15))
        }

        it("Should success after one retry") {
          self.sut = ArticleProviderFactory.makeProvider(client: self.mockHttp)

          self.mockHttp.then { request, result in
            let url = request.url
            let urlResponse = HTTPURLResponse(url: url!, statusCode: 500, httpVersion: nil, headerFields: nil)!
            let response = HTTPResponse(request: request, response: urlResponse, body: Data())
            let error = HTTPError(code: .serverError, request: request, response: response, underlyingError: nil)

            result(.failure(error))
          }

          let data = MockedData.articles.data
          self.mockHttp.then { request, result in
            let response = HTTPResponse(
              request: request,
              response: HTTPURLResponse(),
              body: data
            )
            result(.success(response))
          }

          var articles: Articles?
          var failedToFetch: Bool?

          self.sut?
            .provide(withDelay: .seconds(2), on: DispatchQueue.global(), withRetry: 3)
            .sink(
              receiveCompletion: { result in
                switch result {
                  case .finished:
                    failedToFetch = false
                  case .failure:
                    failedToFetch = true
                }
              },
              receiveValue: { articles = $0 }
            )
            .store(in: &self.disposeBag)

          expect(failedToFetch).toEventually(equal(false), timeout: .seconds(15))
          expect(articles?.count).toEventually(equal(60), timeout: .seconds(15))
        }
      }
    }
  }
}
