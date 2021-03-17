import Foundation

public enum ArticleDateFormatter {
  public static let shared = DateFormatter.articleFormatter()
}

public enum PresentingArticleDateFormatter {
  public static let shared = DateFormatter.presentationDateFormatter()
}

private extension DateFormatter {
  static func articleFormatter() -> DateFormatter {
    let formatter = DateFormatter()
    formatter.dateFormat = "MM/dd/yyyy"
    return formatter
  }

  static func presentationDateFormatter() -> DateFormatter {
    let formatter = DateFormatter()
    formatter.dateFormat = "E, MMM d, ''YY'"
    return formatter
  }
}
