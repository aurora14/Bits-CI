//
//  AbortBuildParams.swift
//  bitrise unofficial ios
//
//  Created by Alexei Gudimenko on 14/9/18.
//  Copyright © 2018 Alexei Gudimenko. All rights reserved.
//

import Foundation

struct AbortBuildParams: Codable {
  
  var abortReason: String
  var abortWithSuccess: Bool
  var skipNotifications: Bool
  
}
