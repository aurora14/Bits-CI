//
//  AsyncResult.swift
//  bitrise unofficial ios
//
//  Created by Alexei Gudimenko on 18/8/18.
//  Copyright © 2018 Alexei Gudimenko. All rights reserved.
//

import Foundation

/// A simple result wrapper for async ops with two states. Note that it only returns
/// states, with no information, to allow switching on something a bit more meaningful
/// than just a true/false boolean. 
///
/// - success: represents 'true' or 'success' of the operation
/// - error: represents 'false' or 'failure' of the operation
enum AsyncResult {
  case success, error
}
