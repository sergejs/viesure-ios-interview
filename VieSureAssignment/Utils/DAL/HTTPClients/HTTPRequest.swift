import Foundation

public struct HTTPRequest {
  // MARK: Lifecycle

  public init(
    method: HTTPMethod = .get,
    urlComponents: URLComponents,
    headers: [String: String] = [:],
    body: HTTPBody = EmptyBody()
  ) {
    self.method = method
    self.headers = headers
    self.body = body
    self.urlComponents = urlComponents
  }

  public init(
    method: HTTPMethod = .get,
    host: String? = "",
    path: String? = "",
    headers: [String: String] = [:],
    body: HTTPBody = EmptyBody()
  ) {
    self.method = method
    self.headers = headers
    self.body = body

    urlComponents?.scheme = "https"
    urlComponents?.host = host
    if let path = path {
      urlComponents?.path = path
    }
  }

  // MARK: Public

  public var method: HTTPMethod
  public var headers: [String: String]
  public var body: HTTPBody

  // MARK: Internal

  internal var urlComponents: URLComponents? = URLComponents()
}

public extension HTTPRequest {
  var url: URL? { urlComponents?.url }
}
