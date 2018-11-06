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
  
  private func setupUI() {
    setDefaultThemePreference()
  }
  
  @IBAction func didTogglePasscode(_ sender: Any) {
    isUsingPasscodeUnlock = passcodeAuthSwitch.isOn
    UserDefaults.standard.set(isUsingPasscodeUnlock, forKey: L10n.isUsingPasscodeUnlock)
    
    if isUsingPasscodeUnlock {
      
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
  
//  @IBAction func didSwitchThemes(_ sender: UISwitch) {
//    let userDefaults = UserDefaults.standard
//    uiThemeSwitch.isOn.toggle()
//    userDefaults.set(uiThemeSwitch.isOn, forKey: L10n.isDarkThemeSelected)
//    App.sharedInstance.setDarkThemeActive(uiThemeSwitch.isOn)
//    print("Dark theme is on: \(uiThemeSwitch.isOn)")
//  }
  
}
