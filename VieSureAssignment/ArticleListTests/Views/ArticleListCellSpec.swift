@testable import ArticleList
import Nimble
import Quick
import SnapshotTesting
import SwiftUI
import UIKit
import Utils

class ArticleListCellSpec: QuickSpec {
  let mockHttp = MockHTTPClient()
  let cache = ImageCache()

  override func spec() {
    describe("ArticleListCell") {
      context("Snapshot") {
        it("should record short content") {
          ServiceContainer.shared.register(type: HTTPClientRequestDispatcher.self, component: self.mockHttp)
          ServiceContainer.shared.register(type: ImageCache.self, component: self.cache)

          let data = MockedData.articlesShort.data
          var article: Article?
          expect {
            let decoder = ArticleDecoder.shared
            article = try decoder.decode(Articles.self, from: data).first
          }.notTo(throwError())

          let sut = ArticleListCell(article: article!, action: {})

          assertSnapshot(
            matching: sut.toVC(),
            as: .image,
            named: "short"
          )
        }

        it("should record long content") {
          ServiceContainer.shared.register(type: HTTPClientRequestDispatcher.self, component: self.mockHttp)
          ServiceContainer.shared.register(type: ImageCache.self, component: self.cache)

          let data = MockedData.articlesShort.data
          var article: Article?
          expect {
            let decoder = ArticleDecoder.shared
            article = try decoder.decode(Articles.self, from: data).last
          }.notTo(throwError())

          let sut = ArticleListCell(article: article!, action: {})

          assertSnapshot(
            matching: sut.toVC(),
            as: .image,
            named: "long"
          )
        }
      }
    }
  }
}
