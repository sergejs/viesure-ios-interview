import SwiftUI
import UIKit

public class Design {
  public static var bundle: Bundle {
    Bundle(for: Design.self)
  }

  public static func setupTableViewAppearance() {
    UITableView.appearance().backgroundColor = .clear
    UITableView.appearance().separatorColor = .clear
    UITableView.appearance().separatorStyle = .none
  }
}
