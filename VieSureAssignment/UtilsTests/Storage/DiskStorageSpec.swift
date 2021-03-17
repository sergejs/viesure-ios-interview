import Nimble
import Quick
@testable import Utils

class DiskStorageSpec: QuickSpec {
  let sut = DiskStorage(crypter: DataCrypter())

  override func spec() {
    describe("DiskStorage") {
      context("Success") {
        it("Store and read data") {
          let directory = NSTemporaryDirectory()
          let filename = UUID().uuidString
          let url = URL(fileURLWithPath: directory).appendingPathComponent(filename)

          let data = "String".data(using: .utf8)!
          var storedData: Data?
          expect {
            try self.sut.store(
              data,
              to: url
            )
            storedData = try self.sut.load(from: url)
          }.notTo(throwError())
          expect(storedData).to(equal(data))
        }
      }
    }

    context("Key not found") {
      it("Should throw exception") {
        var storedData: Data?

        let directory = NSTemporaryDirectory()
        let filename = UUID().uuidString
        let url = URL(fileURLWithPath: directory).appendingPathComponent(filename)

        expect {
          storedData = try self.sut.load(from: url)
        }.to(throwError())

        expect(storedData).to(beNil())
      }
    }
  }
}
