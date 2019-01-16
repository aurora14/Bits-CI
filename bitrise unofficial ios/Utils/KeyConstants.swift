//
//  KeyConstants.swift
//  bitrise unofficial ios
//
//  Created by Alexei Gudimenko on 21/11/18.
//  Copyright © 2018 Alexei Gudimenko. All rights reserved.
//
//  Maintains a list of UserDefaults keys.
//  This is separate from the L10n constants because L10n is primarily kept for localization work, and keys shouldn't be translated

import Foundation

struct UserDefaultKey {
  
  static let isDarkThemeSelected = "Dark Theme Selection Key"
  /// Records whether the user has enabled the passcode unlock
  static let isUsingPasscodeUnlock = "Passcode Lock Key"
  /// Records whether the user has enabled the biometric unlock
  static let isUsingBiometricUnlock = "Biometric Lock Key"
  
  /// Records when the application was moved to background
  static let backgroundTimeValue = "ApplicationBackgroundTime"
  /// Records whether user has enabled the grace period
  static let isPasscodeTimeoutEnabled = "PasscodeTimeoutEnabled"
  /// Records the value of the user-selected grace period
  static let passcodeTimeoutValue = "PasscodeTimeoutValue"
  ///
  static let passcodeUnlockKey = "PasscodeUnlockKey"
  
}
