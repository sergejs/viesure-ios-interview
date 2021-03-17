import DesignSystem
import SwiftUI

struct ArticlesListView: View {
  // MARK: Lifecycle

  init(viewModel: ArticleListViewModel) {
    self.viewModel = viewModel
  }

  // MARK: Internal

  @ObservedObject
  var viewModel: ArticleListViewModel

  var body: some View {
    listView
      .padding([.bottom, .trailing, .leading], .gutter)
      .edgesIgnoringSafeArea(.bottom)
      .onAppear(perform: viewModel.onAppear)
      .onDisappear(perform: viewModel.onDisappear)
      .alert(isPresented: $viewModel.isError) {
        errorAlert
      }
      .sheet(isPresented: $viewModel.detailsViewIsPresented) {
        viewModel.detailsView
      }
  }

  // MARK: Private

  @ViewBuilder
  private var listView: some View {
    NoSepratorList {
      if viewModel.articles.isEmpty {
        Text("Loading...")
          .textStyle(.primary, size: .titleLarge)
      } else {
        ForEach(viewModel.articles, id: \.id) { article in
          ArticleListCell(article: article) {
            viewModel.userDidSelected(article)
          }
        }
      }
    }
  }

  private var errorAlert: Alert {
    Alert(
      title: Text(viewModel.errorTitle),
      message: Text(viewModel.errorDescription),
      primaryButton: .cancel(Text("Retry"), action: viewModel.userDidPressedRetry),
      secondaryButton: .default(Text("OK"), action: viewModel.userDidPressedOk)
    )
  }
}
