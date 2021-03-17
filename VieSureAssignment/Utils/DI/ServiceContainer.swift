import Foundation

public protocol ServiceContainable {
  func register<T>(type: T.Type, component: Any)
  func resolve<T>(type: T.Type) -> T?
}

public final class ServiceContainer: ServiceContainable {
  // MARK: Lifecycle

  private init() {}

  // MARK: Public

  public static let shared: ServiceContainable = ServiceContainer()

  // MARK: Internal

  internal var components: [String: Any] = [:]
}

public extension ServiceContainer {
  func register<T>(type: T.Type, component: Any) {
    components["\(type)"] = component
  }

  func resolve<T>(type: T.Type) -> T? {
    components["\(type)"] as? T
  }
}
