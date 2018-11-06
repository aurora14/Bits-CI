//
//  Bundle+AppVersions.swift
//  bitrise unofficial ios
//
//  Created by Alexei Gudimenko on 4/11/18.
//  Copyright © 2018 Alexei Gudimenko. All rights reserved.
//

import Foundation

extension Bundle {
  
  var appVersionNumber: String? {
    return self.infoDictionary?["CFBundleShortVersionString"] as? String
  }
  
  var buildVersionNumber: String? {
    return self.infoDictionary?["CFBundleVersion"] as? String
  }
  
}
