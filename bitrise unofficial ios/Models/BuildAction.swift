//
//  BuildAction.swift
//  bitrise unofficial ios
//
//  Created by Alexei Gudimenko on 7/9/18.
//  Copyright © 2018 Alexei Gudimenko. All rights reserved.
//

import UIKit

enum BuildAction {
  
  case rebuild
  case abort
  
  var title: String {
    switch self {
    case .rebuild: return "Rebuild"
    case .abort: return "Abort"
    }
  }
  
  var color: UIColor {
    switch self {
    case .rebuild: return Asset.Colors.bitriseGreen.color
    case .abort: return Asset.Colors.bitriseYellow.color
    }
  }
  
  var icon: UIImage {
    switch self {
    case .rebuild: return Asset.Icons.repeat.image
    case .abort: return Asset.Icons.buildAborted.image
    }
  }
}
