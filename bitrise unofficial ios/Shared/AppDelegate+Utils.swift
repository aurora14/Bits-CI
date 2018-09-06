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


extension AppDelegate {
  
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
}
