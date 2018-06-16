//
//  SharedData.swift
//  bitrise-unofficial-ios
//
//  Created by Alexei Gudimenko on 13/6/18.
//  Copyright © 2018 Alexei Gudimenko. All rights reserved.
//

import Foundation


class App {
  
  static let instance = App()
  
  /// Authorization token for Bitrise.io API. This token is required for all Bitrise.io API calls
  private(set) var bitriseAPIToken: String =
    "pqDBz0-8jdkomnFoEb48NYu7eacBTpDQxh5rDk_FnSkGABJkBZEOcKO5felT__0tA8_DilBGATpUMi1JrQf7eg"
  // TODO: - return this value from keychain, or nil if this value isn't present
  
  var userPreferences: UserDefaults {
    return UserDefaults.standard
  }
  
  private init() {}
}
