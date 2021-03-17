import SwiftUI

public struct ImageView: View {
  // MARK: Lifecycle

  public init(
    withURL url: String,
    contentMode: ContentMode = .fill
  ) {
    self.contentMode = contentMode
    imageLoader = ImageLoader(
      urlString: url,
      httpClient: ServiceContainer.shared.resolve(type: HTTPClientRequestDispatcher.self)!,
      cache: ServiceContainer.shared.resolve(type: ImageCache.self)!
    )
  }

  // MARK: Public

  public var body: some View {
    Image(uiImage: image)
      .resizable()
      .aspectRatio(contentMode: contentMode)
      .onReceive(imageLoader.didChange) { image in
        self.image = image
      }
      .onAppear(perform: imageLoader.onAppear)
  }

  // MARK: Internal

  @ObservedObject
  internal var imageLoader: ImageLoader
  @State
  internal var image = UIImage()
  internal let contentMode: ContentMode
}
