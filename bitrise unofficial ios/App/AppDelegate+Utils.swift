//
//  AppDelegate+Utils.swift
//  bitrise unofficial ios
//
//  Created by Alexei Gudimenko on 30/7/18.
//  Copyright © 2018 Alexei Gudimenko. All rights reserved.
//

import Foundation
import AlamofireNetworkActivityIndicator
import Firebase
import Fabric
import IQKeyboardManagerSwift
import UserNotifications
import UserNotificationsUI


extension AppDelegate: UNUserNotificationCenterDelegate {
  
  /// Any shared Alamofire, Firebase etc
  func initNetworkUtils() {
    NetworkActivityIndicatorManager.shared.isEnabled = true
  }
  
  /// Fabric, Crashlytics and any other analytics tools. Note, call this method last in
  /// your "finishedLaunchingWith(options:)", just before "return true".
  func initReportingUtils() {
    FirebaseApp.configure()
    Fabric.sharedSDK().debug = false
    Fabric.with([Crashlytics.self])
  }
  
  /// Keyboard managers, etc 
  func initUserInterfaceUtils() {
    IQKeyboardManager.shared.enable = true
    IQKeyboardManager.shared.shouldToolbarUsesTextFieldTintColor = true
  }
  
  func initNotificationSettings() {
    
  }
  
  func initUITheme() {
    App.sharedInstance.setDarkThemeActive(UserDefaults.standard.bool(forKey: L10n.isDarkThemeSelected))
  }
  
  func unlockIfNecessary() {
    
    guard let controller = UIApplication.topViewController() else {
      return
    }
    
    if UserDefaults.standard.bool(forKey: L10n.isUsingPasscodeUnlock) {
      
      if isInactivityTimeoutReached() {
        let passcodeController = StoryboardScene.Main.passcodeViewController.instantiate()
        passcodeController.userFlow = .unlocking
        passcodeController.userActionText = L10n.enterYourPasscode
        controller.present(passcodeController, animated: true, completion: nil)
      }
      
    }

  }
  
  private func isInactivityTimeoutReached() -> Bool {
    
    // TODO: - compare the time and record the time difference between the stored 'inactive' time and current time.
    // If the time difference is greater than the set 'timeout' to activate screen lock, handle screen lock presentation
    
    return true
    
  }
  
}
