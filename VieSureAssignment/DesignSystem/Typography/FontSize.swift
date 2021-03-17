import UIKit

public enum FontSize: Int {
  case titleLarge = 28
  case titleMedium = 24
  case titleSmall = 20
  case headline = 18
  case bodyDefault = 16
  case bodySmall = 14
  case label = 12
  case labelSmall = 11

  // MARK: Internal

  var lineSpacing: Float {
    switch self {
      case .titleLarge,
           .titleMedium,
           .titleSmall,
           .bodyDefault: return 4

      case .headline,
           .bodySmall: return 3

      case .label: return 2
      case .labelSmall: return 0.5
    }
  }

  var value: CGFloat {
    CGFloat(rawValue)
  }
}
