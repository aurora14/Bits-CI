//
//  SettingsVC.swift
//  bitrise unofficial ios
//
//  Created by Alexei Gudimenko on 4/11/18.
//  Copyright © 2018 Alexei Gudimenko. All rights reserved.
//

import UIKit
import LocalAuthentication
import KeychainAccess

class SettingsViewController: UITableViewController {
  
  // TODO: - add label IBOutlets and config methods to handle localization
  
  // Auth controls
  @IBOutlet weak var passcodeAuthSwitch: UISwitch!
  @IBOutlet weak var biometricAuthSwitch: UISwitch!
  
  var isUsingPasscodeUnlock = false
  var isUsingBiometricUnlock = false
  
  // UI Controls
  // @IBOutlet weak var uiThemeSwitch: UISwitch!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    setupUI()
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    setUnlockSwitches()
  }
  
  private func setupUI() {
    setDefaultThemePreference()
    setUnlockSwitches()
  }
  
  @IBAction func didTogglePasscode(_ sender: Any) {
    isUsingPasscodeUnlock = passcodeAuthSwitch.isOn
    UserDefaults.standard.set(isUsingPasscodeUnlock, forKey: L10n.isUsingPasscodeUnlock)
    
    if isUsingPasscodeUnlock {
      perform(segue: StoryboardSegue.Main.setupPasscodeSegue)
    } else {
      perform(segue: StoryboardSegue.Main.switchOffPasscodeSegue)
    }
    /*
     Note: for simplicity we're using UserDefaults for passcode unlock. In theory this
     is insecure since it means only a boolean value in a relatively public dataset
     is controlling code access. However this feature is designed primarily to protect
     from physical access, so for now it's enough to shield your content from prying eyes.
     
     Furthermore, if you want to secure the actual electronic access to your projects, or
     enforce a stronger security for any case in general, you should use Bitrise's personal
     access tokens with an expiry time.
    */
  }
  
  @IBAction func didToggleBiometrics(_ sender: Any) {
    isUsingBiometricUnlock = biometricAuthSwitch.isOn
    UserDefaults.standard.set(isUsingBiometricUnlock, forKey: L10n.isUsingBiometricUnlock)
  }
  
  // MARK: - navigation
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    
    if let passcodeController = segue.destination as? PasscodeViewController {
      passcodeController.delegate = self
      passcodeController.isUsingBiometrics = isUsingBiometricUnlock
      
      switch segue.identifier {
      case StoryboardSegue.Main.setupPasscodeSegue.rawValue:
        guard segue.destination is PasscodeViewController else {
          assertionFailure("Setup Passcode Segue isn't pointing to an instance of Passcode View Controller")
          return
        }
        passcodeController.userFlow = .settingUp
        passcodeController.userActionText = L10n.enterNewPasscode
      case StoryboardSegue.Main.resetPasscodeSegue.rawValue:
        guard segue.destination is PasscodeViewController else {
          assertionFailure("Reset Passcode Segue isn't pointing to an instance of Passcode View Controller")
          return
        }
        passcodeController.userFlow = .resetting
        passcodeController.userActionText = L10n.enterCurrentPasscode
      case StoryboardSegue.Main.switchOffPasscodeSegue.rawValue:
        guard segue.destination is PasscodeViewController else {
          assertionFailure("Switch Off Passcode Segue isn't pointing to an instance of Passcode View Controller")
          return
        }
        passcodeController.userFlow = .switchingOff
        passcodeController.userActionText = L10n.enterCurrentPasscode
      default:
        ()
      }
    }
    
  }
}

// MARK: - Table view datasource
extension SettingsViewController {
  
  private var infoSection: Int {
    return 1
  }
  
  override func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
    
    switch section {
    case infoSection:
      return createInfoView()
    default: return UIView(frame: .zero)
    }
  }
  
  override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
    switch section {
    case infoSection:
      return 56
    default: return 0
    }
  }
  
  private func createInfoView() -> UIView {
    
    let bundle = Bundle.main
    
    let view = UIView(frame: CGRect(x: 16, y: 0, width: tableView.frame.width, height: 56))
    let label = UILabel(frame: view.frame)
    
    guard let versionNumber = bundle.appVersionNumber else {
      return UIView()
    }
    
    guard let buildNumber = bundle.buildVersionNumber else {
      return UIView()
    }
    
    let appVersion = "App version: \(versionNumber).\(buildNumber)"
    
    label.font = UIFont.systemFont(ofSize: 12, weight: .light)
    label.text = appVersion
    
    view.addSubview(label)
    
    return view
  }
  
}

// MARK: - Table view delegate
extension SettingsViewController {
  
  override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    tableView.deselectRow(at: indexPath, animated: true)
    
    switch (indexPath.section, indexPath.row) {
    case (0, 2):
      print("Reset Passcode row tapped")
      perform(segue: StoryboardSegue.Main.resetPasscodeSegue)
    default:
      print("Settings VC row tapped")
    }
  }
}

// MARK: - Switches
extension SettingsViewController {
  
  fileprivate func setDefaultThemePreference() {
    let defaults = UserDefaults.standard
    defaults.set(false, forKey: L10n.isDarkThemeSelected)
  }
  
  fileprivate func setUnlockSwitches() {
    isUsingPasscodeUnlock = UserDefaults.standard.bool(forKey: L10n.isUsingPasscodeUnlock)
    isUsingBiometricUnlock = UserDefaults.standard.bool(forKey: L10n.isUsingBiometricUnlock)
    
    passcodeAuthSwitch.isOn = isUsingPasscodeUnlock
    
    // only allow biometrics if a passcode has been set
    biometricAuthSwitch.isEnabled = isUsingPasscodeUnlock
    biometricAuthSwitch.isOn = isUsingPasscodeUnlock && isUsingBiometricUnlock
  }
//  @IBAction func didSwitchThemes(_ sender: UISwitch) {
//    let userDefaults = UserDefaults.standard
//    uiThemeSwitch.isOn.toggle()
//    userDefaults.set(uiThemeSwitch.isOn, forKey: L10n.isDarkThemeSelected)
//    App.sharedInstance.setDarkThemeActive(uiThemeSwitch.isOn)
//    print("Dark theme is on: \(uiThemeSwitch.isOn)")
//  }
  
}


extension SettingsViewController: PasscodeViewControllerDelegate {
  
  func didCompletePasscodeSetup(_ controller: PasscodeViewController) {
    UserDefaults.standard.set(true, forKey: L10n.isUsingPasscodeUnlock)
    // TODO: - Configuration once a passcode has been set:
    // 1. Enable biometric switch to allow users to use touch and face ID if they so wish
    // 2.
    controller.dismiss(animated: true, completion: nil)
  }
  
  func didCancelPasscodeSetup(_ controller: PasscodeViewController) {
    
    controller.dismiss(animated: true, completion: nil)
  }
  
  func didUnlock(_ controller: PasscodeViewController, withAuthorizationOfType authorizationType: AppUnlockAuthorizationType) {
    
    controller.dismiss(animated: true, completion: nil)
  }
  
  func didSwitchOffPasscode(_ controller: PasscodeViewController) {
    UserDefaults.standard.set(false, forKey: L10n.isUsingPasscodeUnlock)
    UserDefaults.standard.set(false, forKey: L10n.isUsingBiometricUnlock)
    // setUnlockSwitches() // this call might not be necessary, since it's invoked in viewWillAppear.
    // However if issues are experienced, try using it 
    controller.dismiss(animated: true, completion: nil)
  }
  
}
