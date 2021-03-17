import SwiftUI
import UIKit

extension SwiftUI.View {
  func toVC() -> UIViewController {
    let vc = UIHostingController(rootView: self)
    vc.view.frame = .init(x: 0, y: 0, width: 375, height: 812)
    return vc
  }
}
