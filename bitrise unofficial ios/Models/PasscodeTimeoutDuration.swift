//
//  File.swift
//  bitrise unofficial ios
//
//  Created by Alexei Gudimenko on 12/12/18.
//  Copyright © 2018 Alexei Gudimenko. All rights reserved.
//

import Foundation


enum PasscodeTimeoutDuration: Int {
  
  case always = 0
  case one = 1
  case five = 5
  case fifteen = 15
  case sixty = 60
  
  /// Timeout duration in minutes
  var title: String {
    switch self {
    case .always: return "Always"
    case .one: return "1 \(L10n.minute)"
    case .five: return "5 \(L10n.minutes)"
    case .fifteen: return "15 \(L10n.minutes)"
    case .sixty: return "60 \(L10n.minutes)"
    }
  }
}
