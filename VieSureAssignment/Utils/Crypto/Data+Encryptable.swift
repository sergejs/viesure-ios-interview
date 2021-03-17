import Foundation

public protocol Encryptable {
  func encrypt(_ data: Data) throws -> Data
  func decrypt(_ data: Data) throws -> Data
}

public extension Data {
  func encrypt(with encrypter: Encryptable) throws -> Data {
    try encrypter.encrypt(self)
  }

  func decrypt(with encrypter: Encryptable) throws -> Data {
    try encrypter.decrypt(self)
  }
}
