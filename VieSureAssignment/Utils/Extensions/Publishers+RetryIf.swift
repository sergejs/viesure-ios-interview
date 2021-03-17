import Combine

public extension Publishers {
  struct RetryIf<P: Publisher>: Publisher {
    // MARK: Public

    public typealias Output = P.Output
    public typealias Failure = P.Failure

    public func receive<S>(subscriber: S) where S: Subscriber, Failure == S.Failure, Output == S.Input {
      guard
        times > 0
      else {
        return publisher.receive(subscriber: subscriber)
      }

      publisher
        .catch { (error: P.Failure) -> AnyPublisher<Output, Failure> in
          if condition(error) {
            return RetryIf(
              publisher: publisher,
              times: times - 1,
              condition: condition
            )
            .eraseToAnyPublisher()
          } else {
            return Fail(error: error)
              .eraseToAnyPublisher()
          }
        }
        .receive(subscriber: subscriber)
    }

    // MARK: Internal

    let publisher: P
    let times: Int
    let condition: (P.Failure) -> Bool
  }
}

public extension Publisher {
  func retry(
    times: Int,
    if condition: @escaping (Failure) -> Bool
  ) -> Publishers.RetryIf<Self> {
    Publishers.RetryIf(
      publisher: self,
      times: times,
      condition: condition
    )
  }
}
