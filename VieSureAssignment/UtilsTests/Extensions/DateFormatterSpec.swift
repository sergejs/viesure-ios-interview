import Nimble
import Quick
@testable import Utils

class DateFormatterSpec: QuickSpec {
  let sut = ArticleDateFormatter.shared

  override func spec() {
    describe("DateFormatter") {
      context("Article") {
        it("Correct") {
          let date = self.sut.date(from: "2/22/2019")
          expect(date).notTo(beNil())
          let components = Calendar.current.dateComponents([.year, .month, .day], from: date!)

          expect(components.day).to(equal(22))
          expect(components.month).to(equal(2))
          expect(components.year).to(equal(2019))
        }
      }

      it("Will fail") {
        let date = self.sut.date(from: "2/22/2019 22:22")
        expect(date).to(beNil())
      }
    }
  }
}
