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
  
  let keychain = App.sharedInstance.keychain
  
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
    // TODO: - The logic in the two lines below should be moved to the delegate method to avoid
    // doubling up on states. Then if it doesn't activate correctly, the issue would simply be
    // that the delegate method wasn't called in the right place, making it easier to debug.
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
    
    if isUsingBiometricUnlock {
      // If the bio lock is already on, toggling the switch will turn it off after asking for passcode
      let passcodeController = StoryboardScene.Main.passcodeViewController.instantiate()
      passcodeController.userFlow = .switchingOffBiometrics
      passcodeController.userActionText = L10n.enterYourPasscode
      present(passcodeController, animated: true, completion: nil)
    } else {
      // No passcode is required for switching the bio on
    }
    
    isUsingBiometricUnlock = biometricAuthSwitch.isOn
    UserDefaults.standard.set(isUsingBiometricUnlock, forKey: L10n.isUsingBiometricUnlock)
  }
  
  // MARK: - navigation
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    
    /*
     These scenarios handle following cases for presenting PasscodeVC using segues:
     - setup
     - reset
     - switch off
     
     In other cases the PasscodeVC is presented modally using the present(animated:completion:) method.
     These cases are:
     - unlock app
     - switch off biometrics
     
     Unlocking is presented in this way because the user could background the app from any screen,
     and secondly, because PasscodeVC needs to be able to be presented at any time from any place
     that it's required.
     
     Biometrics is presented to avoid additional boilerplate and to keep the storyboard clean.
     This may be changed in the future.
     */
    
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
    
    // this is something of a fragile implementation, should the passcode rows ever change.
    //
    switch (indexPath.section, indexPath.row) {
    case (0, 2):
      print("Passcode timeout row tapped")
      presentTimeoutOptions()
    case (0, 3):
      print("Reset Passcode row tapped")
      do {
        guard let _ = try keychain.get(UserDefaultKey.passcodeUnlockKey) else {
          print("No previously stored passcodes. Aborting... ")
          return
        }
        perform(segue: StoryboardSegue.Main.resetPasscodeSegue)
      } catch let error {
        print("Settings VC Keychain Err: \(error.localizedDescription)")
      }
      
    default:
      print("Settings VC row tapped")
    }
  }
  
  override func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
    switch (indexPath.section, indexPath.row) {
    case (0, 2), (0, 3):
      if UserDefaults.standard.bool(forKey: UserDefaultKey.isUsingPasscodeUnlock) {
        return indexPath
      } else {
        return nil
      }
    default:
      return indexPath
    }
  }
  
  
  private func presentTimeoutOptions() {
    
    let optionsController = UIAlertController(
      title: "Set time to elapse before locking",
      message: nil,
      preferredStyle: .actionSheet)
    
    optionsController.view.tintColor = Asset.Colors.bitriseGreen.color
    
    let always = UIAlertAction(title: PasscodeTimeoutDuration.always.title, style: .default, handler: { _ in
      self.saveTimeoutSelection(isEnabled: false, forDuration: PasscodeTimeoutDuration.always)
      UserDefaults.standard.set(false, forKey: UserDefaultKey.isPasscodeTimeoutEnabled)
      UserDefaults.standard.set(PasscodeTimeoutDuration.always.rawValue, forKey: UserDefaultKey.passcodeTimeoutValue)
      self.timeoutLabelText = "OFF"
    })
    
    let oneMinute = UIAlertAction(title: PasscodeTimeoutDuration.one.title, style: .default, handler: { _ in
      self.saveTimeoutSelection(isEnabled: true, forDuration: PasscodeTimeoutDuration.one)
    })
    
    let fiveMinutes = UIAlertAction(title: PasscodeTimeoutDuration.five.title, style: .default, handler: { _ in
      self.saveTimeoutSelection(isEnabled: true, forDuration: PasscodeTimeoutDuration.five)
    })
    
    let fifteenMinutes = UIAlertAction(title: PasscodeTimeoutDuration.fifteen.title, style: .default, handler: { _ in
      self.saveTimeoutSelection(isEnabled: true, forDuration: PasscodeTimeoutDuration.fifteen)
    })
    
    let sixtyMinutes = UIAlertAction(title: PasscodeTimeoutDuration.sixty.title, style: .default, handler: { _ in
      self.saveTimeoutSelection(isEnabled: true, forDuration: PasscodeTimeoutDuration.sixty)
    })
    
    let cancelAction = UIAlertAction(title: L10n.cancel, style: .cancel, handler: nil)
    
    optionsController.addAction(always)
    optionsController.addAction(oneMinute)
    optionsController.addAction(fiveMinutes)
    optionsController.addAction(fifteenMinutes)
    optionsController.addAction(sixtyMinutes)
    optionsController.addAction(cancelAction)
    
    present(optionsController, animated: true, completion: {
      
    })
  }
  
  private func saveTimeoutSelection(isEnabled flag: Bool, forDuration duration: PasscodeTimeoutDuration) {
    UserDefaults.standard.set(flag, forKey: UserDefaultKey.isPasscodeTimeoutEnabled)
    UserDefaults.standard.set(duration.rawValue, forKey: UserDefaultKey.passcodeTimeoutValue)
    if duration == .always {
      timeoutLabelText = "OFF"
    } else {
      timeoutLabelText = duration.title
    }
  }
}

