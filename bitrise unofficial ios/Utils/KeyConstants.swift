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
  static let isUsingPasscodeUnlock = "Passcode Lock Key"
  static let isUsingBiometricUnlock = "Biometric Lock Key"
  
  static let backgroundTimeValue = "ApplicationBackgroundTime"
  static let isPasscodeTimeoutEnabled = "PasscodeTimeoutEnabled"
  static let passcodeTimeoutValue = "PasscodeTimeoutValue"
  static let passcodeUnlockKey = "PasscodeUnlockKey"
  
}
