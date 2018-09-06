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
  
  fileprivate lazy var decoder = JSONDecoder() // consume API payload
  fileprivate lazy var encoder = JSONEncoder() // send API payload
  
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
                              then: @escaping (_ isValid: Bool, _ message: String) -> Void) {
    
    setAuthHeaders(withToken: token)
    
    let url = apiEndpointURL(Endpoint.me.rawValue)
    let queue = DispatchQueue.global(qos: .background)
    
    //httpSessionManager.
    
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
    
    BRSessionManager.shared.background.request(url, method: .get, parameters: nil,
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
  
  
  /// Makes a call to /apps endpoint.
  ///
  /// - Parameter completion: success status that can be true or false, an array of projects
  /// if successful or nil if not, and a message that provides additional information
  func getUserApps(then: @escaping (_ success: Bool,
    _ apps: [BitriseProjectViewModel]?, _ message: String) -> Void) {
    
    guard let token = App.sharedInstance.getBitriseAuthToken() else {
      then(false, nil, "No token saved in keychain")
      return
    }
    
    setAuthHeaders(withToken: token)
    
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
  ///   - completion: <#completion description#>
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
  
  
  /// Fetches builds for a given app on Bitrise.
  ///
  /// - Parameters:
  ///   - app: the app as represented by the BitriseApp object. The most important property of this object is the 'slug' - slug is
  ///     the project ID on Bitrise and must be passed to get builds, YML etc belonging to that application.a
  ///   - limit: how many builds to fetch. Pass '1' to this parameter to fetch the last build. Pass '0' to this parameter to fetch
  ///     all builds for an application. Otherwise, set whatever value is necessary for the use case. The default value is '0'.
  ///   - completion: a closure containing the result of the call, an array of builds on success (or nil on failure), and a message
  func getBuilds(for app: BitriseApp, withLimit limit: Int = 0,
                 then: @escaping (_ success: Bool, _ builds: [ProjectBuildViewModel]?, _ message: String) -> Void) {
    
    // v0.1/apps/{APP-SLUG}/builds
    
    guard let token = App.sharedInstance.getBitriseAuthToken() else {
      then(false, nil, "No token saved in keychain")
      return
    }
    
    setAuthHeaders(withToken: token)
    
    var url: URL
    
    if limit == 0 {
      url = apiEndpointURL("\(Endpoint.apps.rawValue)/\(app.slug)/builds")
    } else {
      let limitItem = URLQueryItem(name: "limit", value: "\(limit)")
      
      let queryItems: [URLQueryItem] = [limitItem]
      
      url = apiEndpointURL("\(Endpoint.apps.rawValue)/\(app.slug)/builds", withQueryItems: queryItems)
    }
    
    print("*** Last Build URL String: \(url.absoluteString)")
    
    let queue = DispatchQueue.global(qos: .background)
    
    BRSessionManager.shared.background.request(url, method: .get, parameters: nil,
                                               encoding: JSONEncoding.default, headers: headers)
      .validate()
      .responseJSON(queue: queue, completionHandler: { [weak self] response in
        
        switch response.result {
        case .success:
          
          guard let data = response.data else {
            then(false, nil, "Response contained no data")
            return
          }
          
          do { // essentially, only one success condition
            let builds = try self?.decoder.decode(Builds.self, from: data)
            let buildsArray = builds?.data.compactMap { ProjectBuildViewModel(with: $0) }
            //print("Test: last build # \(lastBuild?.buildNumber)")
            //debugPrint(response.value)
            guard buildsArray != nil else {
              then(false, nil, "Failed to translate build")
              return
            }
            then(true, buildsArray, "Successfully fetched build")
          } catch let error {
            then(false, nil,
                       "Build retrieval failed with \(error.localizedDescription), \(response.value ?? "")")
          }
          
        case .failure(let error):
          then(false, nil, "Build retrieval failed with \(error.localizedDescription)")
        }
      })
  }
  
  func getYMLFor(bitriseApp app: BitriseApp, completion: @escaping (_ success: Bool, _ yamlString: String?, _ message: String) -> Void) {
    
    guard let token = App.sharedInstance.getBitriseAuthToken() else {
      completion(false, nil, "No token saved in keychain")
      return
    }
    
    setAuthHeaders(withToken: token)
    
    let url = apiEndpointURL("\(Endpoint.apps.rawValue)/\(app.slug)/bitrise.yml")
    
    let queue = DispatchQueue.global(qos: .background)
    
    BRSessionManager.shared.background.request(url,
                                               method: .get,
                                               parameters: nil,
                                               encoding: URLEncoding.default, headers: headers)
      .validate()
      .response(queue: queue) { response in
        
        guard let httpResponse = response.response else {
          completion(false, nil, "Bitrise YML wasn't available: missing HTTP URL Response")
          return
        }
        
        if httpResponse.statusCode == 200 {
          
          guard let data = response.data else {
            completion(false, nil, "Bitrise YML wasn't available")
            return
          }
          
          let ymlString = String(data: data, encoding: .utf8)
          
          completion(true, ymlString, "Successfully fetched yml file")
          
        } else {
          
          completion(false, nil, "Bitrise YML wasn't available, status code: \(httpResponse.statusCode)")
          return
          
        }
    }
  }
}

// MARK: - New build
extension APIClient {
  
  func startNewBuild(for app: BitriseApp,
                     withBuildParams buildParams: BuildData,
                     then: @escaping (_ result: AsyncResult, _ message: String) -> Void) {
    
    // ensure user is authorized
    guard let token = App.sharedInstance.getBitriseAuthToken() else {
      then(.error, L10n.noTokenInKeychain)
      return
    }
    
    setAuthHeaders(withToken: token)
    
    let url = apiEndpointURL("\(Endpoint.apps.rawValue)/\(app.slug)/builds")
    
    // Encode build params data
    var buildRequestBody: Data
    do {
      buildRequestBody = try encoder.encode(buildParams)
    } catch let error {
      print(error.localizedDescription)
      then(.error, error.localizedDescription)
      return
    }
    
    // Create a custom request
    var buildRequest = URLRequest(url: url)
    buildRequest.httpMethod = HTTPMethod.post.rawValue
    buildRequest.setValue(token, forHTTPHeaderField: "Authorization")
    buildRequest.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
    buildRequest.httpBody = buildRequestBody
    
    BRSessionManager.shared.background.request(buildRequest)
      .validate()
      .responseJSON { response in
        
        switch response.result {
        case .success:
          guard let data = response.data, let statusCode = response.response?.statusCode else {
            then(.success, "Build started successfully")
            return
          }
          do {
            let response = try self.decoder.decode(BuildErrorResponse.self, from: data)
            then(.success, "\(statusCode): \(response.message)")
          } catch {
            then(.success, "Build started successfully")
          }
          then(.success, "Build started successfully")
        case .failure(let error):
          guard let data = response.data, let statusCode = response.response?.statusCode else {
            then(.error, error.localizedDescription)
            return
          }
          do {
            let response = try self.decoder.decode(BuildErrorResponse.self, from: data)
            then(.error, "\(statusCode): \(response.message)")
          } catch {
            then(.error, error.localizedDescription)
          }
        }
    }
    
    
    // Validate HTTP errors, get HTTP body of response
  }
}
