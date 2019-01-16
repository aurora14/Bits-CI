//
//  SettingsVC+PasscodeDelegate.swift
//  bitrise unofficial ios
//
//  Created by Alexei Gudimenko on 7/12/18.
//  Copyright © 2018 Alexei Gudimenko. All rights reserved.
//

import Foundation

extension SettingsViewController: PasscodeViewControllerDelegate {
  
  func didCompletePasscodeSetup(_ controller: PasscodeViewController) {
    isUsingPasscodeUnlock = true
    UserDefaults.standard.set(isUsingPasscodeUnlock, forKey: UserDefaultKey.isUsingPasscodeUnlock)
    passcodeAuthSwitch.isOn = isUsingPasscodeUnlock
    biometricAuthSwitch.isEnabled = isUsingPasscodeUnlock
    controller.dismiss(animated: true, completion: nil)
  }
  
  func didCancelPasscodeSetup(_ controller: PasscodeViewController, forUserFlow flow: PasscodeUserFlow = .settingUp) {
    print("*** User flow when cancelling: \(flow)")
    switch flow {
    case .settingUp, .resetting:
      setUnlockSwitches()
    default:
      ()
    }
    controller.dismiss(animated: true, completion: nil)
  }
  
  func didUnlock(_ controller: PasscodeViewController,
                 withAuthorizationOfType authorizationType: AppUnlockAuthorizationType) {
    
    controller.dismiss(animated: true, completion: nil)
  }
  
  func didSwitchOffPasscode(_ controller: PasscodeViewController) {
    UserDefaults.standard.set(false, forKey: UserDefaultKey.isUsingPasscodeUnlock)
    UserDefaults.standard.set(false, forKey: UserDefaultKey.isUsingBiometricUnlock)
    setUnlockSwitches() // this call might not be necessary, since it's invoked in viewWillAppear.
    // However if issues are experienced, try using it
    controller.dismiss(animated: true, completion: nil)
  }
  
  func didCancelPasscodeOff(_ controller: PasscodeViewController) {
    isUsingPasscodeUnlock = true
    passcodeAuthSwitch.isOn = isUsingPasscodeUnlock
    UserDefaults.standard.set(isUsingPasscodeUnlock, forKey: UserDefaultKey.isUsingPasscodeUnlock)
    controller.dismiss(animated: true, completion: nil)
  }
  
  func didSwitchOffBiometrics(_ controller: PasscodeViewController) {
    isUsingBiometricUnlock = false
    biometricAuthSwitch.isOn = isUsingBiometricUnlock
    UserDefaults.standard.set(isUsingBiometricUnlock, forKey: UserDefaultKey.isUsingBiometricUnlock)
    controller.dismiss(animated: true, completion: nil)
  }
  
  func didCancelBiometricsOff(_ controller: PasscodeViewController) {
    isUsingBiometricUnlock = true
    biometricAuthSwitch.isOn = isUsingBiometricUnlock
    UserDefaults.standard.set(isUsingBiometricUnlock, forKey: UserDefaultKey.isUsingBiometricUnlock)
    controller.dismiss(animated: true, completion: nil)
  }
}
