//
//  PasscodeViewController.swift
//  bitrise unofficial ios
//
//  Created by Alexei Gudimenko on 5/11/18.
//  Copyright © 2018 Alexei Gudimenko. All rights reserved.
//

import UIKit
import KeychainAccess
import Fabric
import Crashlytics

enum AppUnlockAuthorizationType {
  case passcode, biometric
}

enum PasscodeUserFlow {
  case settingUp, resetting, unlocking, switchingOff
}

protocol PasscodeViewControllerDelegate: class {
  func didCompletePasscodeSetup(_ controller: PasscodeViewController)
  func didCancelPasscodeSetup(_ controller: PasscodeViewController)
  func didUnlock(_ controller: PasscodeViewController,
                 withAuthorizationOfType authorizationType: AppUnlockAuthorizationType)
  func didSwitchOffPasscode(_ controller: PasscodeViewController)
}

class PasscodeViewController: UIViewController {
  
  // TODO: - Manage states: is the user entering a passcode for the first time?
  // - first-time setup: show VC, enter password once, re-enter password, on successful match store p/code & dismiss VC.
  // - resetting passcode: show VC, enter old, enter new, reenter new, on success dismiss
  // -
  
  // TODO: - Consider offloading the flow determination to coordinator. Currently we're
  //         doing too much work in the view controllers. But we'll defer this until the actual code
  //         feature works.
  
  weak var delegate: PasscodeViewControllerDelegate?
  
  var passcodeContainerView: PasswordContainerView?
  fileprivate var userActionLabel: UILabel?
  /// When presenting the Passcode View Controller, use this property to update the text, rather than directly
  /// updating the label.
  var userActionText: String = "" {
    didSet {
      userActionLabel?.text = userActionText
    }
  }
  /// Determines the handling of entered passcode depending on the circumstances it was presented under. Set this
  /// before presenting or navigating to the Passcode View Controller.
  var userFlow: PasscodeUserFlow = .settingUp
  
  let keychain = Keychain(service: "com.gudimenko.alexei.bitrise-unofficial-ios")
  let passcodeUnlockKey = "PasscodeUnlockKey"
  
  /// Length of the passcode
  let kPasscodeDigit = 6
  
  var isUsingBiometrics = false
  /// Use this as a temporary store for the first time the user enters the passcode, for example during first-time setup or when they are resetting the passcode to something new. When the user enters the new passcode a second time, that value will be matched against the temporary store.
  var passcodeToMatch = ""
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    // Do any additional setup after loading the view.
    modalPresentationStyle = .overCurrentContext
    
    createPasscodeView()
    createUserActionLabel(withTitle: userActionText)
  }
  
  @IBAction func didTapCancel(_ sender: Any) {
    do {
      // If user cancels entry and one of the following is true:
      // 1. - There IS a stored value in the keychain under 'passcode unlock key' but it's an empty string
      // 2. - There isn't a stored value in the keychain under this passcode
      // then
      if let storedPasscode = try keychain.get(passcodeUnlockKey) {
        if storedPasscode.isEmpty {
          setUserDefaultLockValuesToOff()
        }
        // Otherwise, the implication is that user defaults state is preserved
      } else {
        setUserDefaultLockValuesToOff()
      }
    } catch let error {
      assertionFailure("Error retrieving passcode: \(error.localizedDescription)")
    }
    delegate?.didCancelPasscodeSetup(self)
  }
  
  private func createPasscodeView() {
    
    passcodeContainerView = PasswordContainerView.create(withDigit: kPasscodeDigit)
    passcodeContainerView?.delegate = self
    passcodeContainerView?.deleteButtonLocalizedTitle = L10n.deletePasscodeCharacter
    
    passcodeContainerView?.tintColor = Asset.Colors.bitriseGreen.color
    passcodeContainerView?.highlightedColor = Asset.Colors.bitrisePurple.color
    
    passcodeContainerView?.touchAuthenticationEnabled =
      isUsingBiometrics || UserDefaults.standard.bool(forKey: L10n.isUsingBiometricUnlock)
    
    guard let v = passcodeContainerView else {
      assertionFailure("Failed to initialise PasswordContainerView instance from NIB")
      return
    }
    
    view.addSubview(v)
    
    let margins = view.layoutMarginsGuide
    
    v.translatesAutoresizingMaskIntoConstraints = false
    
    v.centerXAnchor.constraint(equalTo: margins.centerXAnchor, constant: 0).isActive = true
    v.centerYAnchor.constraint(equalTo: margins.centerYAnchor, constant: 0).isActive = true
    v.widthAnchor.constraint(equalTo: margins.widthAnchor, constant: -48).isActive = true
    
    v.contentMode = .scaleAspectFit
  }
  
  private func createUserActionLabel(withTitle title: String = "") {
    
    userActionLabel = UILabel(frame: .zero)
    
    userActionLabel?.textAlignment = .center
    userActionLabel?.font = UIFont.systemFont(ofSize: 21, weight: .light)
    userActionLabel?.text = title.isEmpty ? "Enter Passcode" : title
    
    guard let l = userActionLabel else {
      assertionFailure("Failed to initialise the title label with frame of zero")
      return
    }
    
    view.addSubview(l)
    
    let margins = view.layoutMarginsGuide
    
    l.translatesAutoresizingMaskIntoConstraints = false
    
    l.centerXAnchor.constraint(equalTo: margins.centerXAnchor, constant: 0).isActive = true
    l.heightAnchor.constraint(equalToConstant: 56).isActive = true
    l.widthAnchor.constraint(equalTo: margins.widthAnchor, constant: -48).isActive = true // equal with passcode container
    
    guard let passcodeView = passcodeContainerView else {
      l.topAnchor.constraint(equalTo: margins.topAnchor, constant: 48).isActive = true
      return
    }
    
    // if passcode view has been properly initialised, pin bottom of the label to the top of the passcode view
    l.bottomAnchor.constraint(equalTo: passcodeView.topAnchor, constant: 0).isActive = true
  }
  
  /// Convenience method for user defaults
  fileprivate func setUserDefaultLockValuesToOff() {
    UserDefaults.standard.set(false, forKey: L10n.isUsingPasscodeUnlock)
    UserDefaults.standard.set(false, forKey: L10n.isUsingBiometricUnlock)
  }
  /*
   // MARK: - Navigation
   
   // In a storyboard-based application, you will often want to do a little preparation before navigation
   override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
   // Get the new view controller using segue.destination.
   // Pass the selected object to the new view controller.
   }
   */
  
}

