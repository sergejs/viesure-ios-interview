import CommonCrypto
import Foundation

public extension Data {
  static func randomGenerateBytes(count: Int) -> Data? {
    let bytes = UnsafeMutableRawPointer.allocate(byteCount: count, alignment: 1)
    defer {
      bytes.deallocate()
    }
    let status = CCRandomGenerateBytes(bytes, count)
    guard
      status == kCCSuccess
    else {
      return nil
    }
    return Data(
      bytes: bytes,
      count: count
    )
  }
}
