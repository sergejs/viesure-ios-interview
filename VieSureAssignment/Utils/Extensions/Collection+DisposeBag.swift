import Combine

public typealias DisposeBag = Set<AnyCancellable>

public extension Collection where Element == AnyCancellable {
  func dispose() {
    forEach { $0.cancel() }
  }
}
