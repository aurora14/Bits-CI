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

/// Handles communication with the Bitrise endpoints. Avoid adding state to this. The definition
/// should not be modified.
/// This class acts as a wrapper for typical Alamofire requests, allowing specification of
/// parameters and completion handlers. It also defines some convenience methods and objects such
/// as an internal JSONDecoder to allow manipulation of content received from the server.
/// Most of this functionality is internal to this file or the main containing block, but this
/// may change as required.
final class APIClient {
  
  private(set) var baseURL: URL
  
  private(set) var headers: HTTPHeaders
  
  fileprivate lazy var decoder = JSONDecoder()
  
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
  
  func setAuthHeaders(withToken value: String) {
    headers["Authorization"] = value
  }
}

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
                              completion: @escaping (_ isValid: Bool, _ message: String) -> Void) {
    
    setAuthHeaders(withToken: token)
    
    let url = apiEndpointURL(Endpoint.me.rawValue)
    let queue = DispatchQueue.global(qos: .background)
    
    //httpSessionManager.
    
    Alamofire.request(url, method: .get, parameters: nil,
                      encoding: JSONEncoding.default, headers: headers)
      .validate(statusCode: 200 ..< 300)
      .responseJSON(queue: queue, completionHandler: { response in
        
        switch response.result {
        case .success:
          completion(true, "\(response.value ?? "Authorized")")
        case .failure(let error):
          completion(false, "Unauthorized, \(error.localizedDescription)")
        }
      })
  }
  
  
  /// <#Description#>
  ///
  /// - Parameter completion: <#completion description#>
  func getUserProfile(completion: @escaping (_ isSignedIn: Bool, _ user: User?, _ message: String) -> Void) {
    
    guard let token = App.sharedInstance.getBitriseAuthToken() else {
      completion(false, nil, "No token saved in keychain")
      return
    }
    
    setAuthHeaders(withToken: token)
    
    let url = apiEndpointURL(Endpoint.me.rawValue)
    let queue = DispatchQueue.global(qos: .background)
    
    Alamofire.request(url, method: .get, parameters: nil,
                      encoding: JSONEncoding.default, headers: headers)
      .validate(statusCode: 200 ..< 300)
      .responseJSON(queue: queue, completionHandler: { [weak self] response in
        
        switch response.result {
        case .success:
          
          guard let data = response.data else {
            completion(false, nil, "Response contained no data")
            return
          }
          
          do {
            
            let user = try self?.decoder.decode(User.self, from: data)
            //print(user?.description)
            App.sharedInstance.currentUser = user
            completion(true, user, "User retrieved successfully")
            
          } catch let error {
            print("Failed json decoding with \(error.localizedDescription)")
            completion(false, nil, "Failed to decode user object with \(error.localizedDescription)")
          }
        case .failure(let error):
          completion(false, nil, "Unauthorized, \(error.localizedDescription)")
        }
      })
  }
  
  
  func getUserApps(completion: @escaping (_ success: Bool,
    _ apps: [BitriseProjectViewModel]?, _ message: String) -> Void) {
    
    guard let token = App.sharedInstance.getBitriseAuthToken() else {
      completion(false, nil, "No token saved in keychain")
      return
    }
    
    setAuthHeaders(withToken: token)
    
    let sortByLastBuildQuery = URLQueryItem(name: "sort_by", value: "last_build_at")
    let queryItems = [sortByLastBuildQuery]
    let url = apiEndpointURL(Endpoint.apps.rawValue, withQueryItems: queryItems)
    print(url)
    let queue = DispatchQueue.global(qos: .background)
    
    Alamofire.request(url, method: .get, parameters: nil,
                      encoding: JSONEncoding.default, headers: headers)
      .validate()
      .responseJSON(queue: queue, completionHandler: { [weak self] response in
        
        switch response.result {
        case .success:
          
          guard let data = response.data else {
            completion(false, nil, "Response contained no data")
            return
          }
          
          var retrievedProjects = [BitriseProjectViewModel]()
          
          do {
            let projectArrayStruct = try self?.decoder.decode(BitriseProjects.self, from: data)
            if let p = projectArrayStruct {
              retrievedProjects = p.data.map { BitriseProjectViewModel(with: $0) }
            } else {
              print("Couldn't unwrap project struct")
            }
            
            completion(true, retrievedProjects, "Fetched successfully")
          } catch let error {
            completion(false, nil, "Failed to decode application sets with \(error.localizedDescription)")
          }
        case .failure(let error):
          completion(false, nil, "Unauthorized, \(error.localizedDescription)")
        }
      })
  }
  
  
  func getUserImage(from url: URLConvertible,
                    completion: @escaping (_ success: Bool, _ image: UIImage?, _ message: String) -> Void) {
    
    Alamofire.request(url)
      .validate()
      .responseImage { response in
        
        switch response.result {
        case .success:
          if var retrievedImage = response.result.value {
            retrievedImage = retrievedImage.af_imageRoundedIntoCircle()
            App.sharedInstance.currentUser?.avatarImage = retrievedImage
            completion(true, retrievedImage, "Image received successfully")
          }
        case .failure(let error):
          completion(false, nil, "Image retrieval failed with \(error.localizedDescription)")
        }
    }
  }
}
