import CommonCrypto
import Foundation

public enum AES256CrypterError: Error {
  case keyGeneration(status: Int)
  case malformattedSalt
  case wrongLengthOfSalt
  case wrongLengthOfPassword
  case cryptoFailed(status: CCCryptorStatus)
  case badKeyLength
  case badInputVectorLength
  case malformattedEncryptedData
}
