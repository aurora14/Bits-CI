//
//  bitrise_unofficial_ios_UITests.swift
//  bitrise unofficial ios UITests
//
//  Created by Alexei Gudimenko on 22/1/19.
//  Copyright © 2019 Alexei Gudimenko. All rights reserved.
//

import XCTest

class bitrise_unofficial_ios_UITests: XCTestCase {

  private var bitriseAccessToken = "_mKUAC8GWcfaYwudvSVPZi0SZwZAjc-ibBtjPSVr4Fmg4UMf0uh-W0chiby4xbTWZYHxZyKb0eTEhy_tScZ-kA"
  
  var application: XCUIApplication!
  
  override func setUp() {
    super.setUp()
    // Put setup code here. This method is called before the invocation of each test method in the class.
    
    // In UI tests it is usually best to stop immediately when a failure occurs.
    continueAfterFailure = false
    
    // UI tests must launch the application that they test. Doing this in setup will make sure it happens for each test method.
    // XCUIApplication().launch()
    application = XCUIApplication()
    
    application.launchArguments.append("--uitesting")
  }
  
  override func tearDown() {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
  }
  
  func testPasscodeViewPresentation() {
    application.launch()
    
    XCTAssertTrue(application.isPresentingPasscodeView)
    
    application.buttons["Close"].tap()
    
    XCTAssertFalse(application.isPresentingPasscodeView)
  }
}

extension XCUIApplication {
  
  var isPresentingPasscodeView: Bool {
    return otherElements["passcodeView"].exists
  }
}
