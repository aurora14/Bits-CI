//
//  StartNewBuild.swift
//  bitrise unofficial ios
//
//  Created by Alexei Gudimenko on 10/8/18.
//  Copyright © 2018 Alexei Gudimenko. All rights reserved.
//

import Foundation

struct BuildParameters: Codable {
  
  var branch: String
  var workflowId: String
  var commitMessage: String
  
  init(branch: String, workflowId: String = "", commitMessage: String = "") {
    self.branch = branch
    self.workflowId = workflowId
    self.commitMessage = commitMessage
  }
}

struct HookInfo: Codable {
  let type = "bitrise"
}

/// Enclosing type that contains all objects & properties to be sent to Bitrise for
/// starting a new build. Authorization is still sent via headers.
struct BuildData: Codable {
  var triggeredBy: String
  let hookInfo: HookInfo
  let buildParams: BuildParameters
  
  init(branch: String, workflowId: String, commitMessage: String = "") {
    triggeredBy = Bundle.main.bundleIdentifier ?? "Bitrise iOS Client"
    hookInfo = HookInfo()
    buildParams = BuildParameters(branch: branch, workflowId: workflowId, commitMessage: commitMessage)
  }
}
