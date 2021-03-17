import CommonCrypto
import Nimble
import Quick
@testable import Utils

class AES256CrypterSpec: QuickSpec {
  var sut: Encryptable!
  let ivArrayCorrect: [UInt8] = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
  let ivArrayShort: [UInt8] = [0, 0]
  let saltArray: [UInt8] = [0, 0, 0, 0, 0, 0, 0, 0]

  override func spec() {
    describe("AES256Crypter") {
      context("Success") {
        it("Should throw no error on crypt") {
          let factory = AES256KeyFactory(saltProvider: { Data(self.saltArray) })
          let password = "password".data(using: .utf8)!
          var key: Data?
          expect {
            key = try factory.makeKey(with: password)
          }.notTo(throwError())
          expect(key?.count).to(equal(kCCKeySizeAES256))

          let digest = "String".data(using: .utf8)!

          expect {
            self.sut = try AES256Crypter(
              key: key!
            )
            let encryptedData = try digest.encrypt(with: self.sut!)
            let decryptedData = try encryptedData.decrypt(with: self.sut!)
            expect(decryptedData).to(equal(digest))
          }.notTo(throwError())
        }
      }

      context("Throws") {
        it("Empty key") {
          expect {
            try AES256Crypter(key: Data())
          }.to(throwError(AES256CrypterError.badKeyLength))
        }

        it("Wrong key") {
          expect {
            try AES256Crypter(key: "Data".data(using: .utf8)!)
          }.to(throwError(AES256CrypterError.badKeyLength))
        }

        it("Wrong iv") {
          let factory = AES256KeyFactory(saltProvider: { Data(self.saltArray) })
          let password = "password".data(using: .utf8)!
          var key: Data?
          expect {
            key = try factory.makeKey(with: password)
          }.notTo(throwError())
          expect(key?.count).to(equal(kCCKeySizeAES256))

          expect {
            let sut = try AES256Crypter(
              key: key!,
              ivProvider: { Data(self.ivArrayShort) }
            )
            _ = try Data().encrypt(with: sut)
          }.to(throwError(AES256CrypterError.badInputVectorLength))
        }

        it("Nil iv") {
          let factory = AES256KeyFactory(saltProvider: { Data(self.saltArray) })
          let password = "password".data(using: .utf8)!
          var key: Data?
          expect {
            key = try factory.makeKey(with: password)
          }.notTo(throwError())
          expect(key?.count).to(equal(kCCKeySizeAES256))

          expect {
            let sut = try AES256Crypter(
              key: key!,
              ivProvider: { nil }
            )
            _ = try Data().encrypt(with: sut)
          }.to(throwError(AES256CrypterError.badInputVectorLength))
        }

        it("Wrong encoded data") {
          let factory = AES256KeyFactory(saltProvider: { Data(self.saltArray) })
          let password = "password".data(using: .utf8)!
          var key: Data?
          expect {
            key = try factory.makeKey(with: password)
          }.notTo(throwError())
          expect(key?.count).to(equal(kCCKeySizeAES256))

          expect {
            self.sut = try AES256Crypter(
              key: key!,
              ivProvider: { Data(self.ivArrayCorrect) }
            )
            _ = try Data().decrypt(with: self.sut)
          }.to(throwError(AES256CrypterError.malformattedEncryptedData))
        }
      }
    }
  }
}
