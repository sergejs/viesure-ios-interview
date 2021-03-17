import Foundation

@propertyWrapper
public struct LossyArray<T: Decodable> {
  // MARK: Lifecycle

  public init(wrappedValue: [T]) {
    self.wrappedValue = wrappedValue
  }

  // MARK: Public

  public var wrappedValue: [T]
}

// MARK: Decodable

extension LossyArray: Decodable {
  private struct AnyDecodable: Decodable {}

  public init(from decoder: Decoder) throws {
    var container = try decoder.unkeyedContainer()
    var elements: [T] = []

    while !container.isAtEnd {
      do {
        let wrapper = try container.decode(T.self)
        elements.append(wrapper)
      } catch {
        _ = try? container.decode(AnyDecodable.self)
      }
    }

    wrappedValue = elements
  }
}
