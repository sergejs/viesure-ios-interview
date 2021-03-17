import Combine
import Nimble
import Quick
@testable import Utils

enum PublishersRetryIfSpecError: Error {
  case error
}

class PublishersRetryIfSpec: QuickSpec {
  var disposeBag = DisposeBag()

  override func spec() {
    describe("Publisher Retry if") {
      context("Should retry") {
        it("Once") {
          var calls = 0
          let publisher = Deferred {
            Future<Bool, PublishersRetryIfSpecError> { promise in
              calls += 1
              promise(.failure(.error))
            }
          }

          publisher
            .retry(times: 1, if: { _ in true })
            .sink { _ in } receiveValue: { _ in }
            .store(in: &self.disposeBag)

          expect(calls).toEventually(equal(2), timeout: .seconds(3))
        }

        it("Ten times") {
          var calls = 0
          let publisher = Deferred {
            Future<Bool, PublishersRetryIfSpecError> { promise in
              calls += 1
              promise(.failure(.error))
            }
          }

          publisher
            .retry(times: 10, if: { _ in true })
            .sink { _ in } receiveValue: { _ in }
            .store(in: &self.disposeBag)

          expect(calls).toEventually(equal(11), timeout: .seconds(3))
        }

        it("0 times") {
          var calls = 0
          let publisher = Deferred {
            Future<Bool, PublishersRetryIfSpecError> { promise in
              calls += 1
              promise(.failure(.error))
            }
          }

          publisher
            .retry(times: 10, if: { _ in false })
            .sink { _ in } receiveValue: { _ in }
            .store(in: &self.disposeBag)

          expect(calls).toEventually(equal(1), timeout: .seconds(3))
        }
      }
    }
  }
}
