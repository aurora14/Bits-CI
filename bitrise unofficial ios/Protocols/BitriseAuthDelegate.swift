//
//  BitriseAuthDelegate.swift
//  bitrise unofficial ios
//
//  Created by Alexei Gudimenko on 29/8/18.
//  Copyright © 2018 Alexei Gudimenko. All rights reserved.
//

import Foundation

typealias AuthToken = String

protocol BitriseAuthorizationDelegate: class {
  
  /// Called when the API returns user information from base_url/me endpoint.
  /// * User enters token into the text field and submits.
  /// * If the token is valid, Bitrise API returns user name, slug and avatar URL
  /// * In that case, call this delegate method and dismiss the TokenAuth View Controller.
  /// - Parameter authorizationToken: token string. Pass this parameter in only if the underlying
  ///   implementation requires this value for other functionality it invokes
  
  func didAuthorizeSuccessfully(withToken authorizationToken: AuthToken?)
  
  /// Called when the API returns 401 and "Unauthorized" message from the base_url/me endpoint.
  /// * User enters token into the text field and submits
  /// * Invalid token & Unauth 401 result
  /// * DO NOT dismiss the view controller. Highlight the text field border in red and show an error message
  /// * When the user starts editing again, revert the border to the original colour and hide the error msg
  ///
  /// - Parameter error: <#error description#>
  
  func didFailToAuthorize(with message: String)
  
  /// User decided not to submit a token and dismissed the view with the cancel button
  func didCancelAuthorization()
}
