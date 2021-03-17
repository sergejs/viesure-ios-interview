import SwiftUI

public enum Space {
  case micro
  case xSmall
  case small
  case medium
  case large
  case xLarge
  case xxLarge
  case xxxLarge
  case gutter
  case rowHeight

  // MARK: Public

  public var value: CGFloat {
    switch self {
      case .micro: return 4
      case .xSmall: return 8
      case .small: return 12
      case .medium: return 16
      case .large: return 24
      case .xLarge: return 32
      case .xxLarge: return 48
      case .xxxLarge: return 68
      case .gutter: return 16
      case .rowHeight: return 44
    }
  }
}

// MARK: - ViewModifier

struct SpaceModifier: ViewModifier {
  var edges: Edge.Set
  var space: Space

  func body(content: Content) -> some View {
    content
      .padding(edges, space.value)
  }
}

public extension View {
  func padding(_ edges: Edge.Set = .all, _ space: Space) -> some View {
    modifier(SpaceModifier(edges: edges, space: space))
  }
}
