import Nimble
import Quick
@testable import Utils

class CacheSpec: QuickSpec {
  var sut: Cache<String, Data>?

  override func spec() {
    describe("Cache") {
      context("Success") {
        it("Read/Write") {
          self.sut = Cache<String, Data>()
          let sut = self.sut!
          let data = "Data".data(using: .utf8)!
          var storedData: Data?

          sut.insert(data, forKey: "key")
          storedData = sut.value(forKey: "key")

          expect(data).to(equal(storedData))
        }

        it("Read/Write and remove") {
          self.sut = Cache<String, Data>()
          let sut = self.sut!
          let data = "Data".data(using: .utf8)!
          var storedData: Data?

          sut.insert(data, forKey: "key")
          storedData = sut.value(forKey: "key")
          expect(data).to(equal(storedData))

          sut.removeValue(forKey: "key")
          storedData = sut.value(forKey: "key")
          expect(storedData).to(beNil())
        }
      }

      context("Entry life time") {
        it("All fine") {
          self.sut = Cache<String, Data>(
            entryLifetime: 60 * 60 * 24 * 31
          )
          let sut = self.sut!
          let data = "Data".data(using: .utf8)!
          var storedData: Data?
          sut.insert(data, forKey: "key")
          storedData = sut.value(forKey: "key")

          expect(storedData).to(equal(data))
        }

        it("Timed out") {
          var firstDate = true
          let dateProvider: Cache.DateProvider = {
            if firstDate {
              firstDate = false
              return Date()
            }
            return Date() + 60 * 60 * 24 * 31 + 1
          }

          self.sut = Cache<String, Data>(
            dateProvider: dateProvider,
            entryLifetime: 60 * 60 * 24 * 31
          )
          let sut = self.sut!
          let data = "Data".data(using: .utf8)!
          var storedData: Data?
          sut.insert(data, forKey: "key")
          storedData = sut.value(forKey: "key")

          expect(storedData).to(beNil())
        }
      }

      context("Save to storage") {
        it("Success save/load") {
          let storage = MemoryStorage()
          self.sut = Cache<String, Data>(
            entryLifetime: 60 * 60 * 24 * 31
          )
          let sut = self.sut!
          let data = "Data".data(using: .utf8)!
          var storedData: Data?
          sut.insert(data, forKey: "key")
          storedData = sut.value(forKey: "key")

          expect(storedData).to(equal(data))

          expect {
            try sut.saveToDisk(
              to: URL(string: "MEM")!,
              using: storage
            )
          }.notTo(throwError())

          var loadedCache: Cache<String, Data>?
          expect {
            loadedCache = try Cache<String, Data>
              .readFrom(
                storage,
                with: URL(string: "MEM")!
              )
          }.notTo(throwError())
          storedData = loadedCache?.value(forKey: "key")
          expect(storedData).to(equal(data))
        }

        it("Success save/load, with one invalidated key") {
          enum Step {
            case save, secondSave, read, restore
          }
          var step: Step = .save
          let dateProvider: Cache.DateProvider = {
            switch step {
              case .save:
                return Date()
              case .secondSave:
                return Date() + 10
              case .read:
                return Date()
              case .restore:
                return Date() + 60 + 1
            }
          }

          let storage = MemoryStorage()
          let sut = Cache<String, Data>(
            dateProvider: dateProvider,
            entryLifetime: 60
          )

          let data1 = "Data1".data(using: .utf8)!
          let data2 = "Data2".data(using: .utf8)!
          var storedData1: Data?
          var storedData2: Data?

          sut.insert(data1, forKey: "key")

          step = .secondSave
          sut.insert(data2, forKey: "key2")

          step = .read
          storedData1 = sut.value(forKey: "key")
          storedData2 = sut.value(forKey: "key2")

          expect(storedData1).to(equal(data1))
          expect(storedData2).to(equal(data2))

          step = .restore

          expect {
            try sut.saveToDisk(
              to: URL(string: "MEM")!,
              using: storage
            )
          }.notTo(throwError())

          var loadedCache: Cache<String, Data>?
          expect {
            loadedCache = try Cache<String, Data>
              .readFrom(
                storage,
                with: URL(string: "MEM")!
              )
          }.notTo(throwError())
          storedData1 = loadedCache?.value(forKey: "key")
          storedData2 = loadedCache?.value(forKey: "key2")

          expect(storedData1).to(beNil())
          expect(storedData2).to(equal(data2))
        }
      }
    }
  }
}
