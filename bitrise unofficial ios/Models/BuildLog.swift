//
//  BuildLog.swift
//  bitrise unofficial ios
//
//  Created by Alexei Gudimenko on 26/9/18.
//  Copyright © 2018 Alexei Gudimenko. All rights reserved.
//

import Foundation

struct BuildLog: Codable {
  let expiringRawLogURL: String
  let generatedLogChunksNum: Int
  let isArchived: Bool
  let logChunks: [LogChunk]
  let timestamp: JSONNull?
  
  enum CodingKeys: String, CodingKey {
    case expiringRawLogURL = "expiring_raw_log_url"
    case generatedLogChunksNum = "generated_log_chunks_num"
    case isArchived = "is_archived"
    case logChunks = "log_chunks"
    case timestamp
  }
}

struct LogChunk: Codable {
  let chunk: String
  let position: Int
}

// MARK: Convenience initializers

extension BuildLog {
  init?(data: Data) {
    guard let me = try? JSONDecoder().decode(BuildLog.self, from: data) else { return nil }
    self = me
  }
  
  init?(_ json: String, using encoding: String.Encoding = .utf8) {
    guard let data = json.data(using: encoding) else { return nil }
    self.init(data: data)
  }
  
  init?(fromURL url: String) {
    guard let url = URL(string: url) else { return nil }
    guard let data = try? Data(contentsOf: url) else { return nil }
    self.init(data: data)
  }
  
  var jsonData: Data? {
    return try? JSONEncoder().encode(self)
  }
  
  var json: String? {
    guard let data = self.jsonData else { return nil }
    return String(data: data, encoding: .utf8)
  }
}

extension LogChunk {
  init?(data: Data) {
    guard let me = try? JSONDecoder().decode(LogChunk.self, from: data) else { return nil }
    self = me
  }
  
  init?(_ json: String, using encoding: String.Encoding = .utf8) {
    guard let data = json.data(using: encoding) else { return nil }
    self.init(data: data)
  }
  
  init?(fromURL url: String) {
    guard let url = URL(string: url) else { return nil }
    guard let data = try? Data(contentsOf: url) else { return nil }
    self.init(data: data)
  }
  
  var jsonData: Data? {
    return try? JSONEncoder().encode(self)
  }
  
  var json: String? {
    guard let data = self.jsonData else { return nil }
    return String(data: data, encoding: .utf8)
  }
}

// MARK: Encode/decode helpers

class JSONNull: Codable {
  public init() {}
  
  public required init(from decoder: Decoder) throws {
    let container = try decoder.singleValueContainer()
    if !container.decodeNil() {
      throw DecodingError.typeMismatch(JSONNull.self, DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "Wrong type for JSONNull"))
    }
  }
  
  public func encode(to encoder: Encoder) throws {
    var container = encoder.singleValueContainer()
    try container.encodeNil()
  }
}
