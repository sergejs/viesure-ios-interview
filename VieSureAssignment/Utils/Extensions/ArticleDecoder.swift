import Foundation

public enum ArticleDecoder {
  public static let shared: JSONDecoder = {
    let decoder = JSONDecoder()
    decoder.dateDecodingStrategy = .formatted(ArticleDateFormatter.shared)
    return decoder
  }()
}
