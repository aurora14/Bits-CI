//
//  User.swift
//  bitrise unofficial ios
//
//  Created by Alexei Gudimenko on 16/6/18.
//  Copyright © 2018 Alexei Gudimenko. All rights reserved.
//

import Foundation


struct User: Decodable, Encodable, Equatable, CustomStringConvertible {
  
  var username: String
  var slug: String
  var avatarURL: String
  
  var description: String
  
  init(username name: String, slug slugToken: String, avatarURL url: String) {
    username = name
    slug = slugToken
    avatarURL = url
    
    description = """
    == Struct USER ==
    [String] Username: \(username)
    [String] Slug:     \(slug)
    [String] AvatarURL:\(avatarURL)
    
    \(type(of: self))
    ==================
    """
  }
  
}
