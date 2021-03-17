//
//  Storable.swift
//  Utils
//
//  Created by Sergejs Smirnovs on 08/03/2021.
//
import Foundation

public protocol Storable {
  func store(_ data: Data, to url: URL) throws
  func load(from url: URL) throws -> Data?
}

public extension Storable {
  func encode<T: Encodable>(_ object: T, to URL: URL) throws {
    let encoder = JSONEncoder()
    encoder.dateEncodingStrategy = .formatted(ArticleDateFormatter.shared)
    let data = try encoder.encode(object)
    try store(data, to: URL)
  }

  func decode<T: Decodable>(from url: URL) throws -> T? {
    guard
      let data = try load(from: url)
    else {
      return nil
    }

    let decoder = JSONDecoder()
    decoder.dateDecodingStrategy = .formatted(ArticleDateFormatter.shared)
    return try decoder.decode(T.self, from: data)
  }
}
