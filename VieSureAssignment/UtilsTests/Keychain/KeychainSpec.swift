import Nimble
import Quick
@testable import Utils

class KeychainSpec: QuickSpec {
  let sut = Keychain(service: "com.sergejs.TestIns")

  override func spec() {
    describe("Keychain") {
      beforeEach {
        expect {
          try self.sut.deleteAll()
        }.notTo(throwError())
      }

      afterSuite {
        expect {
          try self.sut.deleteAll()
        }.notTo(throwError())
      }

      context("CRUD") {
        it("Read with nothing stored") {
          var loadedData: Data?
          expect {
            loadedData = self.sut.get("key")
          }.notTo(throwError())

          expect(loadedData).to(beNil())
        }

        it("Create / Read") {
          let data = "String".data(using: .utf8)!
          var loadedData: Data?
          expect {
            try self.sut.set("key", data: data)
            loadedData = self.sut.get("key")
          }.notTo(throwError())

          expect(loadedData).to(equal(data))
        }

        it("Create / Delete / Read") {
          let data = "String".data(using: .utf8)!
          var loadedData: Data?
          expect {
            try self.sut.set("key", data: data)
            loadedData = self.sut.get("key")
          }.notTo(throwError())

          expect(loadedData).to(equal(data))

          expect {
            try self.sut.delete("key")
          }.notTo(throwError())

          loadedData = self.sut.get("key")

          expect(loadedData).to(beNil())
        }

        it("Create / Delete / read") {
          let data = "String".data(using: .utf8)!
          let dataNew = "New String".data(using: .utf8)!
          var loadedData: Data?
          expect {
            try self.sut.set("key", data: data)
            loadedData = self.sut.get("key")
          }.notTo(throwError())

          expect(loadedData).to(equal(data))

          expect {
            try self.sut.set("key", data: dataNew)
          }.notTo(throwError())

          loadedData = self.sut.get("key")

          expect(loadedData).to(equal(dataNew))
        }

        it("Delete all") {
          let data = "String".data(using: .utf8)!
          let dataNew = "New String".data(using: .utf8)!

          var loadedData: Data?
          var loadedData2: Data?

          expect {
            try self.sut.set("key", data: data)
            try self.sut.set("key-two", data: dataNew)
          }.notTo(throwError())
          expect {
            try self.sut.deleteAll()
          }.notTo(throwError())

          loadedData = self.sut.get("key")
          loadedData2 = self.sut.get("key")

          expect(loadedData).to(beNil())
          expect(loadedData2).to(beNil())
        }
      }
    }
  }
}
