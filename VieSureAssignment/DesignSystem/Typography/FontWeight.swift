import SwiftUI

public enum FontWeight {
  case regular
  case bold

  // MARK: Internal

  var value: Font.Weight {
    switch self {
      case .regular: return .regular
      case .bold: return .bold
    }
  }
}
