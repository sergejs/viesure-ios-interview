import Nimble
import Quick
@testable import Utils

class ServiceContainerSpec: QuickSpec {
  var sut: ServiceContainable = ServiceContainer.shared

  override func spec() {
    describe("ServiceContainer") {
      beforeEach {
        (self.sut as? ServiceContainer)?.components.removeAll()
      }

      context("Success resolve") {
        it("Empty data - Should not throw") {
          let memoryStorage = MemoryStorage()
          let data = "String".data(using: .utf8)!
          try? memoryStorage.store(data, to: URL(string: "key")!)

          self.sut.register(type: Storable.self, component: memoryStorage)

          let storable = self.sut.resolve(type: Storable.self)
          expect(storable).notTo(beNil())
          let storedData = try? storable?.load(from: URL(string: "key")!)
          expect(storedData).to(equal(data))
        }

        it("Fail to resolve") {
          let storable = self.sut.resolve(type: Storable.self)
          expect(storable).to(beNil())
          let storedData = try? storable?.load(from: URL(string: "key")!)
          expect(storedData).to(beNil())
        }
      }
    }
  }
}
