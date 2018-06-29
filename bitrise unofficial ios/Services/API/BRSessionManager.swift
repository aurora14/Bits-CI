//
//  BRSessionManager.swift
//  bitrise unofficial ios
//
//  Created by Alexei Gudimenko on 18/6/18.
//  Copyright © 2018 Alexei Gudimenko. All rights reserved.
//


import Foundation
import Alamofire

class BRSessionManager {
  
  
  static let shared = BRSessionManager()
  
  public var background: Alamofire.SessionManager
  
  
  private init() {
    
    let configuration = URLSessionConfiguration
      .background(withIdentifier: "com.gudimenko.alexei.bitrise-unofficial-ios")
    
    configuration.httpAdditionalHeaders = Alamofire.SessionManager.defaultHTTPHeaders
    
    background = Alamofire.SessionManager(configuration: configuration)
  }

}
