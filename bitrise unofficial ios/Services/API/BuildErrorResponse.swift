//
//  BuildErrorResponse.swift
//  bitrise unofficial ios
//
//  Created by Alexei Gudimenko on 21/8/18.
//  Copyright © 2018 Alexei Gudimenko. All rights reserved.
//

import Foundation

struct BuildErrorResponse: Codable {
  
  var status: String
  var message: String
  var slug: String
  var service: String
  
}
