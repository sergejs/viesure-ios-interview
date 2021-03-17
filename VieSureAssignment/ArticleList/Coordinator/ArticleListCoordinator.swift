import ArticleDetails
import SwiftUI
import Utils

public typealias CacheURL = URL

public enum ArticleListCoordinatorFactory {
  public static func makeCoordinator(
    httpClient: HTTPClientRequestDispatcher = ServiceContainer.shared.resolve(type: HTTPClientRequestDispatcher.self)!,
    storage: Storable = ServiceContainer.shared.resolve(type: Storable.self)!,
    cacheUrl: CacheURL = ServiceContainer.shared.resolve(type: CacheURL.self)!
  ) -> Coordinatable {
    ArticleListCoordinator(
      httpClient: httpClient,
      storage: storage,
      cacheUrl: cacheUrl
    )
  }
}

internal final class ArticleListCoordinator {
  // MARK: Lifecycle

  init(
    httpClient: HTTPClientRequestDispatcher,
    storage: Storable,
    cacheUrl: CacheURL
  ) {
    let provider = ArticleProviderFactory.makeProvider(client: httpClient)
    let publisher = ArticlePublisherFactory.makeArticlePublisher(
      repository: provider,
      storage: storage,
      cacheUrl: cacheUrl
    )

    viewModel = ArticleListViewModel(publisher: publisher)
    viewModel.delegate = self
  }

  // MARK: Internal

  internal let viewModel: ArticleListViewModel
}

extension ArticleListCoordinator: Coordinatable {
  public func start() -> AnyView {
    AnyView(ArticlesListView(viewModel: viewModel))
  }
}

extension ArticleListCoordinator: ArticleListViewModelDelegate {
  func userDidSelected(_ article: Article) {
    let coordinator = ArticleDetailsCoordinator(article: article)
    viewModel.detailsView = coordinator.start()
    viewModel.detailsViewIsPresented = true
  }
}
