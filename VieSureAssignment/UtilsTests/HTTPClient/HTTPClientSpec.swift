import Mocker
import Nimble
import Quick
@testable import Utils

class HTTPClientSpec: QuickSpec {
  enum HTTPClientSpecError: Error {
    case error
  }

  let sut = HTTPClient(session: URLSession.shared)

  override func spec() {
    describe("HTTPClient") {
      beforeSuite {
        Mock(
          url: URL(string: "https://www.google.com/100")!,
          dataType: .json,
          statusCode: 100,
          data: [.get: Data()]
        ).register()
        Mock(
          url: URL(string: "https://www.google.com/404")!,
          dataType: .json,
          statusCode: 404,
          data: [.get: Data()],
          requestError: HTTPClientSpecError.error
        ).register()
        Mock(
          url: URL(string: "https://www.google.com/200")!,
          dataType: .json,
          statusCode: 200,
          data: [.get: Data()]
        ).register()
        Mock(
          url: URL(string: "https://www.google.com/300")!,
          dataType: .json,
          statusCode: 300,
          data: [.get: Data()]
        ).register()
        Mock(
          url: URL(string: "https://www.google.com/400")!,
          dataType: .json,
          statusCode: 400,
          data: [.get: Data()]
        ).register()
        Mock(
          url: URL(string: "https://www.google.com/500")!,
          dataType: .json,
          statusCode: 500,
          data: [.get: Data()]
        ).register()
      }

      context("Basic calls") {
        it("Request GET - 100") {
          let request = HTTPRequest(
            method: .get,
            host: "www.google.com",
            path: "/100"
          )
          var httpResult: HTTPResult?
          self.sut.execute(
            request: request
          ) { result in
            httpResult = result
          }

          expect(httpResult?.response?.status.isInformational)
            .toEventually(equal(true), timeout: .seconds(3))
        }

        it("Request GET - 200") {
          let request = HTTPRequest(
            method: .get,
            host: "www.google.com",
            path: "/200"
          )
          var httpResult: HTTPResult?
          self.sut.execute(
            request: request
          ) { result in
            httpResult = result
          }

          expect(httpResult?.response?.status.isSuccessful)
            .toEventually(equal(true), timeout: .seconds(3))
        }

        it("Request GET - 300") {
          let request = HTTPRequest(
            method: .get,
            host: "www.google.com",
            path: "/300"
          )
          var httpResult: HTTPResult?
          self.sut.execute(
            request: request
          ) { result in
            httpResult = result
          }

          expect(httpResult?.response?.status.isRedirection)
            .toEventually(equal(true), timeout: .seconds(3))
        }

        it("Request GET 4xx") {
          let request = HTTPRequest(
            method: .get,
            host: "www.google.com",
            path: "/400"
          )
          var httpResult: HTTPResult?

          self.sut.execute(
            request: request
          ) { result in
            httpResult = result
          }

          expect(httpResult?.response?.status.isClientError)
            .toEventually(equal(true), timeout: .seconds(3))

          expect(httpResult?.request.body.isEmpty)
            .toEventually(equal(true), timeout: .seconds(3))
        }

        it("Request POST 5xx") {
          let body = JSONBody("body")
          let request = HTTPRequest(
            method: .get,
            urlComponents: URLComponents(string: "https://www.google.com/500")!,
            headers: ["header": "value"],
            body: body
          )
          var httpResult: HTTPResult?

          self.sut.execute(
            request: request
          ) { result in
            httpResult = result
          }

          expect(httpResult?.response?.status.isServerError)
            .toEventually(equal(true), timeout: .seconds(3))

          expect(httpResult?.response?.message)
            .toEventually(equal("internal server error"), timeout: .seconds(3))

          expect(httpResult?.request.body.isEmpty)
            .toEventually(equal(false), timeout: .seconds(3))
        }
      }
    }
    context("Failures") {
      it("Wrong request") {
        let body = JSONBody(EncodeWillFail())
        let request = HTTPRequest(
          method: .post,
          urlComponents: URLComponents(string: "https://www.google.com/500")!,
          headers: ["header": "value"],
          body: body
        )
        var httpError: HTTPError?

        self.sut.execute(
          request: request
        ) {
          if case let .failure(error) = $0 {
            httpError = error
          }
        }

        expect(httpError?.code)
          .toEventually(equal(.malformedRequest), timeout: .seconds(3))
      }

      it("Wrong response") {
        let body = JSONBody("Test")
        let request = HTTPRequest(
          method: .get,
          urlComponents: URLComponents(string: "https://www.google.com/404")!,
          headers: ["header": "value"],
          body: body
        )
        var httpError: HTTPError?

        self.sut.execute(
          request: request
        ) {
          if case let .failure(error) = $0 {
            httpError = error
          }
        }

        expect(httpError?.code)
          .toEventually(equal(.invalidResponse), timeout: .seconds(3))
      }

      it("Wrong request") {
        var request = HTTPRequest(method: .delete, host: nil, path: "")
        request.urlComponents = nil

        var httpError: HTTPError?

        self.sut.execute(
          request: request
        ) {
          if case let .failure(error) = $0 {
            httpError = error
          }
        }

        expect(httpError?.code)
          .toEventually(equal(.invalidRequest), timeout: .seconds(3))
      }
    }
  }
}

struct EncodeWillFail: Encodable {
  enum EncodeWillFailError: Error {
    case error
  }

  func encode(to encoder: Encoder) throws {
    throw EncodeWillFailError.error
  }
}
