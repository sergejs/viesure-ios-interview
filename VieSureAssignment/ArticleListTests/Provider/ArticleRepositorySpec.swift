@testable import ArticleList
import Nimble
import Quick
import Utils

class ArticleRepositorySpec: QuickSpec {
  var disposeBag = DisposeBag()
  let mockHttp = MockHTTPClient()
  var sut: ArticleProvidable?

  override func spec() {
    describe("HTTPClient") {
      context("Success") {
        it("should parse all elements") {
          let data = MockedData.articles.data
          self.sut = ArticleProviderFactory.makeProvider(client: self.mockHttp)

          self.mockHttp.then { request, result in
            let response = HTTPResponse(
              request: request,
              response: HTTPURLResponse(),
              body: data
            )
            result(.success(response))
          }

          var articles: Articles?
          self.sut?
            .fetch()
            .sink(
              receiveCompletion: { _ in },
              receiveValue: { articles = $0 }
            )
            .store(in: &self.disposeBag)

          expect(articles?.count).toEventually(equal(60), timeout: .seconds(3))
        }
      }

      it("should parse all correct elements") {
        let data = MockedData.articlesBroken.data
        self.sut = ArticleProviderFactory.makeProvider(client: self.mockHttp)

        self.mockHttp.then { request, result in
          let response = HTTPResponse(
            request: request,
            response: HTTPURLResponse(),
            body: data
          )
          result(.success(response))
        }

        var articles: Articles?
        self.sut?
          .fetch()
          .sink(
            receiveCompletion: { _ in },
            receiveValue: { articles = $0 }
          )
          .store(in: &self.disposeBag)

        expect(articles?.count).toEventually(equal(2), timeout: .seconds(3))
      }

      it("should parse all correct elements from short list") {
        let data = MockedData.articlesShort.data
        self.sut = ArticleProviderFactory.makeProvider(client: self.mockHttp)

        self.mockHttp.then { request, result in
          let response = HTTPResponse(
            request: request,
            response: HTTPURLResponse(),
            body: data
          )
          result(.success(response))
        }

        var articles: Articles?
        self.sut?
          .fetch()
          .sink(
            receiveCompletion: { _ in },
            receiveValue: { articles = $0 }
          )
          .store(in: &self.disposeBag)

        expect(articles?.count).toEventually(equal(3), timeout: .seconds(3))
      }
    }

    context("Failure") {
      it("Should fail on 404") {
        self.sut = ArticleProviderFactory.makeProvider(client: self.mockHttp)

        self.mockHttp.then { request, result in
          let response = HTTPResponse(
            request: request,
            response: HTTPURLResponse(),
            body: Data()
          )
          let error = HTTPError(
            code: .serverError,
            request: request,
            response: response,
            underlyingError: nil
          )
          result(.failure(error))
        }

        var articles: Articles?
        var responseError: ArticleRepositoryError?

        self.sut?
          .fetch()
          .sink(
            receiveCompletion: {
              if case let .failure(error) = $0 {
                responseError = error as? ArticleRepositoryError
              }
            },
            receiveValue: { articles = $0 }
          )
          .store(in: &self.disposeBag)

        expect(responseError).toEventuallyNot(beNil(), timeout: .seconds(3))
        expect(articles?.count).toEventually(beNil(), timeout: .seconds(3))
      }

      it("Should fail on parsing") {
        let data = Data.randomGenerateBytes(count: 100)
        self.sut = ArticleProviderFactory.makeProvider(client: self.mockHttp)

        self.mockHttp.then { request, result in
          let response = HTTPResponse(
            request: request,
            response: HTTPURLResponse(),
            body: data
          )
          result(.success(response))
        }

        var articles: Articles?
        var responseError: ArticleRepositoryError?

        self.sut?
          .fetch()
          .sink(
            receiveCompletion: {
              if case let .failure(error) = $0 {
                responseError = error as? ArticleRepositoryError
              }
            },
            receiveValue: { articles = $0 }
          )
          .store(in: &self.disposeBag)

        expect(responseError).toEventuallyNot(beNil(), timeout: .seconds(3))
        expect(articles?.count).toEventually(beNil(), timeout: .seconds(3))
      }
    }

    it("Should fail on nil parsing") {
      self.sut = ArticleProviderFactory.makeProvider(client: self.mockHttp)

      self.mockHttp.then { request, result in
        let response = HTTPResponse(
          request: request,
          response: HTTPURLResponse(),
          body: nil
        )
        result(.success(response))
      }

      var articles: Articles?
      var responseError: ArticleRepositoryError?

      self.sut?
        .fetch()
        .sink(
          receiveCompletion: {
            if case let .failure(error) = $0 {
              responseError = error as? ArticleRepositoryError
            }
          },
          receiveValue: { articles = $0 }
        )
        .store(in: &self.disposeBag)

      expect(responseError).toEventuallyNot(beNil(), timeout: .seconds(3))
      expect(articles?.count).toEventually(beNil(), timeout: .seconds(3))
    }
  }
}
