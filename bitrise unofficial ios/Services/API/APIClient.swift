//
//  APIClient.swift
//  bitrise-unofficial-ios
//
//  Created by Alexei Gudimenko on 13/6/18.
//  Copyright © 2018 Alexei Gudimenko. All rights reserved.
//

import Foundation
import Alamofire
import AlamofireImage

enum Endpoint: String {
  case me
  case apps
}

/// Alphanumeric string ID used by every Bitrise object as its unique ID
typealias Slug = String

// MARK: - Initialization/default config

/// Handles communication with the Bitrise endpoints. Avoid adding state to this. The definition
/// should not be modified.
/// This class acts as a wrapper for typical Alamofire requests, allowing specification of
/// parameters and completion handlers. It also defines some convenience methods and objects such
/// as an internal JSONDecoder to allow manipulation of content received from the server.
/// Most of this functionality is internal to this file or the main containing block, but this
/// may change as required.
///
/// Note that all calls must be made with https. Currently the app is not configured to handle
/// arbitrary loads or for any domain exceptions. 
final class APIClient {
  
  private(set) var baseURL: URL
  
  private(set) var headers: HTTPHeaders
  
  internal lazy var decoder = JSONDecoder() // consume API payload
  internal lazy var encoder = JSONEncoder() // send API payload
  
  /// Creates an instance of an APIClient for issuing network request.
  ///
  /// - Parameter baseURL: a string containing scheme and host information
  /// in the following format: "scheme://host"
  ///
  /// Valid initializer examples:
  /// - APIClient("https://www.example.com")
  /// - APIClient("http://api.example.com")
  init(baseURL: URL) {
    self.baseURL = baseURL
    
    // try to set headers with token from keychain
    headers = [
      "Authorization": ""
    ]
    
    decoder.keyDecodingStrategy = .convertFromSnakeCase
    decoder.dataDecodingStrategy = .deferredToData
    encoder.keyEncodingStrategy = .convertToSnakeCase
  }
  
  /// Checks for presence of Bitrise token and sets the authorization headers if one is found.
  ///
  /// This is purely a helper method to remove some of the common boilerplate from endpoint callers
  ///
  /// - Returns: true or false based on whether a token was found and headers set. When false, the
  ///   "Authorization" header key can be assumed to contain a nil or invalid value.
  internal func headersSetWithAuthorization() -> Bool {
    guard let token = App.sharedInstance.getBitriseAuthToken() else {
      return false
    }
    
    setAuthHeaders(withToken: token)
    return true
  }
  
  
  /// Helper method that sets the Authorization header to a valid token value. Mainly acts as a wrapper
  /// to provide clarity and auto-completion
  ///
  /// - Parameter value: an authorization token string. An authorization token is the Personal Access Token
  ///   obtained from the Bitrise site.
  private func setAuthHeaders(withToken value: String) {
    headers["Authorization"] = value
  }

  
  /// Resets the Authorization header to an empty string, wiping any stored value. Normally you wouldn't
  /// need to use this functionality, but it's provided as a convenience in case you want to call an
  /// endpoint with a clean slate.
  ///
  /// Note that this doesn't change anything in the Keychain, it purely clears the HTTP headers
  internal func invalidateAuthHeaders() {
    headers["Authorization"] = ""
  }
  
  /// Generates a URL with the provided endpoint path. Paths must not start with a forward slash.
  ///
  /// Examples:
  /// Valid: apiEndpointURL("me"), apiEndpointURL("me/apps")
  /// Invalid: apiEndpointURL("/me")
  ///
  /// - Parameter path: <#path description#>
  /// - Returns: <#return value description#>
  public func apiEndpointURL(_ path: String,
                             withQueryItems queries: [URLQueryItem]? = nil) -> URL {
    if let queryItems = queries {
      
      // Build the path with host & endpoint
      var components = URLComponents()
      components.scheme = "https"
      components.host = baseURL
        .absoluteString
        .replacingOccurrences(of: "https://", with: "") // Remove the scheme if it was present during
        .replacingOccurrences(of: "http://", with: "")  // initalisation, as we are adding it separately
      components.path = "/v0.1/\(path)" // seems to be necessary to have the leading / in this case
      
      // add parameters for the query
      components.queryItems = queryItems
      
      return components.url ?? baseURL.appendingPathComponent("v0.1/\(path)")
    } else {
      // If no parameters are required, just provide the path
      return baseURL.appendingPathComponent("v0.1/\(path)")
    }
  }
}


// MARK: - Authorization/validation
extension APIClient {
  
  /// Sends a request to base_url/me with the token value to ensure that what the user is saving
  /// is a valid token string. If API returns "200" header we can proceed, "401" - update the UI
  /// accordingly and get the user to enter a correct value.
  ///
  /// We use this to simplify checks, - this way we don't have to do regex and other types of
  /// validation directly on the textfield's text value. We can just try and submit a token.
  ///
  /// On the other hand, we should still check for empty textfield value, to save on data &
  /// networking calls
  ///
  /// - Parameters:
  ///   - token: Bitrise Personal Access Token
  ///   - completion: Validation result handler.
  func validateGeneratedToken(_ token: String,
                              then: @escaping (_ isValid: Bool, _ message: String) -> Void) {
    
    setAuthHeaders(withToken: token)
    
    let url = apiEndpointURL(Endpoint.me.rawValue)
    let queue = DispatchQueue.global(qos: .background)
    
    BRSessionManager.shared.background.request(url, method: .get, parameters: nil,
                                               encoding: JSONEncoding.default, headers: headers)
      .validate(statusCode: 200 ..< 300)
      .responseJSON(queue: queue, completionHandler: { response in
        
        switch response.result {
        case .success:
          then(true, "\(response.value ?? "Authorized")")
        case .failure(let error):
          then(false, "Unauthorized, \(error.localizedDescription)")
        }
      })
  }
}

