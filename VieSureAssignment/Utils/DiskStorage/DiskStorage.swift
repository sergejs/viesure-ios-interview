import Foundation

public final class DiskStorage: Storable {
  // MARK: Lifecycle

  public init(
    fileManager: FileManager = .default,
    crypter: Encryptable
  ) {
    self.fileManager = fileManager
    self.crypter = crypter
  }

  // MARK: Public

  public func store(
    _ data: Data,
    to url: URL
  ) throws {
    try data
      .encrypt(with: crypter)
      .write(to: url)
  }

  public func load(
    from url: URL
  ) throws -> Data? {
    try Data(contentsOf: url)
      .decrypt(with: crypter)
  }

  // MARK: Internal

  let crypter: Encryptable
  let fileManager: FileManager
}