extension PasscodeViewController: PasswordInputCompleteProtocol {
  
  func passwordInputComplete(_ passwordContainerView: PasswordContainerView, input: String) {
    print("Did call password complete")
    switch userFlow {
    case .settingUp:
      performSetupFlow(in: passwordContainerView, withCode: input)
    case .resetting:
      performResetFlow(in: passwordContainerView, withCode: input)
    case .unlocking:
      performUnlockFlow(in: passwordContainerView, withCode: input)
    case .switchingOff:
      performSwitchOffFlow(in: passwordContainerView, withCode: input)
    }
  }
  
  func touchAuthenticationComplete(_ passwordContainerView: PasswordContainerView, success: Bool, error: Error?) {
    if success {
      delegate?.didUnlock(self, withAuthorizationOfType: .biometric)
      dismiss(animated: true, completion: nil)
    } else {
      passwordContainerView.wrongPassword()
    }
  }
  
}


// MARK: - Passcode flow helpers
extension PasscodeViewController {
  
  fileprivate func performSetupFlow(in passwordContainerView: PasswordContainerView, withCode input: String) {
    if passcodeToMatch.isEmpty {
      // No passcode has been entered yet
      passcodeToMatch = input
      passcodeContainerView?.clearInput()
      userActionLabel?.text = L10n.reenterNewPasscode
    } else if input == passcodeToMatch {
      // Second time entering password, first and second input attempts match
      do {
        try keychain
          .label("App Unlock Passcode")
          .comment("Authorization value for accessing Bitrise.io API")
          .synchronizable(true)
          .accessibility(.afterFirstUnlock)
          .set(input, key: passcodeUnlockKey)
        delegate?.didCompletePasscodeSetup(self)
      } catch let error {
        assertionFailure("Error saving passcode to keychain: \(error.localizedDescription)")
        Answers.logCustomEvent(withName: "Passcode Saving error",
                               customAttributes: ["Error Value": "\(error.localizedDescription)"])
        // TODO: - present an error, instructing to contact support
      }
    } else {
      passwordContainerView.wrongPassword()
    }
  }
  
  fileprivate func performResetFlow(in passwordContainerView: PasswordContainerView, withCode input: String) {
    #warning("Perform Reset Flow: - incomplete or empty implementation. ")
    // 1. Check the input against the stored passcode
    // 2. If the passcode is correct, clear input and proceed to the 'setup' workflow
    // 3. Otherwise present 'invalid' option. User can re-enter or cancel
  }
  
  fileprivate func performUnlockFlow(in passwordContainerView: PasswordContainerView, withCode input: String) {
    // 1. Check the input against the stored passcode
    // 2. If the passcode is correct, dismiss the controller. If lock-after-inactive-period is enabled,
    //    update the stored time.
    //    Note that if lock is activated with no time, the passcode screen will always show when user
    //    launches the app.
    // 3. Otherwise present 'invalid' option. User can re-enter or cancel
    do {
      guard let storedPasscode = try keychain.get(passcodeUnlockKey) else {
        print("No previously stored passcodes. Aborting...")
        return
      }
      if storedPasscode == input {
        delegate?.didUnlock(self, withAuthorizationOfType: .passcode)
        dismiss(animated: true, completion: nil)
      } else {
        passwordContainerView.wrongPassword()
      }
    } catch let error {
      assertionFailure("*** Key op error: \(error.localizedDescription)")
    }
  }
  
  fileprivate func performSwitchOffFlow(in passwordContainerView: PasswordContainerView, withCode input: String) {
    do {
      guard let storedPasscode = try keychain.get(passcodeUnlockKey) else {
        print("No previously stored passcodes. Aborting...")
        return
      }
      // 1. Check the input against the stored passcode.
      if storedPasscode == input {
        // 2. If the passcode is correct - delete the keychain entry. Then set the touch and passcode switches to off. Dismiss the view controller
        try keychain.remove(passcodeUnlockKey)
        delegate?.didSwitchOffPasscode(self)
      } else {
        // 3. If the passcode is incorrect, invoke passwordContainerView.wrongPassword(), and DO NOT update any of the settings
        passwordContainerView.wrongPassword()
      }
    } catch let error {
      assertionFailure("Key op error:  \(error.localizedDescription)")
    }
  }
}
