import Nimble
import Quick
@testable import Utils

class DataCrypterSpec: QuickSpec {
  let sut: Encryptable = DataCrypter()

  override func spec() {
    describe("DataCrypter") {
      context("Empty data") {
        let digest = Data()
        var decrypted: Data?
        expect {
          let encrypted = try digest.encrypt(with: self.sut)
          decrypted = try encrypted.decrypt(with: self.sut)
        }.notTo(throwError())

        expect(decrypted).to(equal(digest))
      }

      context("String") {
        let digest = "Test string".data(using: .utf8)!
        var decrypted: Data?
        expect {
          let encrypted = try digest.encrypt(with: self.sut)
          decrypted = try encrypted.decrypt(with: self.sut)
        }.notTo(throwError())

        expect(decrypted).to(equal(digest))
      }

      context("Image") {
        let image = UIImage(systemName: "square.and.arrow.up")!
        let digest = image.pngData()!
        var decrypted: Data?
        expect {
          let encrypted = try digest.encrypt(with: self.sut)
          decrypted = try encrypted.decrypt(with: self.sut)
        }.notTo(throwError())

        expect(decrypted).to(equal(digest))
      }
    }
  }
}
