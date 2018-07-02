//
//  String+Digits.swift
//  bitrise unofficial ios
//
//  Created by Alexei Gudimenko on 23/6/18.
//  Copyright © 2018 Alexei Gudimenko. All rights reserved.
//

import Foundation

extension String {
  
  /// Returns a string containing any digits contained in a source string
  var digits: String {
    return components(separatedBy: CharacterSet.decimalDigits.inverted).joined()
  }
  
  
  /// <#Description#>
  var isValidNumber: Bool {
    //let regex = "^[0-9]+(?:\\.[0-9])?$"
    let regex = "^\\d*(\\.\\d+)?$"
    return NSPredicate(format: "SELF MATCHES %@", regex).evaluate(with: self)
  }
  
}
