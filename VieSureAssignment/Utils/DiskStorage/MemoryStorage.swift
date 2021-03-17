import Foundation

public final class MemoryStorage: Storable {
  // MARK: Lifecycle

  public init() {}

  // MARK: Public

  public func store(
    _ data: Data,
    to url: URL
  ) throws {
    storage[url] = data
  }

  public func load(
    from url: URL
  ) throws -> Data? {
    if let data = storage[url] {
      return data
    }
    return nil
  }

  // MARK: Private

  private var storage: [URL: Data?] = [:]
}