// MARK: - Switches & Helpers
extension SettingsViewController {
  
  fileprivate func setLocalisedTitles() {
    title = L10n.settingsTitle
    unlockWithPasscodeLabel.text = L10n.unlockWithPasscode
    unlockWithBiometricsLabel.text = L10n.unlockWithBio
    passcodeGracePeriodLabel.text = L10n.setGracePeriod
    resetPasscodeLabel.text = L10n.resetPasscode
    acknowledgementsLabel.text = L10n.acknowledgements
  }
  
  fileprivate func setDefaultThemePreference() {
    let defaults = UserDefaults.standard
    defaults.set(false, forKey: UserDefaultKey.isDarkThemeSelected)
  }
  
  func setUnlockSwitches() {
    isUsingPasscodeUnlock = UserDefaults.standard.bool(forKey: UserDefaultKey.isUsingPasscodeUnlock)
    passcodeAuthSwitch.isOn = isUsingPasscodeUnlock
    
    // only allow biometrics if a passcode has been set
    biometricAuthSwitch.isEnabled = isUsingPasscodeUnlock
    biometricAuthSwitch.isOn = isUsingPasscodeUnlock && isUsingBiometricUnlock
  }
  
  func setupResetAndGraceRows() {
    let timeoutIndexPath = IndexPath(row: 2, section: 0)
    let resetIndexPath = IndexPath(row: 3, section: 0)
    
    let timeoutCell = tableView.cellForRow(at: timeoutIndexPath)
    let resetCell = tableView.cellForRow(at: resetIndexPath)
    
    if UserDefaults.standard.bool(forKey: UserDefaultKey.isUsingPasscodeUnlock) {
      resetCell?.selectionStyle = .default
      resetPasscodeLabel.textColor = Asset.Colors.bitriseGreen.color
      
      timeoutCell?.selectionStyle = .default
      passcodeGracePeriodLabel.textColor = Asset.Colors.bitrisePurple.color
    } else {
      resetCell?.selectionStyle = .none
      resetPasscodeLabel.textColor = UIColor.lightGray
      
      timeoutCell?.selectionStyle = .none
      passcodeGracePeriodLabel.textColor = UIColor.lightGray
    }
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
  
  func didUnlock(_ controller: PasscodeViewController,
                 withAuthorizationOfType authorizationType: AppUnlockAuthorizationType) {
    
    controller.dismiss(animated: true, completion: nil)
  }
  
  func didSwitchOffPasscode(_ controller: PasscodeViewController) {
    UserDefaults.standard.set(false, forKey: L10n.isUsingPasscodeUnlock)
    UserDefaults.standard.set(false, forKey: L10n.isUsingBiometricUnlock)
    // setUnlockSwitches() // this call might not be necessary, since it's invoked in viewWillAppear.
    // However if issues are experienced, try using it 
    controller.dismiss(animated: true, completion: nil)
  }
  
  func didCancelPasscodeOff(_ controller: PasscodeViewController) {
    isUsingPasscodeUnlock = true
    passcodeAuthSwitch.isOn = isUsingPasscodeUnlock
    UserDefaults.standard.set(isUsingPasscodeUnlock, forKey: L10n.isUsingPasscodeUnlock)
    controller.dismiss(animated: true, completion: nil)
  }
  
  func didSwitchOffBiometrics(_ controller: PasscodeViewController) {
    isUsingBiometricUnlock = false
    biometricAuthSwitch.isOn = isUsingBiometricUnlock
    UserDefaults.standard.set(isUsingBiometricUnlock, forKey: L10n.isUsingBiometricUnlock)
    controller.dismiss(animated: true, completion: nil)
  }
  
  func didCancelBiometricsOff(_ controller: PasscodeViewController) {
    isUsingBiometricUnlock = true
    biometricAuthSwitch.isOn = isUsingBiometricUnlock
    UserDefaults.standard.set(isUsingBiometricUnlock, forKey: L10n.isUsingBiometricUnlock)
    controller.dismiss(animated: true, completion: nil)
  }
}
