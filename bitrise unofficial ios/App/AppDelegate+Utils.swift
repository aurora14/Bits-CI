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
import SwiftDate


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
    App.sharedInstance.setDarkThemeActive(UserDefaults.standard.bool(forKey: UserDefaultKey.isDarkThemeSelected))
  }
  
}


// MARK: - Locking mechanisms
extension AppDelegate {
  
  func recordTimeWhenMovedToBackground() {
    let currentTime = Date()
    let currentTimeAsDate = Date()
    print("Date version: \(currentTimeAsDate)")
    print("String version: \(currentTime)")
    UserDefaults.standard.set("\(currentTime)", forKey: UserDefaultKey.backgroundTimeValue)
  }
  
  func unlockIfNecessary() {
    
    guard let controller = UIApplication.topViewController() else {
      return
    }
    
    if UserDefaults.standard.bool(forKey: UserDefaultKey.isUsingPasscodeUnlock) {
      
      let presentPasscodeController = {
        let passcodeController = StoryboardScene.Main.passcodeViewController.instantiate()
        passcodeController.userFlow = .unlocking
        passcodeController.userActionText = L10n.enterYourPasscode
        //passcodeController.delegate = ... //TODO: - assign delegate
        controller.present(passcodeController, animated: true, completion: nil)
      }
      
      // Discussion: it may not be necessary to assign a delegate here, since on successful unlock
      // the app merely dismisses the passcode controller. In other words, it doesn't modify state
      // of any locking mechanisms.
      
      let isTimeoutEnabled = UserDefaults.standard.bool(forKey: UserDefaultKey.isPasscodeTimeoutEnabled)
      
      if !isTimeoutEnabled || isTimeoutEnabled && isInactivityTimeoutReached() {
        presentPasscodeController()
      }
    }
    
  }
  
  
  /// <#Description#>
  ///
  /// The inactivity timeout is assumed reached in the following cases:
  /// - if the time between app being put in background and time resumed is greater than an hour
  /// - if "always" was selected
  /// - if the app cannot infer one of the saved values for some reason
  ///
  /// - Returns: <#return value description#>
  private func isInactivityTimeoutReached() -> Bool {

    let timeoutDurationValue = UserDefaults.standard.integer(forKey: UserDefaultKey.passcodeTimeoutValue)
    
    let timeoutDuration = PasscodeTimeoutDuration(rawValue: timeoutDurationValue) ?? .always
    
    switch timeoutDuration {
    case .one, .five, .fifteen, .sixty:
      // if difference is equal or greater than timeout setting, return true - timeout reached.
      
      let timeStringMovedIntoBackground =
        UserDefaults.standard.string(forKey: UserDefaultKey.backgroundTimeValue) ?? ""
      
      // fixme: - fails to init date due to format
      let formatter = DateFormatter()
      formatter.dateFormat = "yyyy-MM-dd HH:mm:ss Z"
      let timeToBackground = formatter.date(from: timeStringMovedIntoBackground) ?? Date()
      
      let timeResumed = Date()
      
      // 1. Get the value of the difference between background and resumption
      let difference = timeResumed - timeToBackground
      
      let year = abs(difference.year ?? 0)
      let month = abs(difference.month ?? 0)
      let week = abs(difference.weekOfMonth ?? 0)
      let day = abs(difference.day ?? 0)
      let hour = abs(difference.hour ?? 0)
      let minute = abs(difference.minute ?? 0)
      
      print("""
        > Time Background String: \(timeStringMovedIntoBackground)
        
        > Time to background: \(timeToBackground)
        > Time resumed: \(timeResumed)
        > Difference: \(difference)
        
        > Recorded time difference between background and foreground:
        - year:   \(year)
        - month:  \(month)
        - week:   \(week)
        - day:    \(day)
        - hour:   \(hour)
        - minute: \(minute)
      """)
      
      guard year == 0, month == 0, week == 0, day == 0, hour < 1, minute < timeoutDurationValue else {
        // if any of these are greater than 0, then it's guaranteed to be above 60 minutes, so always invoke passcode screen. The 'hour' value cannot be greater than one, - otherwise the same rule applies.
        return true
      }
      
      return false

    case .always:
      return true
    }

  }
  
}
