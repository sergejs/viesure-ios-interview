import Utils

struct ArticleDetailsViewModel {
  // MARK: Lifecycle

  init(article: Article) {
    imageUrl = article.imageUrl
    title = article.title
    description = article.description
    date = Self.dateFormatter(article.releaseDate)
    author = article.author
  }

  // MARK: Internal

  let imageUrl: String
  let title: String
  let description: String
  let date: String
  let author: String

  static func dateFormatter(_ date: Date) -> String {
    PresentingArticleDateFormatter.shared.string(from: date)
  }
}
