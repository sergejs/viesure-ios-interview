import Foundation
import SwiftUI
import Utils

public class ArticleDetailsCoordinator {
  // MARK: Lifecycle

  public init(article: Article) {
    viewModel = ArticleDetailsViewModel(article: article)
  }

  // MARK: Internal

  internal let viewModel: ArticleDetailsViewModel
}

extension ArticleDetailsCoordinator: Coordinatable {
  public func start() -> AnyView {
    AnyView(ArticleDetailsView(viewModel: viewModel))
  }
}
