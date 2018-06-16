//
//  BitriseProjectOwner.swift
//  bitrise unofficial ios
//
//  Created by Alexei Gudimenko on 16/6/18.
//  Copyright © 2018 Alexei Gudimenko. All rights reserved.
//

import Foundation


struct BitriseProjectOwner: Encodable, Decodable, Equatable {
  
  var accountType: String
  var name: String
  var slug: String
  
  init(accountType account: String, name ownerName: String, slug ownerSlug: String) {
    accountType = account
    name = ownerName
    slug = ownerSlug
  }
}
