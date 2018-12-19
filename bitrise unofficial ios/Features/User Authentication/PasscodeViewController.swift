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

/// Describes potential user actions in relation to passcode and biometrics protection.
/// Specify one of these when presenting the Passcode View Controller
///
/// - settingUp: <#settingUp description#>
/// - resetting: <#resetting description#>
/// - unlocking: <#unlocking description#>
/// - switchingOff: <#switchingOff description#>
/// - switchingOffBiometrics: <#switchingOffBiometrics description#>
enum PasscodeUserFlow {
  /// <#Description#>
  case settingUp
  /// <#Description#>
  case resetting
  /// <#Description#>
  case unlocking
  /// <#Description#>
  case switchingOff
  /// <#Description#>
  case switchingOffBiometrics
}

protocol PasscodeViewControllerDelegate: class {
  func didCompletePasscodeSetup(_ controller: PasscodeViewController)
  func didCancelPasscodeSetup(_ controller: PasscodeViewController)
  func didUnlock(_ controller: PasscodeViewController,
                 withAuthorizationOfType authorizationType: AppUnlockAuthorizationType)
  func didSwitchOffPasscode(_ controller: PasscodeViewController)
  func didCancelPasscodeOff(_ controller: PasscodeViewController)
  func didSwitchOffBiometrics(_ controller: PasscodeViewController)
  func didCancelBiometricsOff(_ controller: PasscodeViewController)
}

class PasscodeViewController: UIViewController {
  
  @IBOutlet weak var dismissButton: UIButton!
  
  weak var delegate: PasscodeViewControllerDelegate?
  
  private var notificationFeedbackGenerator = UINotificationFeedbackGenerator()
  private var impactFeedbackGenerator = UIImpactFeedbackGenerator()
  
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
  
  let keychain = App.sharedInstance.keychain
  //let passcodeUnlockKey = "PasscodeUnlockKey"
  
  /// Length of the passcode
  let kPasscodeDigit = 6
  
  var isUsingBiometrics = false
  /// Use this as a temporary store for the first time the user enters the passcode, for example during first-time setup or when they are resetting the passcode to something new. When the user enters the new passcode a second time, that value will be matched against the temporary store.
  var passcodeToMatch = ""
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    // Do any additional setup after loading the view.
    modalPresentationStyle = .overCurrentContext
    
    notificationFeedbackGenerator.prepare()
    impactFeedbackGenerator.prepare()
    
    createPasscodeView()
    createUserActionLabel(withTitle: userActionText)
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    
    if userFlow == .resetting || userFlow == .settingUp {
      passcodeContainerView?.touchAuthenticationEnabled = false
    }
    
