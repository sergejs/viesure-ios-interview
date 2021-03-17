@testable import ArticleDetails
import Nimble
import Quick
import SnapshotTesting
import SwiftUI
import UIKit
import Utils

class ArticleDetailsCoordinatorSpec: QuickSpec {
  let mockHttp = MockHTTPClient()
  let cache = ImageCache()

  override func spec() {
    describe("ArticleDetailsCoordinator") {
      beforeSuite {
        ServiceContainer.shared.register(type: HTTPClientRequestDispatcher.self, component: self.mockHttp)
        ServiceContainer.shared.register(type: ImageCache.self, component: self.cache)
      }

      context("Snapshot") {
        it("should record short content") {
          let data = MockedData.articlesShort.data
          var article: Article?
          expect {
            let decoder = ArticleDecoder.shared
            article = try decoder.decode(Articles.self, from: data).last
          }.notTo(throwError())

          let sut = ArticleDetailsCoordinator(article: article!)
          let view = sut.start()

          assertSnapshot(
            matching: view.toVC(),
            as: .image,
            testName: "snapshot"
          )
        }
      }
    }
  }
}
