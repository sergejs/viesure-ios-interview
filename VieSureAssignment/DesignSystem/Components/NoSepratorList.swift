import SwiftUI

public struct NoSepratorList<Content>: View where Content: View {
  // MARK: Lifecycle

  public init(
    spacing: Space = .medium,
    @ViewBuilder content: @escaping () -> Content
  ) {
    self.spacing = spacing.value
    self.content = content
  }

  // MARK: Public

  public var body: some View {
    if #available(iOS 14.0, *) {
      ScrollView {
        LazyVStack(spacing: spacing) {
          content()
        }
      }
    } else {
      List {
        content()
          .listRowInsets(
            EdgeInsets(
              top: spacing,
              leading: 0,
              bottom: 0,
              trailing: 0
            )
          )
      }
      .onAppear {
        Design.setupTableViewAppearance()
      }
    }
  }

  // MARK: Internal

  let content: () -> Content
  let spacing: CGFloat
}
