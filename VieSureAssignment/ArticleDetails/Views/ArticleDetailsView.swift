import DesignSystem
import SwiftUI
import Utils

struct ArticleDetailsView: View {
  // MARK: Lifecycle

  init(viewModel: ArticleDetailsViewModel) {
    self.viewModel = viewModel
  }

  // MARK: Internal

  let viewModel: ArticleDetailsViewModel

  var body: some View {
    VStack(alignment: .leading, spacing: 0) {
      ImageView(
        withURL: viewModel.imageUrl,
        contentMode: .fill
      )
      .padding(.bottom, .micro)
      .frame(height: 200, alignment: .center)
      .clipped()
      .background(Color.secondaryBackground)

      VStack(alignment: .leading, spacing: 0) {
        Text(viewModel.title)
          .textStyle(.primaryText, size: .titleMedium, weight: .bold)
          .padding(.bottom, .micro)
        HStack {
          Spacer()
          Text(viewModel.date)
            .textStyle(.tertiaryText, size: .headline)
            .padding(.bottom, .medium)
        }
        Text(viewModel.description)
          .textStyle(.secondary, size: .bodyDefault)
          .padding(.bottom, .medium)
        HStack {
          Text("Author:")
            .textStyle(.secondaryText, size: .headline, weight: .bold)
          Text(viewModel.author)
            .textStyle(.secondaryText, size: .headline)
          Spacer()
        }
        Spacer()
      }
      .padding(.horizontal, .gutter)
    }
  }
}
