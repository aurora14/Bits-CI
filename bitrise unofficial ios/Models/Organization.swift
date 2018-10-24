//
//  Organization.swift
//  bitrise unofficial ios
//
//  Created by Alexei Gudimenko on 15/9/18.
//  Copyright © 2018 Alexei Gudimenko. All rights reserved.
//

import UIKit

struct Organizations: Codable {
  let data: [Organization]
}

struct Organization: Codable, CustomStringConvertible {
  
  var description: String
  
  enum CodingKeys: String, CodingKey {
    case name
    case slug
    case avatarIconUrl
  }
  
  var data: Data?
  
  var avatarIconUrl: String?
  var name: String?
  var slug: Slug?
  
  var avatarImage: UIImage?
  
  init(from decoder: Decoder) throws {
    
    let container = try decoder.container(keyedBy: CodingKeys.self)
    
    avatarIconUrl = try container.decodeIfPresent(String.self, forKey: .avatarIconUrl)
    slug = try container.decodeIfPresent(Slug.self, forKey: .slug)
    name = try container.decodeIfPresent(String.self, forKey: .name)
    
    description = """
    == Struct ORGANIZATION ==
    [String] Username: \(name ?? "- no value -")
    [String] Slug:     \(slug ?? "- no value -")
    [String] AvatarURL:\(avatarIconUrl ?? "- no value -")
    
    \(type(of: self))
    ==================
    """
  }
  
}

