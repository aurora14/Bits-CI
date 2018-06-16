//
//  SharedData.swift
//  bitrise-unofficial-ios
//
//  Created by Alexei Gudimenko on 13/6/18.
//  Copyright © 2018 Alexei Gudimenko. All rights reserved.
//

import Foundation
import KeychainAccess

class App {
  
  static let instance = App()
  
  let keychain = Keychain(service: "com.gudimenko.alexei.bitrise-unofficial-ios")
  let tokenKey = "BitriseAuthorizationToken"
  
  /// Authorization token for Bitrise.io API. This token is required for all Bitrise.io API calls
  private(set) var bitriseAPIToken: String? =
    "pqDBz0-8jdkomnFoEb48NYu7eacBTpDQxh5rDk_FnSkGABJkBZEOcKO5felT__0tA8_DilBGATpUMi1JrQf7eg"
  // TODO: - return this value from keychain, or nil if this value isn't present
  
  var userPreferences: UserDefaults {
    return UserDefaults.standard
  }
  
  private init() {
    
  }
  
  /// <#Description#>
  ///
  /// - Parameter token: Bitrise access token. The app should only ever have one value maintained
  /// for sign on. If the user decides to log out, that token is wiped and a new one must be entered
  /// before accessing any BR content again
  func saveBitriseAuthToken(_ token: String) {
    DispatchQueue.global(qos: .background).async {
      do {
        try self.keychain
          .label("Bitrise Access Token")
          .comment("Authorization value for accessing Bitrise.io API")
          .synchronizable(true)
          .accessibility(.afterFirstUnlock)
          .set(token, key: self.tokenKey)
      } catch let error {
        print(error.localizedDescription)
      }
    }
  }
  
  func removeBitriseAuthToken() {
    DispatchQueue.global(qos: .background).async {
      do {
        try self.keychain.remove(self.tokenKey)
      } catch let error {
        print(error.localizedDescription)
      }
    }
  }
  
  func getBitriseAuthToken() {
    do {
      try bitriseAPIToken = self.keychain.get(tokenKey)
    } catch let error {
      print(error.localizedDescription)
    }
  }
}
