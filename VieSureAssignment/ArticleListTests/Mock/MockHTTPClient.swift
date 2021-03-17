import Foundation
import Utils

class MockHTTPClient: HTTPClientRequestDispatcher {
  // MARK: Public

  public func execute(
    request: HTTPRequest,
    completion: @escaping HTTPHandler
  ) {
    if nextHandlers.isEmpty == false {
      let next = nextHandlers.removeFirst()
      next(request, completion)
    } else {
      let error = HTTPError(code: .invalidRequest, request: request)
      completion(.failure(error))
    }
  }

  // MARK: Internal

  typealias HTTPHandler = (HTTPResult) -> Void
  typealias MockHandler = (HTTPRequest, HTTPHandler) -> Void

  func then(_ handler: @escaping MockHandler) {
    nextHandlers.append(handler)
  }

  // MARK: Private

  private var nextHandlers = [MockHandler]()
}
