import Nimble
import Quick
import SwiftUI
import UIKit
@testable import Utils

class ImageLoaderSpec: QuickSpec {
  var disposeBag = DisposeBag()
  let mockHttp = MockHTTPClient()
  let cache = ImageCache()

  override func spec() {
    beforeEach {
      self.cache.removeValue(forKey: "url-string")
    }

    describe("ImageLoader") {
      context("Basic usage") {
        it("Image downloaded") {
          let image = UIImage(systemName: "square.and.arrow.up")!
          let data = image.pngData()!

          self.mockHttp.then { request, result in
            let response = HTTPResponse(
              request: request,
              response: HTTPURLResponse(),
              body: data
            )
            result(.success(response))
          }

          let sut = ImageLoader(
            urlString: "url-string",
            httpClient: self.mockHttp,
            cache: self.cache
          )
          sut.onAppear()

          expect(sut.image.size.height).toEventuallyNot(equal(0), timeout: .seconds(3))
        }

        it("Image cached") {
          let image = UIImage(systemName: "square.and.arrow.up")!

          self.cache.insert(image, forKey: "url-string")

          let sut = ImageLoader(
            urlString: "url-string",
            httpClient: self.mockHttp,
            cache: self.cache
          )
          sut.onAppear()

          expect(sut.image.size.height).toEventuallyNot(equal(0), timeout: .seconds(3))
        }
      }
    }
  }
}
