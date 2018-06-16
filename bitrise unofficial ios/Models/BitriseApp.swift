//
//  BitriseApp.swift
//  bitrise unofficial ios
//
//  Created by Alexei Gudimenko on 16/6/18.
//  Copyright © 2018 Alexei Gudimenko. All rights reserved.
//

import Foundation


struct BitriseApp: Encodable, Decodable, Equatable {
  
  var title: String
  var slug: String
  var projectType: String? // e.g. "iOS", "Xamarin" - can be 'null' if project hasn't been fully set up
  var provider: String // Usually this is the remote host, e. g. Gitlab, Github, Bitbucket
  var repoOwner: String
  var repoUrl: String
  var repoSlug: String
  var isDisabled: Bool
  var status: Int
  var isPublic: Bool
  var owner: BitriseProjectOwner
  
  init(
    title appTitle: String,
    slug appSlug: String,
    projectType type: String?,
    provider serviceProvider: String,
    repoOwner rOwner: String,
    repoUrl rUrl: String,
    repoSlug rSlug: String,
    isDisabled disabled: Bool,
    status appStatus: Int,
    isPublic i_Public: Bool,
    owner projectOwner: BitriseProjectOwner
    ) {
    
    title = appTitle
    slug = appSlug
    projectType = type
    provider = serviceProvider
    repoOwner = rOwner
    repoUrl = rUrl
    repoSlug = rSlug
    isDisabled = disabled
    status = appStatus
    isPublic = i_Public
    owner = projectOwner
  }
  
}
