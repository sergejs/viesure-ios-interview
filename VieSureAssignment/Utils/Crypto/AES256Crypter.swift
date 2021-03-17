import CommonCrypto
import Foundation

public struct AES256Crypter: Encryptable {
  // MARK: Lifecycle

  public init(
    key: Data,
    ivProvider: @escaping () -> Data? = { Data.randomGenerateBytes(count: kCCBlockSizeAES128) }
  ) throws {
    guard
      key.count == kCCKeySizeAES256
    else {
      throw AES256CrypterError.badKeyLength
    }

    self.key = key
    self.ivProvider = ivProvider
  }

  // MARK: Public

  public func encrypt(_ digest: Data) throws -> Data {
    guard
      let iv = ivProvider()
    else {
      throw AES256CrypterError.badInputVectorLength
    }
    let encrypted = try crypt(
      input: digest,
      iv: iv,
      operation: CCOperation(kCCEncrypt)
    )
    return iv + encrypted
  }

  public func decrypt(_ encrypted: Data) throws -> Data {
    guard
      encrypted.count >= kCCBlockSizeAES128
    else {
      throw AES256CrypterError.malformattedEncryptedData
    }

    return try crypt(
      input: encrypted.suffix(from: kCCBlockSizeAES128),
      iv: encrypted.prefix(kCCBlockSizeAES128),
      operation: CCOperation(kCCDecrypt)
    )
  }

  // MARK: Private

  private let ivProvider: () -> Data?
  private var key: Data

  private func crypt(
    input: Data,
    iv: Data,
    operation: CCOperation
  ) throws -> Data {
    guard
      iv.count == kCCBlockSizeAES128
    else {
      throw AES256CrypterError.badInputVectorLength
    }

    var outLength = Int(0)
    var outBytes = [UInt8](repeating: 0, count: input.count + kCCBlockSizeAES128)
    var status = CCCryptorStatus(kCCSuccess)

    input.withUnsafeBytes { rawBufferPointer in
      let encryptedBytes = rawBufferPointer.baseAddress!

      iv.withUnsafeBytes { rawBufferPointer in
        let ivBytes = rawBufferPointer.baseAddress!

        key.withUnsafeBytes { rawBufferPointer in
          let keyBytes = rawBufferPointer.baseAddress!

          status = CCCrypt(
            operation,
            CCAlgorithm(kCCAlgorithmAES),
            CCOptions(kCCOptionPKCS7Padding),
            keyBytes,
            key.count,
            ivBytes,
            encryptedBytes,
            input.count,
            &outBytes,
            outBytes.count,
            &outLength
          )
        }
      }
    }

    guard status == kCCSuccess else {
      throw AES256CrypterError.cryptoFailed(status: status)
    }

    return Data(bytes: &outBytes, count: outLength)
  }
}
