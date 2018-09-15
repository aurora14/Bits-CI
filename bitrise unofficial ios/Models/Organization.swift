//
//  Organization.swift
//  bitrise unofficial ios
//
//  Created by Alexei Gudimenko on 15/9/18.
//  Copyright © 2018 Alexei Gudimenko. All rights reserved.
//

import UIKit

struct Organization: Codable, CustomStringConvertible {
  
  var description: String
  
  enum CodingKeys: String, CodingKey {
    case data
  }
  
  enum OrgInfoKeys: String, CodingKey {
    case name
    case slug
    case avatarUrl
  }
  
  var data: Data?
  
  var avatarUrl: String?
  var name: String?
  var slug: Slug?
  
  var avatarImage: UIImage?
  
  init(from decoder: Decoder) throws {
    
    let data = try decoder.container(keyedBy: CodingKeys.self)
    
    let orgInfo = try data.nestedContainer(keyedBy: OrgInfoKeys.self, forKey: .data)
    avatarUrl = try orgInfo.decodeIfPresent(String.self, forKey: .avatarUrl)
    slug = try orgInfo.decodeIfPresent(Slug.self, forKey: .slug)
    name = try orgInfo.decodeIfPresent(String.self, forKey: .name)
    
    description = """
    == Struct ORGANIZATION ==
    [String] Username: \(name ?? "- no value -")
    [String] Slug:     \(slug ?? "- no value -")
    [String] AvatarURL:\(avatarUrl ?? "- no value -")
    
    \(type(of: self))
    ==================
    """
  }
  
  func encode(to encoder: Encoder) throws {
    
    var container = encoder.container(keyedBy: CodingKeys.self)
    try container.encode(data, forKey: .data)
    
    var orgInfo = container.nestedContainer(keyedBy: OrgInfoKeys.self, forKey: .data)
    try orgInfo.encode(name, forKey: .name)
    try orgInfo.encode(slug, forKey: .slug)
    try orgInfo.encode(avatarUrl, forKey: .avatarUrl)
  }
}
