import ArticleList
import DesignSystem
import SwiftUI
import UIKit
import Utils

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
  var window: UIWindow?
  var coordinator: Coordinatable?

  func scene(
    _ scene: UIScene,
    willConnectTo session: UISceneSession,
    options connectionOptions: UIScene.ConnectionOptions
  ) {
    guard
      !Thread.current.isRunningXCTest
    else {
      let contentView = TestView()

      if let windowScene = scene as? UIWindowScene {
        let window = UIWindow(windowScene: windowScene)
        window.rootViewController = UIHostingController(rootView: contentView)
        self.window = window
        window.makeKeyAndVisible()
      }

      return
    }

    buildDependencyGraph()

    coordinator = ArticleListCoordinatorFactory.makeCoordinator()

    let contentView = coordinator?.start()

    if let windowScene = scene as? UIWindowScene {
      let window = UIWindow(windowScene: windowScene)
      window.rootViewController = UIHostingController(rootView: contentView)
      self.window = window
      window.makeKeyAndVisible()
    }
  }
}

extension SceneDelegate {
  private static let aesKeychainKeyAccount = "AES_KEY"
  private static let password = "Password123456".data(using: .utf8)!

  private func buildDependencyGraph() {
    let container = ServiceContainer.shared

    container.register(type: FileManager.self, component: FileManager.default)
    container.register(type: ImageCache.self, component: ImageCache(entryLifetime: 60 * 60 * 24))
    container.register(type: HTTPClientRequestDispatcher.self, component: HTTPClient(session: URLSession.shared))

    let crypter: Encryptable
    do {
      crypter = try buildCrypter()
    } catch {
      fatalError("Unable to create crypter")
    }
    container.register(type: Storable.self, component: DiskStorage(crypter: crypter))
    container.register(type: CacheURL.self, component: makeCacheUrl())
  }

  private func buildCrypter() throws -> Encryptable {
    try AES256Crypter(key: try makeKey())
  }

  private func makeKey() throws -> Data {
    let bundle = Bundle.main.bundleIdentifier ?? "VieSure"

    let keychain = Keychain(service: bundle)
    if let key = keychain.get(Self.aesKeychainKeyAccount) {
      return key
    }
    let key = try AES256KeyFactory().makeKey(with: Self.password)
    try keychain.set(Self.aesKeychainKeyAccount, data: key)

    return key
  }

  private func makeCacheUrl() -> CacheURL {
    let fileManager = ServiceContainer.shared.resolve(type: FileManager.self)!

    let folderURLs = fileManager.urls(
      for: .cachesDirectory,
      in: .userDomainMask
    )
    return folderURLs[0].appendingPathComponent(Self.cacheFilename)
  }

  // MARK: Private

  private static let cacheFilename = "ArticleCache.cache"
}
