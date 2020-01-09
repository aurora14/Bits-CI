//
//  AppDelegate.swift
//  bitrise unofficial ios
//
//  Created by Alexei Gudimenko on 12/6/18.
//  Copyright © 2018 Alexei Gudimenko. All rights reserved.
//


import UIKit

@UIApplicationMain
final class AppDelegate: UIResponder, UIApplicationDelegate {

  var window: UIWindow?

  func application(_ application: UIApplication, didFinishLaunchingWithOptions
    launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
    
    // Override point for customization after application launch.
    initUITheme()
    initNetworkUtils()
    initUserInterfaceUtils()
    initReportingUtils()
    
    return true
  }

  func applicationWillResignActive(_ application: UIApplication) {
    recordTimeWhenMovedToBackground()
  }

  func applicationDidBecomeActive(_ application: UIApplication) {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    
    unlockIfNecessary()
  }
}