    // don't give user the option to cancel if they must enter passcode or biometrics
    if userFlow == .unlocking {
      dismissButton.isHidden = true
    }
  }
  
  @IBAction func didTapCancel(_ sender: Any) {
    
    // First two cases handle switching off existing setup.
    // Default currently handles setup case, when no passcode exists in the system
    
    switch userFlow {
    case .switchingOffBiometrics:
      delegate?.didCancelBiometricsOff(self)
    case .switchingOff:
      delegate?.didCancelPasscodeOff(self)
    default:
      do {
        // If user cancels entry and one of the following is true:
        // 1. - There IS a stored value in the keychain under 'passcode unlock key' but it's an empty string
        // 2. - There isn't a stored value in the keychain under this passcode
        // then
        if let storedPasscode = try keychain.get(UserDefaultKey.passcodeUnlockKey) {
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
    
  }
  
  private func createPasscodeView() {
    
    passcodeContainerView = PasswordContainerView.create(withDigit: kPasscodeDigit)
    passcodeContainerView?.delegate = self
    passcodeContainerView?.deleteButtonLocalizedTitle = L10n.deletePasscodeCharacter
    
    passcodeContainerView?.tintColor = Asset.Colors.bitriseGreen.color
    passcodeContainerView?.highlightedColor = Asset.Colors.bitrisePurple.color
    
    passcodeContainerView?.touchAuthenticationEnabled =
      isUsingBiometrics || UserDefaults.standard.bool(forKey: UserDefaultKey.isUsingBiometricUnlock)
    
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
    UserDefaults.standard.set(false, forKey: UserDefaultKey.isUsingPasscodeUnlock)
    UserDefaults.standard.set(false, forKey: UserDefaultKey.isUsingBiometricUnlock)
  }
  
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
    case .switchingOffBiometrics:
      performSwitchOffBiometricFlow(in: passwordContainerView, withCode: input)
    }
  }
  
  func touchAuthenticationComplete(_ passwordContainerView: PasswordContainerView, success: Bool, error: Error?) {
    
    guard error == nil else {
      print(error?.localizedDescription ?? "Biometric auth error")
      return
    }
    
    if success {
      switch userFlow {
      case .switchingOffBiometrics:
        delegate?.didSwitchOffBiometrics(self)
      default:
        delegate?.didUnlock(self, withAuthorizationOfType: .biometric)
        if delegate == nil {
          dismiss(animated: true, completion: nil)
        }
        
      }
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
      impactFeedbackGenerator.impactOccurred()
      userActionLabel?.text = L10n.reenterNewPasscode
    } else if input == passcodeToMatch {
      // Second time entering password, first and second input attempts match
      do {
        try keychain
          .label("App Unlock Passcode")
          .comment("Authorization value for accessing Bitrise.io API")
          .synchronizable(true)
          .accessibility(.afterFirstUnlock)
          .set(input, key: UserDefaultKey.passcodeUnlockKey)
        notificationFeedbackGenerator.notificationOccurred(.success)
        delegate?.didCompletePasscodeSetup(self)
      } catch let error {
        assertionFailure("Error saving passcode to keychain: \(error.localizedDescription)")
        Answers.logCustomEvent(withName: "Passcode Saving error",
                               customAttributes: ["Error Value": "\(error.localizedDescription)"])
        // TODO: - present an error, instructing to contact support
      }
    } else {
      notificationFeedbackGenerator.notificationOccurred(.error)
      passwordContainerView.wrongPassword()
    }
  }
  
  fileprivate func performResetFlow(in passwordContainerView: PasswordContainerView, withCode input: String) {
    // 1. Check the input against the stored passcode
    // 2. If the passcode is correct, clear input and proceed to the 'setup' workflow
    // 3. Otherwise present 'invalid' option. User can re-enter or cancel
    
    guard let storedPasscode = validateStoredPasscode(in: passwordContainerView) else {
      return
    }
    
    if storedPasscode == input {
      notificationFeedbackGenerator.notificationOccurred(.success)
      passwordContainerView.clearInput()
      userActionText = L10n.enterNewPasscode
      userFlow = .settingUp
    } else {
      notificationFeedbackGenerator.notificationOccurred(.error)
      passwordContainerView.wrongPassword()
    }
  }
  
  fileprivate func performUnlockFlow(in passwordContainerView: PasswordContainerView, withCode input: String) {
    // 1. Check the input against the stored passcode
    // 2. If the passcode is correct, dismiss the controller. If lock-after-inactive-period is enabled,
    //    update the stored time.
    //    Note that if lock is activated with no time, the passcode screen will always show when user
    //    launches the app.
    // 3. Otherwise present 'invalid' option. User can re-enter or cancel
    
    guard let storedPasscode = validateStoredPasscode(in: passwordContainerView) else {
      return
    }
    
    if storedPasscode == input {
      notificationFeedbackGenerator.notificationOccurred(.success)
      delegate?.didUnlock(self, withAuthorizationOfType: .passcode)
      if delegate == nil {
        dismiss(animated: true, completion: nil)
      }
    } else {
      notificationFeedbackGenerator.notificationOccurred(.error)
      passwordContainerView.wrongPassword()
    }
  }
  
  fileprivate func performSwitchOffFlow(in passwordContainerView: PasswordContainerView, withCode input: String) {
    
    guard let storedPasscode = validateStoredPasscode(in: passwordContainerView) else {
      return
    }
    
    // 1. Check the input against the stored passcode.
    if storedPasscode == input {
      do {
        try keychain.remove(UserDefaultKey.passcodeUnlockKey)
        notificationFeedbackGenerator.notificationOccurred(.success)
      } catch let error {
        notificationFeedbackGenerator.notificationOccurred(.error)
        assertionFailure("Error removing passcode: \(error.localizedDescription)")
        userActionText = "Couldn't remove passcode"
        return
      }
      delegate?.didSwitchOffPasscode(self)
    } else {
      notificationFeedbackGenerator.notificationOccurred(.error)
      passwordContainerView.wrongPassword()
    }
  }
  
  fileprivate func performSwitchOffBiometricFlow(in passwordContainerView: PasswordContainerView,
                                                 withCode input: String) {
    
    guard let storedPasscode = validateStoredPasscode(in: passwordContainerView) else {
      return
    }
    
    if storedPasscode == input {
      notificationFeedbackGenerator.notificationOccurred(.success)
      delegate?.didSwitchOffBiometrics(self)
    } else {
      notificationFeedbackGenerator.notificationOccurred(.error)
      passwordContainerView.wrongPassword()
    }
  }
  
  private typealias PasscodeString = String
  
  private func validateStoredPasscode(in passwordContainerView: PasswordContainerView) -> PasscodeString? {
    do {
      guard let storedPasscode = try keychain.get(UserDefaultKey.passcodeUnlockKey) else {
        print("No previously stored passcodes. Aborting...")
        passwordContainerView.wrongPassword()
        notificationFeedbackGenerator.notificationOccurred(.error)
        return nil
      }
      
      return storedPasscode
      
    } catch let error {
      notificationFeedbackGenerator.notificationOccurred(.error)
      assertionFailure("Key op error:  \(error.localizedDescription)")
      return nil
    }
  }
}
