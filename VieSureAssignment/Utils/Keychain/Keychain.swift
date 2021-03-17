import Foundation

public protocol Keychanable {
  func get(_ key: String) -> Data?
  func set(_ key: String, data: Data) throws
  func delete(_ key: String) throws
}

public enum KeychainError: Error {
  case unhandled(status: OSStatus, message: String?)
}

public class Keychain {
  // MARK: Lifecycle

  public init(service: String) {
    self.service = service
  }

  // MARK: Public

  public func set(
    _ key: String,
    data: Data
  ) throws {
    if get(key) != nil {
      try delete(key)
    }

    let query = [
      String(kSecClass): kSecClassGenericPassword as String,
      String(kSecAttrAccount): key,
      String(kSecValueData): data,
      String(kSecAttrService): service,
    ] as [String: Any]

    let status = SecItemAdd(query as CFDictionary, nil)

    if status != errSecSuccess {
      throw error(from: status)
    }
  }

  public func delete(_ key: String) throws {
    let query = [
      String(kSecClass): kSecClassGenericPassword as String,
      String(kSecAttrAccount): key,
      String(kSecAttrService): service,
    ] as [String: Any]

    let status = SecItemDelete(query as CFDictionary)

    if status != errSecSuccess, status != errSecItemNotFound {
      throw error(from: status)
    }
  }

  public func deleteAll() throws {
    let query = [
      String(kSecClass): kSecClassGenericPassword as String,
      String(kSecAttrService): service,
    ] as [String: Any]

    let status = SecItemDelete(query as CFDictionary)
    guard status == errSecSuccess || status == errSecItemNotFound else {
      throw error(from: status)
    }
  }

  public func get(_ key: String) -> Data? {
    let query = [
      String(kSecClass): kSecClassGenericPassword,
      String(kSecAttrAccount): key,
      String(kSecReturnData): kCFBooleanTrue!,
      String(kSecMatchLimit): kSecMatchLimitOne,
      String(kSecAttrService): service,
    ] as [String: Any]

    var dataTypeRef: AnyObject?

    let status: OSStatus = SecItemCopyMatching(query as CFDictionary, &dataTypeRef)

    if status == noErr, let data = dataTypeRef as? Data? {
      return data
    } else {
      return nil
    }
  }

  // MARK: Private

  private let service: String

  private func error(from status: OSStatus) -> KeychainError {
    let message = SecCopyErrorMessageString(status, nil) as String?
    return KeychainError.unhandled(status: status, message: message)
  }
}
