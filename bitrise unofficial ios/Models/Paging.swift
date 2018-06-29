//
//  Paging.swift
//  bitrise unofficial ios
//
//  Created by Alexei Gudimenko on 27/6/18.
//  Copyright © 2018 Alexei Gudimenko. All rights reserved.
//

import Foundation

struct Paging: Codable {
  
  var totalItemCount: Int?
  var pageItemLimit: Int?
  var next: String?
  
  init(from decoder: Decoder) throws {
    let values = try decoder.container(keyedBy: CodingKeys.self)
    totalItemCount = try values.decodeIfPresent(Int.self, forKey: .totalItemCount)
    pageItemLimit = try values.decodeIfPresent(Int.self, forKey: .pageItemLimit)
    next = try values.decodeIfPresent(String.self, forKey: .next)
  }
}
