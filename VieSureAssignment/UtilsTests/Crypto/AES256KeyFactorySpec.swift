import CommonCrypto
import Nimble
import Quick
@testable import Utils

class AES256KeyFactorySpec: QuickSpec {
  var sut: AES256KeyCreatable!

  override func spec() {
    describe("AES256KeyFactory") {
      context("Success") {
        it("Should return key") {
          self.sut = AES256KeyFactory(saltProvider: { Data.randomGenerateBytes(count: 8) })
          let password = "password".data(using: .utf8)!
          var key: Data?
          expect {
            key = try self.sut.makeKey(with: password)
          }.notTo(throwError())
          expect(key).notTo(beNil())
          expect(key?.count).to(equal(kCCKeySizeAES256))
        }
      }

      context("Throws") {
        it("Should throw nil salt") {
          self.sut = AES256KeyFactory(saltProvider: { nil })
          let password = "password".data(using: .utf8)!
          expect {
            try self.sut.makeKey(with: password)
          }.to(throwError(AES256CrypterError.malformattedSalt))
        }

        it("Should throw short salt") {
          self.sut = AES256KeyFactory(saltProvider: { Data.randomGenerateBytes(count: 6) })
          let password = "password".data(using: .utf8)!
          expect {
            try self.sut.makeKey(with: password)
          }.to(throwError(AES256CrypterError.wrongLengthOfSalt))
        }

        it("Should throw short salt") {
          self.sut = AES256KeyFactory(saltProvider: { Data.randomGenerateBytes(count: 16) })
          let password = "password".data(using: .utf8)!
          expect {
            try self.sut.makeKey(with: password)
          }.to(throwError(AES256CrypterError.wrongLengthOfSalt))
        }

        it("Should throw empty password") {
          self.sut = AES256KeyFactory(saltProvider: { Data.randomGenerateBytes(count: 8) })
          let password = Data()
          expect {
            try self.sut.makeKey(with: password)
          }.to(throwError(AES256CrypterError.wrongLengthOfPassword))
        }
      }
    }
  }
}
