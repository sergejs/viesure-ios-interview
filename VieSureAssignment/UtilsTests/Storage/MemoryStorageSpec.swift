import Nimble
import Quick
@testable import Utils

class MemoryStorageSpec: QuickSpec {
  let sut: Storable = MemoryStorage()

  override func spec() {
    describe("MemoryStorage") {
      context("Data") {
        it("Empty data - Should not throw") {
          let data = Data()
          var storedData: Data?

          expect {
            try self.sut.store(
              data,
              to: URL(string: "key")!
            )

            storedData = try self.sut.load(from: URL(string: "key")!)
          }.notTo(throwError())

          expect(data).to(equal(storedData))
        }

        it("Correct data - Should not throw") {
          let data = "Data()".data(using: .utf8)!
          var storedData: Data?

          expect {
            try self.sut.store(
              data,
              to: URL(string: "key")!
            )

            storedData = try self.sut.load(from: URL(string: "key")!)
          }.notTo(throwError())

          expect(data).to(equal(storedData))
        }
      }
    }

    context("Codable") {
      it("Correct data - Should not throw") {
        let data = "Data()"
        var storedData: String?

        expect {
          try self.sut.encode(data, to: URL(string: "key")!)
          storedData = try self.sut.decode(from: URL(string: "key")!)
        }.notTo(throwError())

        expect(data).to(equal(storedData))
      }
    }

    context("Key not found") {
      it("should return nil") {
        var storedData: Data?

        expect {
          storedData = try self.sut.load(from: URL(string: "key-not-found")!)
        }.notTo(throwError())

        expect(storedData).to(beNil())
      }
    }
  }
}
