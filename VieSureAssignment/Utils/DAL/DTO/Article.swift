import Foundation

public typealias Articles = [Article]

public struct Article {
  // MARK: Lifecycle

  public init(
    id: Int,
    title: String,
    description: String,
    author: String,
    releaseDate: Date,
    imageUrl: String
  ) {
    self.id = id
    self.title = title
    self.description = description
    self.author = author
    self.releaseDate = releaseDate
    self.imageUrl = imageUrl
  }

  // MARK: Public

  public let id: Int
  public let title: String
  public let description: String
  public let author: String
  public let releaseDate: Date
  public let imageUrl: String
}

extension Article: Codable {
  enum CodingKeys: String, CodingKey {
    case id
    case title
    case description
    case author
    case releaseDate = "release_date"
    case imageUrl = "image"
  }
}

extension Article: Equatable {}
extension Article: Identifiable {}
extension Article: Comparable {
  public static func < (lhs: Article, rhs: Article) -> Bool {
    lhs.releaseDate < rhs.releaseDate
  }
}
