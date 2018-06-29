//
//  User.swift
//  bitrise unofficial ios
//
//  Created by Alexei Gudimenko on 16/6/18.
//  Copyright © 2018 Alexei Gudimenko. All rights reserved.
//

import Foundation
import UIKit


struct User: Codable, Equatable, CustomStringConvertible {
  
  enum CodingKeys: String, CodingKey {
    case data
  }
  
  enum UserInfoKeys: String, CodingKey {
    case username
    case slug
    case avatarUrl
  }
  
  var data: Data?
  
  var avatarUrl: String?
  var slug: String?
  var username: String?
  
  var avatarImage: UIImage?
  
  var description: String
  
  init(username name: String?, slug slugToken: String?, avatarURL url: String?) {
    username = name
    slug = slugToken
    avatarUrl = url
    
    description = """
    == Struct USER ==
    [String] Username: \(username ?? "- no value -")
    [String] Slug:     \(slug ?? "- no value -")
    [String] AvatarURL:\(avatarUrl ?? "- no value -")
    
    \(type(of: self))
    ==================
    """
  }

  init(from decoder: Decoder) throws {
    
    let data = try decoder.container(keyedBy: CodingKeys.self)
    
    let userInfo = try data.nestedContainer(keyedBy: UserInfoKeys.self, forKey: .data)
    username = try userInfo.decodeIfPresent(String.self, forKey: .username)
    slug = try userInfo.decodeIfPresent(String.self, forKey: .slug)
    avatarUrl = try userInfo.decodeIfPresent(String.self, forKey: .avatarUrl)
    
    description = """
    == Struct USER ==
    [String] Username: \(username ?? "- no value -")
    [String] Slug:     \(slug ?? "- no value -")
    [String] AvatarURL:\(avatarUrl ?? "- no value -")
    
    \(type(of: self))
    ==================
    """
  }
  
  func encode(to encoder: Encoder) throws {
    
    var container = encoder.container(keyedBy: CodingKeys.self)
    try container.encode(data, forKey: .data)
    
    var userInfo = container.nestedContainer(keyedBy: UserInfoKeys.self, forKey: .data)
    try userInfo.encode(username, forKey: .username)
    try userInfo.encode(slug, forKey: .slug)
    try userInfo.encode(avatarUrl, forKey: .avatarUrl)
  }
}
