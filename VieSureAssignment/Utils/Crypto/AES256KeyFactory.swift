import CommonCrypto
import Foundation

public protocol AES256KeyCreatable {
  func makeKey(with password: Data) throws -> Data
}

public struct AES256KeyFactory: AES256KeyCreatable {
  // MARK: Lifecycle

  public init(
    saltProvider: @escaping () -> Data? = { Data.randomGenerateBytes(count: 8) }
  ) {
    self.saltProvider = saltProvider
  }

  // MARK: Public

  public func makeKey(
    with password: Data
  ) throws -> Data {
    guard
      let salt = saltProvider()
    else {
      throw AES256CrypterError.malformattedSalt
    }

    guard
      salt.count == 8
    else {
      throw AES256CrypterError.wrongLengthOfSalt
    }

    guard
      !password.isEmpty
    else {
      throw AES256CrypterError.wrongLengthOfPassword
    }

    let length = kCCKeySizeAES256
    var status = Int32(0)
    var derivedBytes = [UInt8](repeating: 0, count: length)

    password.withUnsafeBytes { rawBufferPointer in
      let passwordRawBytes = rawBufferPointer.baseAddress!
      let passwordBytes = passwordRawBytes.assumingMemoryBound(to: Int8.self)

      salt.withUnsafeBytes { rawBufferPointer in
        let saltRawBytes = rawBufferPointer.baseAddress!
        let saltBytes = saltRawBytes.assumingMemoryBound(to: UInt8.self)

        status = CCKeyDerivationPBKDF(
          CCPBKDFAlgorithm(kCCPBKDF2),
          passwordBytes,
          password.count,
          saltBytes,
          salt.count,
          CCPseudoRandomAlgorithm(kCCPRFHmacAlgSHA1),
          10000,
          &derivedBytes,
          length
        )
      }
    }

    guard
      status == 0
    else {
      throw AES256CrypterError.keyGeneration(status: Int(status))
    }

    return Data(
      bytes: &derivedBytes,
      count: length
    )
  }

  // MARK: Private

  private let saltProvider: () -> Data?
}
