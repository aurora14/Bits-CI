//
//  APIClient+Organizations.swift
//  bitrise unofficial ios
//
//  Created by Alexei Gudimenko on 19/10/18.
//  Copyright © 2018 Alexei Gudimenko. All rights reserved.
//

import Foundation
import Alamofire
import PromiseKit

// MARK: - Organization fetch
extension APIClient {
  

  /// Endpoint: v0.1/organizations
  /// - Parameter then: completion handler with a list of organisations if available
  func getOrganizations(then: @escaping (_ result: AsyncResult, _ orgs: [Organization], _ msg: String) -> Void) {
    
    firstly {
      self.headersSetWithAuthorization()
    }.done { token in

      let url = self.apiEndpointURL(Endpoint.organizations.rawValue)
      let headers = ["Authorization": token]

      let responseQueue = DispatchQueue.global(qos: .background)

      BRSessionManager.shared.background.request(url, method: .get, parameters: nil,
                                                 encoding: JSONEncoding.default, headers: headers)
        .validate()
        .responseJSON(queue: responseQueue, completionHandler: { [weak self] response in

          guard let strongSelf = self else {
            return
          }

          switch response.result {

          case .success:

            guard let data = response.data else {
              then(.error, [], "Response contained no data")
              return
            }

            do {
              let orgs = try strongSelf.decoder.decode(Organizations.self, from: data)
              then(.success, orgs.data, "Successfully fetched organizations")
            } catch let error {
              then(.error, [],
                   "Orgs retrieval failed with \(error.localizedDescription), \(response.value ?? "")")
            }
          case .failure(let error):
            print("*** Orgs failure: \(error.localizedDescription)")
          }

      })
    }.catch { error in
      log.error("No auth token in keychain; error: \(error)")
    }
  }
}
