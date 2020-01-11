//
//  APIClient+Build.swift
//  bitrise unofficial ios
//
//  Created by Alexei Gudimenko on 10/10/18.
//  Copyright © 2018 Alexei Gudimenko. All rights reserved.
//

import Foundation
import Alamofire
import PromiseKit

// MARK: - Build management
extension APIClient {
  
  // MARK: - Get builds
  
  /// Fetches builds for a given app on Bitrise.
  ///
  /// - Parameters:
  ///   - app: the app as represented by the BitriseApp object. The most important property of this object is the 'slug' - slug is
  ///     the project ID on Bitrise and must be passed to get builds, YML etc belonging to that application.a
  ///   - limit: how many builds to fetch. Pass '1' to this parameter to fetch the last build. Pass '0' to this parameter to fetch
  ///     all builds for an application. Otherwise, set whatever value is necessary for the use case. The default value is '0'.
  ///   - completion: a closure containing the result of the call, an array of builds on success (or nil on failure), and a message
  func getBuilds(for app: BitriseApp, withLimit limit: Int = 0) -> Promise<[ProjectBuildViewModel]> {
    
    // v0.1/apps/{APP-SLUG}/builds
    firstly {
      self.headersSetWithAuthorization()
    }.then { token -> Promise<[ProjectBuildViewModel]> in
      return self.getBuilds(token, for: app, withLimit: limit)
    }
  }
  
  // MARK: - Start a new build
  
