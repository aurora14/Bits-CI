//
//  SharedData.swift
//  bitrise-unofficial-ios
//
//  Created by Alexei Gudimenko on 13/6/18.
//  Copyright © 2018 Alexei Gudimenko. All rights reserved.
//

import Foundation
import KeychainAccess

protocol UserUpdateDelegate: class {
  func updateUserViews()
}

class App {
  
  static let sharedInstance = App()
  
  let apiClient = APIClient(baseURL: URL(string: "https://api.bitrise.io")!)
  
  let keychain = Keychain(service: "com.gudimenko.alexei.bitrise-unofficial-ios")
  let tokenKey = "BitriseAuthorizationToken"
  
  /// Authorization token for Bitrise.io API. This token is required for all Bitrise.io API calls
  private var bitriseAPIToken: String?
  
  var userPreferences: UserDefaults {
    return UserDefaults.standard
  }
  
  weak var userUpdateDelegate: UserUpdateDelegate?
  
  var currentUser: User? {
    didSet {
      userUpdateDelegate?.updateUserViews()
    }
  }
  
  private lazy var encoder = JSONEncoder()
  private lazy var decoder = JSONDecoder()
  
  private init() {}
  
}

// MARK: - Authorization token management
extension App {
  
  /// Saves the generated token to keychain
  ///
  /// - Parameter token: Bitrise access token. The app should only ever have one value maintained
  /// for sign on. If the user decides to log out, that token is wiped and a new one must be entered
  /// before accessing any BR content again
  func saveBitriseAuthToken(_ token: String, then: (() -> Void)? = nil) {
    DispatchQueue.global(qos: .background).async { [weak self] in
      
      guard let strongSelf = self else {
        then?()
        return
      }
      
      do {
        try strongSelf.keychain
          .label("Bitrise Access Token")
          .comment("Authorization value for accessing Bitrise.io API")
          .synchronizable(true)
          .accessibility(.afterFirstUnlock)
          .set(token, key: strongSelf.tokenKey)
        then?()
      } catch let error {
        print(error.localizedDescription)
        then?()
      }
    }
  }
  
  /// Removes the token from the keychain if one is present, and calls a
  /// completion handler once finished.
  ///
  /// - Parameter completion: any action to take after removing the token. Typically
  /// this may include verification of whether it was removed successfully, or updating
  /// the user interface
  ///
  /// Note: this operation is performed on the background thread. If the user decides
  /// to check for available token immediately after calling this method, the check
  /// may still return valid authorization. Therefore any operations that may be
  /// time-dependent should be placed in the completion closure. If there's nothing
  /// that needs to be done after removing a token, the user can pass 'nil' for this
  /// parameter
  func removeBitriseAuthToken(then: (() -> Void)?) {
    DispatchQueue.global(qos: .background).async { [weak self] in
      
      guard let strongSelf = self else {
        then?()
        return
      }
      
      do {
        try strongSelf.keychain.remove(strongSelf.tokenKey)
        then?()
      } catch let error {
        print(error.localizedDescription)
        then?()
      }
    }
  }
  
  func getBitriseAuthToken() -> String? {
    do {
      try bitriseAPIToken = self.keychain.get(tokenKey)
      return bitriseAPIToken
    } catch let error {
      print(error.localizedDescription)
      bitriseAPIToken = nil
      return bitriseAPIToken
    }
  }
  
  /// Attempts to get a valid stored token from the keychain. If the operation succeeds, calls completion
  /// handler with true result, otherwise with false result.
  /// * Under consideration: to include the token in the closure return
  ///
  /// - Parameter completion: true if there are valid credentials available, false if not.
  ///
  /// * Usage: App.shared.checkForAvailableBitriseToken { isAvailable in }
  func checkForAvailableBitriseToken(_ then: @escaping (_ isAvailable: Bool) -> Void) {
    
    // Step 1: Check if Keychain has a valid token. If not, open the token modal. There the user
    // has the option
    guard let savedToken = getBitriseAuthToken() else {
      then(false)
      return
    }
    
    // Step 2: Check whether the keychain token is stale (e.g. if the user manually deleted it in Bitrise dashboard)
    apiClient.validateGeneratedToken(savedToken) { isValid, _ in
      
      if isValid {
        then(true)
        return
      }
      
      then(false)
      return
    }
  }
}

// MARK: - Caching/saving common data to disk
extension App {
  
  func getDocumentsDirectory() -> URL {
    let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
    return paths.first ?? paths[0]
  }
  
  func writeUserToMemory() {
    do {
      let file = getDocumentsDirectory().appendingPathComponent("bitriseuser.json")
      let jsonData = try encoder.encode(currentUser)
      try jsonData.write(to: file, options: [.atomicWrite, .completeFileProtection])
    } catch let error {
      assertionFailure("Unable to write user info: \(error.localizedDescription)")
      print("*** Error: \(error.localizedDescription)")
    }
  }
  
  func restoreUserFromMemory() {
    do {
      let file = getDocumentsDirectory().appendingPathComponent("bitriseuser.json")
      let jsonData = try Data(contentsOf: file)
      currentUser = try decoder.decode(User.self, from: jsonData)
    } catch let error {
      assertionFailure("Unable to read user info: \(error.localizedDescription)")
      print("*** Error: \(error.localizedDescription)")
    }
  }
  
  func isZuckerbergALizard() -> Bool {
    return true
  }
}

