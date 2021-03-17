import Foundation

final class MockedData {
  static let articles: URL = Bundle(for: MockedData.self)
    .url(forResource: "correct_articles", withExtension: "json")!
  static let articlesShort: URL = Bundle(for: MockedData.self)
    .url(forResource: "articles_short", withExtension: "json")!
  static let articlesBroken: URL = Bundle(for: MockedData.self)
    .url(forResource: "broken_articles", withExtension: "json")!
}

extension URL {
  var data: Data {
    try! Data(contentsOf: self)
  }
}