  /// <#Description#>
  ///
  /// - Parameters:
  ///   - app: <#app description#>
  ///   - buildParams: <#buildParams description#>
  ///   - then: <#then description#>
  func startNewBuild(for app: BitriseApp,
                     withBuildParams buildParams: BuildData,
                     then: @escaping (_ result: AsyncResult, _ message: String) -> Void) {

    firstly {
      self.headersSetWithAuthorization()
    }.done { token in

       let url = self.apiEndpointURL("\(Endpoint.apps.rawValue)/\(app.slug)/builds")

       // Encode build params data
       var buildRequestBody: Data
       do {
        buildRequestBody = try self.encoder.encode(buildParams)
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
    }.catch { error in
      log.error("No auth token in keychain; error: \(error)")
    }
  }
  
  // MARK: - Abort build
  
  /// <#Description#>
  ///
  /// - Parameters:
  ///   - buildID: <#buildID description#>
  ///   - bitriseAppID: <#bitriseAppID description#>
  ///   - abortParams: <#abortParams description#>
  ///   - then: <#then description#>
  func abortBuild(for buildID: Slug, inApp bitriseAppID: Slug,
                  withParams abortParams: AbortBuildParams, then: @escaping () -> Void) {

    firstly {
      self.headersSetWithAuthorization()
    }.done { token in
      let url = self.apiEndpointURL("\(Endpoint.apps.rawValue)/\(bitriseAppID)/builds/\(buildID)/abort")

      // Encode build params data
      var requestBody: Data
      do {
        requestBody = try self.encoder.encode(abortParams)
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
            log.info("*** API Client MSG: build aborted successfully")
            then()
          case .failure(let error):
            log.error("*** API Client MSG: build abort op FAIL: \(error.localizedDescription)")
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
    }.catch { error in
      log.error("No auth token in keychain; error: \(error)")
    }
  }
  
  // MARK: - Get the build log
  
  /// <#Description#>
  ///
  /// - Parameters:
  ///   - buildID: <#buildID description#>
  ///   - bitriseAppID: <#bitriseAppID description#>
  ///   - then: <#then description#>
  func getLog(forBuildID buildID: Slug,
              inApp bitriseAppID: Slug,
              then: @escaping (_ result: AsyncResult, _ log: BuildLog?, _ message: String) -> Void) {
    
    // v0.1/apps/{APP-SLUG}/builds/{BUILD-SLUG}/log

    firstly {
      self.headersSetWithAuthorization()
    }.done { token in
      let url = self.apiEndpointURL("\(Endpoint.apps.rawValue)/\(bitriseAppID)/builds/\(buildID)/log")
      let headers = ["Authorization": token]

      let queue = DispatchQueue.global(qos: .utility)

      BRSessionManager
        .shared
        .background
        .request(url, method: .get, parameters: nil,
                 encoding: JSONEncoding.default, headers: headers)
        .validate().responseJSON(queue: queue) { [weak self] response in

          switch response.result {
          case .success:

            guard let data = response.data else {
              then(.error, nil, "Build Log Request: response contained no data")
              return
            }

            do { // essentially, only one success condition
              let buildLog = try self?.decoder.decode(BuildLog.self, from: data)
              then(.success, buildLog, "Successfully fetched build log")
            } catch let error {
              then(.error, nil,
                   "Build log retrieval failed with \(error.localizedDescription), \(response.value ?? "")")
            }

          case .failure(let error):
            then(.error, nil, "Build log retrieval failed with \(error.localizedDescription)")
          }
      }
    }.catch { error in
      log.error("No auth token in keychain")
    }
  }
  
  
  /// Calls the expiring raw url obtained from the /log endpoint to retrieve the full contents of that log.
  ///
  /// - Parameters:
  ///   - url: the raw expiring URL
  ///   - then: completion handler that returns a result, log (if available) and information message
  func getFullBuildLog(from url: URLConvertible,
                       then: @escaping (_ result: AsyncResult, _ completeLog: String?, _ message: String) -> Void) {
    
    let queue = DispatchQueue.global(qos: .background)
    
    BRSessionManager.shared.background.request(url).validate().response(queue: queue) { response in
      
      guard let httpResponse = response.response else {
        then(.error, nil, "Full log wasn't available: missing HTTP URL Response")
        return
      }
      
      if httpResponse.statusCode == 200 {
        
        guard let data = response.data else {
          then(.error, nil, "Full log wasn't available: response's data payload was empty")
          return
        }
        
        let logString = """
        \(String(data: data, encoding: .utf8) ?? "")
        """
        
        then(.success, logString, "Successfully fetched full build log")
        
      } else {
        then(.error, nil, "Full log wasn't available, status code: \(httpResponse.statusCode)")
        return
      }
    }
  }
  
}

// MARK: - private API
extension APIClient {

  private func getBuilds(_ authToken: BitriseAccessToken, for app: BitriseApp, withLimit limit: Int = 0) -> Promise<[ProjectBuildViewModel]> {

    let promise: Promise<[ProjectBuildViewModel]> = Promise { resolver in

      var _url: URL

      if limit == 0 {
        _url = self.apiEndpointURL("\(Endpoint.apps.rawValue)/\(app.slug)/builds")
      } else {
        let limitItem = URLQueryItem(name: "limit", value: "\(limit)")

        let queryItems: [URLQueryItem] = [limitItem]

        _url = self.apiEndpointURL("\(Endpoint.apps.rawValue)/\(app.slug)/builds", withQueryItems: queryItems)
      }

      let headers = ["Authorization": authToken]

      let responseQueue = DispatchQueue.global(qos: .background)

      log.debug("GET app builds with url: \(_url)")

      BRSessionManager.shared.background.request(_url, method: .get, parameters: nil,
                                                 encoding: JSONEncoding.default, headers: headers)
        .validate()
        .responseJSON(queue: responseQueue, completionHandler: { [weak self] response in

          switch response.result {
          case .success:

            guard let data = response.data else {
              resolver.reject(APIError.emptyOrNilResponse)
              return
            }

            do { // essentially, only one success condition
              let builds = try self?.decoder.decode(Builds.self, from: data)
              // experimenting with a lazy collection instead of standard map and seeing whether performance
              // improves
              let buildsArray = builds?.data.compactMap { ProjectBuildViewModel(with: $0, forApp: app) } ?? []
              resolver.fulfill(buildsArray)
            } catch let error {
              resolver.reject(APIError.failedResponseParsing(error))
            }

          case .failure(let error):
            resolver.reject(APIError.apiResponseError(error))
          }
        })
    }

    return promise
  }
}
