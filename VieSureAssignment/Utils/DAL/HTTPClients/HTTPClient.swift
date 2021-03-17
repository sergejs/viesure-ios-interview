import Foundation

typealias DataTaskResult = (data: Data?, response: HTTPResponse?, error: Error?)

public protocol HTTPClientRequestDispatcher {
  func execute(
    request: HTTPRequest,
    completion: @escaping (HTTPResult) -> Void
  )
}

public final class HTTPClient {
  // MARK: Lifecycle

  public init(session: URLSessionProtocol) {
    self.session = session
  }

  // MARK: Internal

  let session: URLSessionProtocol
}

extension HTTPClient: HTTPClientRequestDispatcher {
  public func execute(
    request: HTTPRequest,
    completion: @escaping (HTTPResult) -> Void
  ) {
    guard
      let url = request.url
    else {
      let error = HTTPError(
        code: .invalidRequest,
        request: request,
        response: nil,
        underlyingError: nil
      )
      completion(.failure(error))
      return
    }

    var urlRequest = URLRequest(url: url)
    urlRequest.httpMethod = request.method.rawValue

    for (header, value) in request.headers {
      urlRequest.addValue(value, forHTTPHeaderField: header)
    }

    if request.body.isEmpty == false {
      for (header, value) in request.body.additionalHeaders {
        urlRequest.addValue(value, forHTTPHeaderField: header)
      }

      do {
        urlRequest.httpBody = try request.body.encode()
      } catch {
        let error = HTTPError(
          code: .malformedRequest,
          request: request,
          response: nil,
          underlyingError: nil
        )
        completion(.failure(error))
        return
      }
    }

    let dataTask = session.dataTask(with: urlRequest) { data, response, error in
      var httpResponse: HTTPResponse?
      if let response = response as? HTTPURLResponse {
        httpResponse = HTTPResponse(
          request: request,
          response: response,
          body: data
        )
      }
      let dataTaskResult = (data: data, response: httpResponse, error: error)

      let result = self.processDataTaskResult(
        dataTaskResult: dataTaskResult,
        request: request
      )
      completion(result)
    }

    dataTask.resume()
  }
}

extension HTTPClient {
  func processDataTaskResult(
    dataTaskResult: DataTaskResult,
    request: HTTPRequest
  ) -> HTTPResult {
    guard
      let httpResponse = dataTaskResult.response
    else {
      if let error = dataTaskResult.error {
        let httpError = HTTPError(
          code: .invalidResponse,
          request: request,
          response: dataTaskResult.response,
          underlyingError: error
        )
        return .failure(httpError)
      } else {
        let httpError = HTTPError(
          code: .malformedResponse,
          request: request,
          response: dataTaskResult.response,
          underlyingError: nil
        )
        return .failure(httpError)
      }
    }

    let result: HTTPResult
    let statusCode = httpResponse.status.code

    switch statusCode {
      case 500 ... 599:
        let httpError = HTTPError(
          code: .serverError,
          request: request,
          response: dataTaskResult.response,
          underlyingError: nil
        )
        result = .failure(httpError)
      case 400 ... 499:
        let httpError = HTTPError(
          code: .clientError,
          request: request,
          response: dataTaskResult.response,
          underlyingError: nil
        )
        result = .failure(httpError)
      default:
        result = .success(httpResponse)
    }
    return result
  }
}
