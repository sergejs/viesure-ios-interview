@testable import ArticleList
import Nimble
import Quick
import SnapshotTesting
import SwiftUI
import UIKit
import Utils

class ArticlesListViewSpec: QuickSpec {
  let mockHttp = MockHTTPClient()
  let cache = ImageCache()

  override func spec() {
    describe("ArticlesListView") {
      context("Snapshot") {
        it("should record short content") {
          ServiceContainer.shared.register(type: HTTPClientRequestDispatcher.self, component: self.mockHttp)
          ServiceContainer.shared.register(type: ImageCache.self, component: self.cache)

          let data = MockedData.articlesShort.data
          var articles: Articles?
          expect {
            let decoder = ArticleDecoder.shared
            articles = try decoder.decode(Articles.self, from: data)
          }.notTo(throwError())
          let mockPublisher = MockArticlePublisher()

          let viewModel = MockedArticleListViewModel(
            publisher: mockPublisher,
            articles: articles!
          )

          let sut = ArticlesListView(viewModel: viewModel)

          assertSnapshot(
            matching: sut.toVC(),
            as: .image,
            testName: "short"
          )
        }

        it("should record long content") {
          ServiceContainer.shared.register(type: HTTPClientRequestDispatcher.self, component: self.mockHttp)
          ServiceContainer.shared.register(type: ImageCache.self, component: self.cache)

          let data = MockedData.articles.data
          var articles: Articles?
          expect {
            let decoder = ArticleDecoder.shared
            articles = try decoder.decode(Articles.self, from: data)
          }.notTo(throwError())
          let mockPublisher = MockArticlePublisher()

          let viewModel = MockedArticleListViewModel(
            publisher: mockPublisher,
            articles: articles!
          )

          let sut = ArticlesListView(viewModel: viewModel)

          assertSnapshot(
            matching: sut.toVC(),
            as: .image,
            testName: "long"
          )
        }
      }
    }
  }
}

class MockedArticleListViewModel: ArticleListViewModel {
  init(
    publisher: ArticlePublishable,
    articles: Articles
  ) {
    super.init(publisher: publisher)
    self.articles = articles
  }
}
