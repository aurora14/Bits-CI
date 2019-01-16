//
//  ThemeUpdater.swift
//  bitrise unofficial ios
//
//  Created by Alexei Gudimenko on 5/11/18.
//  Copyright © 2018 Alexei Gudimenko. All rights reserved.
//

import UIKit


enum Theme {
  
  case regular, dark
  
  var primaryBackgroundColor: UIColor {
    switch self {
    case .regular: return .white
    case .dark: return Asset.Colors.darkBackground.color
    }
  }
  
  var primaryTextColor: UIColor {
    switch self {
    case .regular: return .darkText
    case .dark: return .white
    }
  }
  
  var barStyle: UIBarStyle {
    switch self {
    case .regular: return .default
    case .dark: return .black
    }
  }
}

