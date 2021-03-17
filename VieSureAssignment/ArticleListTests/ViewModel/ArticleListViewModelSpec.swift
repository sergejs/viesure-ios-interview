@testable import ArticleList
import Combine
import Nimble
import Quick
import Utils

class DumbArticleListViewModelDelegate: ArticleListViewModelDelegate {
  var didSelect = false

  func userDidSelected(_ article: Article) {
    didSelect = true
  }
}

class ArticleListViewModelSpec: QuickSpec {
  var disposeBag = DisposeBag()

  override func spec() {
    describe("ArticleListViewModel") {
      context("Details") {
        it("should navigate") {
          let dumbDelegate = DumbArticleListViewModelDelegate()
          let mockPublisher = MockArticlePublisher()
          let sut = ArticleListViewModel(publisher: mockPublisher)
          sut.delegate = dumbDelegate
          sut.onAppear()

          expect(mockPublisher.startCoung).to(equal(1))

          let data = MockedData.articles.data
          var article: Article?
          expect {
            let decoder = ArticleDecoder.shared
            article = try decoder.decode(Articles.self, from: data).first
          }.notTo(throwError())

          sut.userDidSelected(article!)

          expect(dumbDelegate.didSelect).toEventually(equal(true))
        }
      }

      context("Monitor") {
        it("should start on appear") {
          let mockPublisher = MockArticlePublisher()
          let sut = ArticleListViewModel(publisher: mockPublisher)
          sut.onAppear()

          expect(mockPublisher.startCoung).to(equal(1))
        }

        it("should stop on disappear") {
          let mockPublisher = MockArticlePublisher()
          let sut = ArticleListViewModel(publisher: mockPublisher)
          sut.onAppear()
          sut.onDisappear()

          expect(mockPublisher.startCoung).to(equal(1))
          expect(mockPublisher.stopCount).to(equal(1))
        }

        it("should show error on fail") {
          let mockPublisher = MockArticlePublisher(shouldFail: true)
          let sut = ArticleListViewModel(publisher: mockPublisher)
          sut.onAppear()

          expect(sut.isError).toEventually(be(true), timeout: .seconds(3))
          sut.userDidPressedRetry()
          expect(mockPublisher.startCoung).to(equal(2))
          expect(mockPublisher.stopCount).to(equal(0))
        }
      }
    }
  }
}
