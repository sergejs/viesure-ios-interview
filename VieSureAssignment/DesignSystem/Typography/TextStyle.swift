import SwiftUI

public struct TextStyle {
  // MARK: Lifecycle

  public init(
    color: Color,
    size: FontSize,
    weight: FontWeight = .regular
  ) {
    font = Font.system(
      size: size.value,
      weight: weight.value,
      design: .default
    )
    self.color = color
    lineSpacing = CGFloat(size.lineSpacing)
  }

  // MARK: Internal

  let font: Font
  let color: Color
  let lineSpacing: CGFloat
}

public extension View {
  func textStyle(
    _ color: Color,
    size: FontSize,
    weight: FontWeight = .regular
  ) -> some View {
    textStyle(TextStyle(color: color, size: size, weight: weight))
  }
}
