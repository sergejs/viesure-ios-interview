import Foundation

public protocol URLSessionProtocol {
  func dataTask(
    with request: URLRequest,
    completion: @escaping (Data?, URLResponse?, Error?) -> Void
  ) -> URLSessionDataTaskProtocol
}

extension URLSession: URLSessionProtocol {
  public func dataTask(
    with request: URLRequest,
    completion: @escaping (Data?, URLResponse?, Error?) -> Void
  ) -> URLSessionDataTaskProtocol {
    dataTask(
      with: request,
      completionHandler: completion
    )
  }
}

public protocol URLSessionDataTaskProtocol {
  func resume()
  func cancel()
}

extension URLSessionDataTask: URLSessionDataTaskProtocol {}
