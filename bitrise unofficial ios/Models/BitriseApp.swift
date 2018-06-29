//
//  BitriseApp.swift
//  bitrise unofficial ios
//
//  Created by Alexei Gudimenko on 16/6/18.
//  Copyright © 2018 Alexei Gudimenko. All rights reserved.
//

import Foundation

struct BitriseProjects: Decodable {
  let data: [BitriseApp]
  let paging: Paging?
}

struct BitriseApp: Codable, Equatable, CustomStringConvertible {
  
  var data: Data? // we need a data field to act as a container for the bitrise json model
  
  enum VCProvider {
    case gitlab
    case github
    case bitbucket
  }
  
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
  var owner: BitriseProjectOwner?
  
  var description: String = "\(type(of: BitriseApp.self))"
  
  
  init(from decoder: Decoder) throws {
    //self.init() // Temporary testing code. TODO: - delete after creating the parsing model
    let container = try decoder.container(keyedBy: CodingKeys.self)
    
    title = try container.decode(String.self, forKey: .title).uppercased()
    slug = try container.decode(String.self, forKey: .slug)
    projectType = try container.decodeIfPresent(String.self, forKey: .projectType)
    provider = try container.decode(String.self, forKey: .provider)
    repoOwner = try container.decode(String.self, forKey: .repoOwner)
    repoUrl = try container.decode(String.self, forKey: .repoUrl)
    repoSlug = try container.decode(String.self, forKey: .repoSlug)
    isDisabled = try container.decode(Bool.self, forKey: .isDisabled)
    status = try container.decode(Int.self, forKey: .status)
    isPublic = try container.decode(Bool.self, forKey: .isPublic)
    owner = try container.decode(BitriseProjectOwner.self, forKey: .owner)
    
  }
  
  
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
  
  
  /// A convenience dummy initialiser
  init() {
    title = ""
    slug = ""
    projectType = ""
    provider = ""
    repoOwner = ""
    repoUrl = ""
    repoSlug = ""
    isDisabled = true
    status = 0
    isPublic = false
    owner = nil
  }

}
