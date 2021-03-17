@testable import ArticleDetails
import Nimble
import Quick
import SnapshotTesting
import SwiftUI
import UIKit
import Utils
class ArticleDetailsViewSpec: QuickSpec {
  let mockHttp = MockHTTPClient()
  let cache = ImageCache()

  override func spec() {
    describe("ArticleDetailsView") {
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
            article = try decoder.decode(Articles.self, from: data).first
          }.notTo(throwError())

          let viewModel = ArticleDetailsViewModel(article: article!)
          let sut = ArticleDetailsView(viewModel: viewModel)

          assertSnapshot(
            matching: sut.toVC(),
            as: .image,
            testName: "short"
          )
        }
      }

      it("should record long content") {
        let data = MockedData.articlesShort.data
        var article: Article?
        expect {
          let decoder = ArticleDecoder.shared
          article = try decoder.decode(Articles.self, from: data).last
        }.notTo(throwError())

        let viewModel = ArticleDetailsViewModel(article: article!)
        let sut = ArticleDetailsView(viewModel: viewModel)

        assertSnapshot(
          matching: sut.toVC(),
          as: .image,
          testName: "short"
        )
      }
    }
  }
}
