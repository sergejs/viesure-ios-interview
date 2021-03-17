import DesignSystem
import SwiftUI
import Utils

struct ArticleListCell: View {
  // MARK: Lifecycle

  init(
    article: Article,
    action: @escaping () -> Void
  ) {
    self.action = action
    self.article = article
  }

  // MARK: Internal

  var body: some View {
    Button(
      action: action,
      label: { cellView }
    )
    .frame(maxWidth: .infinity)
    .background(Color.secondaryBackground)
  }

  var cellView: some View {
    HStack(alignment: .top) {
      imageView
      VStack(
        alignment: .leading,
        spacing: Space.micro.value
      ) {
        Text(article.title)
          .frame(maxWidth: .infinity, alignment: .leading)
          .multilineTextAlignment(.leading)
          .lineLimit(1)
          .textStyle(.primaryText, size: .titleSmall, weight: .bold)

        Text(article.description)
          .frame(maxWidth: .infinity, alignment: .leading)
          .multilineTextAlignment(.leading)
          .lineLimit(2)
          .textStyle(.secondaryText, size: .bodySmall)
      }
      .padding(.trailing, .xSmall)
    }
    .padding(.all, .xSmall)
  }

  // MARK: Private

  private let article: Article
  private let action: () -> Void

  private var imageView: some View {
    ImageView(
      withURL: article.imageUrl,
      contentMode: .fill
    )
    .background(Color.neutral1)
    .frame(width: 50, height: 50, alignment: .center)
    .clipShape(Circle())
    .overlay(Circle().stroke(Color.neutral2, lineWidth: 1))
    .padding(.all, .micro)
  }
}

struct ArticleListCell_Previews: PreviewProvider {
  static let article = Article(
    id: 1,
    title: "Title",
    description: "Long text",
    author: "Name",
    releaseDate: Date(),
    imageUrl: ""
  )

  static var previews: some View {
    ArticleListCell(article: article, action: {})
  }
}
