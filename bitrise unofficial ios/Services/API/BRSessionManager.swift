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
  
  private init() { }
  
  private func _httpSessionManager() -> Alamofire.SessionManager {
    
    // Create custom manager
    let configuration = URLSessionConfiguration
      .background(withIdentifier: "com.gudimenko.alexei.bitrise-unofficial-ios")
    configuration.httpAdditionalHeaders = Alamofire.SessionManager.defaultHTTPHeaders
    let manager = Alamofire.SessionManager(
      configuration: configuration
      //serverTrustPolicyManager: ServerTrustPolicyManager(policies: serverTrustPolicies)
    )
    
    return manager
  }
  
  public var httpSessionManager: Alamofire.SessionManager {
    return _httpSessionManager()
  }
}
