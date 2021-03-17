import Foundation

public protocol HTTPBody {
  var isEmpty: Bool { get }
  var additionalHeaders: [String: String] { get }
  func encode() throws -> Data
}

public extension HTTPBody {
  func encode() throws -> Data { Data() }
}

public struct EmptyBody: HTTPBody {
  // MARK: Lifecycle

  public init() {}

  // MARK: Public

  public let isEmpty = true

  public var additionalHeaders: [String: String] { [:] }
}

public struct JSONBody: HTTPBody {
  // MARK: Lifecycle

  public init<T: Encodable>(
    _ value: T,
    encoder: JSONEncoder = JSONEncoder()
  ) {
    encodeClosure = { try encoder.encode(value) }
  }

  // MARK: Public

  public let isEmpty: Bool = false
  public var additionalHeaders = [
    "Content-Type": "application/json; charset=utf-8",
  ]

  public func encode() throws -> Data { try encodeClosure() }

  // MARK: Private

  private let encodeClosure: () throws -> Data
}
