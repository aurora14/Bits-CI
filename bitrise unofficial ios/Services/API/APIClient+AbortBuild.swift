//
//  APIClient+AbortBuild.swift
//  bitrise unofficial ios
//
//  Created by Alexei Gudimenko on 3/10/18.
//  Copyright © 2018 Alexei Gudimenko. All rights reserved.
//

import Foundation
import Alamofire

// MARK: - Abort build
extension APIClient {
  
  func abortBuild(for buildID: Slug, inApp bitriseAppID: Slug,
                  withParams abortParams: AbortBuildParams, then: @escaping () -> Void) {
    
    // ensure user is authorized
    guard let token = App.sharedInstance.getBitriseAuthToken() else {
      then()
      return
    }
    
    setAuthHeaders(withToken: token)
    
    let url = apiEndpointURL("\(Endpoint.apps.rawValue)/\(bitriseAppID)/builds/\(buildID)/abort")
    
    print("Abort PARAMS: \(url) \(token) \(buildID) \(bitriseAppID)")
    
    // Encode build params data
    var requestBody: Data
    do {
      requestBody = try encoder.encode(abortParams)
    } catch let error {
      print(error.localizedDescription)
      then()
      return
    }
    
    // Create a custom request
    var abortRequest = URLRequest(url: url)
    abortRequest.httpMethod = HTTPMethod.post.rawValue
    abortRequest.setValue(token, forHTTPHeaderField: "Authorization")
    abortRequest.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
    abortRequest.httpBody = requestBody
    
    let queue = DispatchQueue.global(qos: .background)
    
    BRSessionManager.shared.background.request(abortRequest)
      .validate()
      .responseJSON(queue: queue) { response in
        
        switch response.result {
        case .success:
          print("*** API Client MSG: build aborted successfully")
          then()
        case .failure(let error):
          print("*** API Client MSG: build abort op FAIL: \(error.localizedDescription)")
          if let data = response.data {
            do {
              let response = try self.decoder.decode(AbortErrorResponse.self, from: data)
              print(response.errorMsg)
              then()
            } catch {
              then()
            }
          }
          then()
        }
    }
    //then()
  }
}
