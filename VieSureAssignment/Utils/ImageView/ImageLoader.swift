import Combine
import SwiftUI

public final class ImageLoader: ObservableObject {
  // MARK: Lifecycle

  public init(
    urlString: String,
    httpClient: HTTPClientRequestDispatcher,
    cache: ImageCache
  ) {
    self.cache = cache
    self.httpClient = httpClient
    self.urlString = urlString
  }

  // MARK: Public

  public var didChange = PassthroughSubject<UIImage, Never>()

  public func onAppear() {
    if let cachedImage = cache.value(forKey: urlString) {
      update(
        image: cachedImage,
        forUrl: urlString
      )
      return
    }

    guard
      let urlComponents = URLComponents(string: urlString)
    else {
      return
    }
    let request = HTTPRequest(urlComponents: urlComponents)
    httpClient.execute(request: request) { [weak self] result in
      guard let self = self else { return }

      if case let .success(response) = result,
         let data = response.body,
         let image = UIImage(data: data) {
        self.update(
          image: image,
          forUrl: self.urlString
        )
      }
    }
  }

  // MARK: Internal

  internal var image = UIImage() {
    didSet {
      didChange.send(image)
    }
  }

  // MARK: Private

  private let httpClient: HTTPClientRequestDispatcher
  private let cache: ImageCache
  private let urlString: String

  private func update(
    image: UIImage,
    forUrl urlString: String
  ) {
    cache.insert(image, forKey: urlString)

    DispatchQueue.main.async { [weak self] in
      self?.image = image
    }
  }
}
