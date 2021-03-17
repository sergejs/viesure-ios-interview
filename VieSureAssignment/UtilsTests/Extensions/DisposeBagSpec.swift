import Combine
import Nimble
import Quick
@testable import Utils

class DisposeBagSpec: QuickSpec {
  var sut = DisposeBag()

  override func spec() {
    describe("DisposeBag") {
      context("Should dispose") {
        it("Empty data - Should not throw") {
          var isCacnelled = false
          Timer.publish(every: 1, on: .main, in: .default)
            .autoconnect()
            .handleEvents(receiveCancel: {
              isCacnelled = true
            })
            .sink { _ in }
            .store(in: &self.sut)

          expect(self.sut.count).to(equal(1))
          self.sut.dispose()
          expect(self.sut.count).to(equal(1))
          expect(isCacnelled).toEventually(equal(true), timeout: .seconds(3))
        }
      }
    }
  }
}