// MARK: - Pull user & app data
extension APIClient {
  
  /// <#Description#>
  ///
  /// - Parameter completion: <#completion description#>
  func getUserProfile(then: @escaping (_ isSignedIn: Bool, _ user: User?, _ message: String) -> Void) {
    
    guard headersSetWithAuthorization() else {
      then(false, nil, L10n.noTokenInKeychain)
      return
    }
    
    let url = apiEndpointURL(Endpoint.me.rawValue)
    let queue = DispatchQueue.global(qos: .background)
    
    BRSessionManager.shared.background.request(url, method: .get, parameters: nil,
                                               encoding: JSONEncoding.default, headers: headers)
      .validate(statusCode: 200 ..< 300)
      .responseJSON(queue: queue, completionHandler: { [weak self] response in
        
        switch response.result {
        case .success:
          
          guard let data = response.data else {
            then(false, nil, "Response contained no data")
            return
          }
          
          do {
            
            let user = try self?.decoder.decode(User.self, from: data)
            //print(user?.description)
            App.sharedInstance.currentUser = user
            then(true, user, "User retrieved successfully")
            
          } catch let error {
            print("Failed json decoding with \(error.localizedDescription)")
            then(false, nil, "Failed to decode user object with \(error.localizedDescription)")
          }
        case .failure(let error):
          then(false, nil, "Unauthorized, \(error.localizedDescription)")
        }
      })
  }
  
  
  /// Makes a call to /apps endpoint.
  ///
  /// - Parameter completion: success status that can be true or false, an array of projects
  /// if successful or nil if not, and a message that provides additional information
  func getUserApps(then: @escaping (_ success: Bool,
    _ apps: [BitriseProjectViewModel]?, _ message: String) -> Void) {
    
    guard headersSetWithAuthorization() else {
      then(false, nil, L10n.noTokenInKeychain)
      return
    }
    
    let sortByLastBuildQuery = URLQueryItem(name: "sort_by", value: "last_build_at")
    let queryItems = [sortByLastBuildQuery]
    let url = apiEndpointURL(Endpoint.apps.rawValue, withQueryItems: queryItems)
    print(url)
    let queue = DispatchQueue.global(qos: .background)
    
    BRSessionManager.shared.background.request(url, method: .get, parameters: nil,
                                               encoding: JSONEncoding.default, headers: headers)
      .validate()
      .responseJSON(queue: queue, completionHandler: { [weak self] response in
        
        print("*** Completed project fetch")
        
        switch response.result {
        case .success:
          
          guard let data = response.data else {
            then(false, nil, "Response contained no data")
            return
          }
          
          do { // essentially, only one success condition
            
            let projectArrayStruct = try self?.decoder.decode(BitriseProjects.self, from: data)
            
            if let p = projectArrayStruct {
              var retrievedProjects = [BitriseProjectViewModel]()
              retrievedProjects = p.data.compactMap { BitriseProjectViewModel(with: $0) }
              then(true, retrievedProjects, "Fetched successfully")
            } else {
              print("Couldn't unwrap project struct")
              then(false, nil, "Invalid data structure")
            }
          } catch let error {
            then(false, nil, "Failed to decode application sets with \(error.localizedDescription)")
          }
        case .failure(let error):
          then(false, nil, "Unauthorized, \(error.localizedDescription)")
        }
      })
  }
  
  
  /// <#Description#>
  ///
  /// - Parameters:
  ///   - url: <#url description#>
  ///   - then: <#completion description#>
  func getUserImage(from url: URLConvertible,
                    then: @escaping (_ success: Bool, _ image: UIImage?, _ message: String) -> Void) {
    
    Alamofire.request(url)
      .validate()
      .responseImage { response in
        
        switch response.result {
        case .success:
          if var retrievedImage = response.result.value {
            retrievedImage = retrievedImage.af_imageRoundedIntoCircle()
            App.sharedInstance.currentUser?.avatarImage = retrievedImage
            then(true, retrievedImage, "Image received successfully")
          }
        case .failure(let error):
          then(false, nil, "Image retrieval failed with \(error.localizedDescription)")
        }
    }
  }

  
  func getYMLFor(bitriseApp app: BitriseApp,
                 then: @escaping (_ success: Bool, _ yamlString: String?, _ message: String) -> Void) {
    
    guard headersSetWithAuthorization() else {
      then(false, nil, L10n.noTokenInKeychain)
      return
    }
    
    let url = apiEndpointURL("\(Endpoint.apps.rawValue)/\(app.slug)/bitrise.yml")
    
    let queue = DispatchQueue.global(qos: .background)
    
    BRSessionManager.shared.background.request(url,
                                               method: .get,
                                               parameters: nil,
                                               encoding: URLEncoding.default, headers: headers)
      .validate()
      .response(queue: queue) { response in
        
        guard let httpResponse = response.response else {
          then(false, nil, "Bitrise YML wasn't available: missing HTTP URL Response")
          return
        }
        
        if httpResponse.statusCode == 200 {
          
          guard let data = response.data else {
            then(false, nil, "Bitrise YML wasn't available: response's data payload was empty")
            return
          }
          
          let ymlString = String(data: data, encoding: .utf8)
          
          then(true, ymlString, "Successfully fetched yml file")
          
        } else {
          then(false, nil, "Bitrise YML wasn't available, status code: \(httpResponse.statusCode)")
          return
        }
    }
  }
}
