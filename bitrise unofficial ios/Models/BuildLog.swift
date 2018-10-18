//
//  BuildLog.swift
//  bitrise unofficial ios
//
//  Created by Alexei Gudimenko on 26/9/18.
//  Copyright © 2018 Alexei Gudimenko. All rights reserved.
//

import Foundation

struct BuildLog: Codable {
  let expiringRawLogUrl: String
  let generatedLogChunksNum: Int
  let isArchived: Bool
  let logChunks: [LogChunk]
  let timestamp: String?
  
  enum CodingKeys: CodingKey {
    case expiringRawLogUrl
    case generatedLogChunksNum
    case isArchived
    case logChunks
    case timestamp
  }
  
  init(from decoder: Decoder) throws {
    let values = try decoder.container(keyedBy: CodingKeys.self)
    expiringRawLogUrl = try values.decode(String.self, forKey: .expiringRawLogUrl)
    generatedLogChunksNum = try values.decode(Int.self, forKey: .generatedLogChunksNum)
    isArchived = try values.decode(Bool.self, forKey: .isArchived)
    logChunks = try values.decode([LogChunk].self, forKey: .logChunks)
    timestamp = try values.decodeIfPresent(String.self, forKey: .timestamp)
  }
}

struct LogChunk: Codable {
  let chunk: String
  let position: Int
}
