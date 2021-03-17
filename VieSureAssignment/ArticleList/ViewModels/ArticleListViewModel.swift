import Combine
import DesignSystem
import Foundation
import SwiftUI
import Utils

protocol ArticleListViewModelDelegate: AnyObject {
  func userDidSelected(_ article: Article)
}

class ArticleListViewModel: ObservableObject {
  // MARK: Lifecycle

  init(publisher: ArticlePublishable) {
    self.publisher = publisher
  }

  // MARK: Public

  public weak var delegate: ArticleListViewModelDelegate?

  // MARK: Internal

  @Published
  internal var articles: Articles = []
  @Published
  internal var isError = false
  internal var errorTitle = "Error!"
  internal var errorDescription = ""
  @Published
  internal var detailsViewIsPresented = false
  internal var detailsView = AnyView(EmptyView())

  // MARK: Private

  private let publisher: ArticlePublishable
  private var monitor: AnyCancellable?
}

extension ArticleListViewModel {
  func onAppear() {
    startMonitor()
  }

  func onDisappear() {
    stopMonitor()
  }

  func userDidPressedRetry() {
    startMonitor()
  }

  func userDidPressedOk() {}

  func userDidSelected(_ article: Article) {
    delegate?.userDidSelected(article)
  }
}

private extension ArticleListViewModel {
  func startMonitor() {
    monitor?.cancel()

    // TODO: Add Storting
    monitor = publisher.startMonitor()
      .prepend(publisher.fetchLocalIfPossible())
      .subscribe(on: DispatchQueue.global())
      .receive(on: DispatchQueue.main)
      .sink { [weak self] completion in
        if case let .failure(error) = completion {
          self?.showError(error)
        }
      } receiveValue: { [weak self] articles in
        self?.articles = articles
      }
  }

  func stopMonitor() {
    publisher.stopMonitor()
  }

  func showError(_ error: ArticleRepositoryError) {
    isError = true
    errorDescription = error.description
  }
}
