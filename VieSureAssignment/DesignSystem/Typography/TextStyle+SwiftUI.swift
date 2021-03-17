import SwiftUI

public extension View {
  func textStyle(_ textStyle: TextStyle) -> some View {
    font(textStyle.font)
      .foregroundColor(textStyle.color)
      .lineSpacing(textStyle.lineSpacing)
      .padding(.vertical, textStyle.lineSpacing / 2)
  }
}
