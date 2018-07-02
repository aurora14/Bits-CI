//
//  Build.swift
//  bitrise unofficial ios
//
//  Created by Alexei Gudimenko on 22/6/18.
//  Copyright © 2018 Alexei Gudimenko. All rights reserved.
//

import UIKit

enum BuildStatus: Int, Codable {
  
  case inProgress
  case success
  case failure
  
  var text: String {
    switch self {
    case .inProgress: return "IN PROGRESS"
    case .success:    return "BUILDING"
    case .failure:    return "FAILING"
    }
  }
  
  var color: UIColor {
    switch self {
    case .inProgress: return Asset.Colors.bitrisePurple.color
    case .success:    return Asset.Colors.bitriseGreen.color
    case .failure:    return Asset.Colors.bitriseOrange.color
    }
  }
  
  var icon: UIImage {
    switch self {
    case .inProgress: return Asset.Icons.buildRunning.image
    case .success:    return Asset.Icons.buildSucceeded.image
    case .failure:    return Asset.Icons.buildFailed.image
    }
  }
}

struct Builds: Decodable {
  let data: [Build]
}

struct OriginalBuildParams: Codable {
  var commitHash: String?
  var branch: String?
  var commitMessage: String?
  var diffUrl: String?
  var workflowId: String?
}

struct Build: Codable {
  
  var status: BuildStatus? = .success
  var abortReason: String?
  var branch: String // master
  var buildNumber: Int // 1
  var commitHash: String?
  var commitMessage: String? // Updated dependencies
  var commitViewUrl: String?
  var environmentPrepareFinishedAt: String? //2017-11-08T13:26:54Z
  var finishedAt: String? // 2017-11-08T13:26:54Z
  var isOnHold: Bool // false
  var originalBuildParams: OriginalBuildParams?
  var pullRequestId: Int = 0
  var pullRequestTargetBranch: String?
  var pullRequestViewUrl: String?
  var slug: String
  var stackConfigType: String
  var stackIdentifier: String
  var startedOnWorkerAt: String?
  var statusText: String // success
  var tag: String?
  var triggeredAt: String
  var triggeredBy: String
  var triggeredWorkflow: String
  
  init(from decoder: Decoder) throws {
    //self.init() // Temporary testing code. TODO: - delete after creating the parsing model
    let container = try decoder.container(keyedBy: CodingKeys.self)
    
    abortReason = try container.decodeIfPresent(String.self, forKey: .abortReason)
    branch = try container.decode(String.self, forKey: .branch)
    buildNumber = try container.decode(Int.self, forKey: .buildNumber)
    commitHash = try container.decodeIfPresent(String.self, forKey: .commitHash)
    commitMessage = try container.decodeIfPresent(String.self, forKey: .commitMessage)
    commitViewUrl = try container.decodeIfPresent(String.self, forKey: .commitViewUrl)
    environmentPrepareFinishedAt = try
      container.decodeIfPresent(String.self, forKey: .environmentPrepareFinishedAt)
    finishedAt = try container.decodeIfPresent(String.self, forKey: .finishedAt)
    isOnHold = try container.decode(Bool.self, forKey: .isOnHold)
    pullRequestId = try container.decode(Int.self, forKey: .pullRequestId)
    pullRequestTargetBranch = try container.decodeIfPresent(String.self, forKey: .pullRequestTargetBranch)
    pullRequestViewUrl = try container.decodeIfPresent(String.self, forKey: .pullRequestViewUrl)
    slug = try container.decode(String.self, forKey: .slug)
    stackConfigType = try container.decode(String.self, forKey: .stackConfigType)
    stackIdentifier = try container.decode(String.self, forKey: .stackIdentifier)
    startedOnWorkerAt = try container.decodeIfPresent(String.self, forKey: .startedOnWorkerAt)
    statusText = try container.decode(String.self, forKey: .statusText)
    tag = try container.decodeIfPresent(String.self, forKey: .tag)
    triggeredAt = try container.decode(String.self, forKey: .triggeredAt)
    triggeredBy = try container.decode(String.self, forKey: .triggeredBy)
    triggeredWorkflow = try container.decode(String.self, forKey: .triggeredWorkflow)
    status = try container.decodeIfPresent(BuildStatus.self, forKey: .status)
    originalBuildParams = try container
      .decodeIfPresent(OriginalBuildParams.self, forKey: .originalBuildParams)
  }
}

/*
 
 @SerializedName("abort_reason") val abortReason: String?,
 @SerializedName("branch") val branch: String, //master
 @SerializedName("build_number") val number: Int, //20
 @SerializedName("commit_hash") val commitHash: String?, //null
 @SerializedName("commit_message") val commitMessage: String, //generate an APK
 @SerializedName("commit_view_url") val commitViewUrl: String?,
 @SerializedName("environment_prepare_finished_at") val environmentPrepareFinishedAt: Date?, //2017-11-08T13:24:33Z
 @SerializedName("finished_at") val finishedAt: Date?, //2017-11-08T13:26:54Z
 @SerializedName("is_on_hold") val isOnHold: Boolean, //false
 @SerializedName("original_build_params") val originalBuildParams: OriginalBuildParams,
 @SerializedName("pull_request_id") val pullRequestId: Int, //0
 @SerializedName("pull_request_target_branch") val pullRequestTargetBranch: String?,
 @SerializedName("pull_request_view_url") val pullRequestViewUrl: String?,
 @SerializedName("slug") val slug: String, //ddf4134555e833d8
 @SerializedName("stack_config_type") val stackConfigType: String, //standard1
 @SerializedName("stack_identifier") val stackIdentifier: String, //linux-docker-android
 @SerializedName("started_on_worker_at") val startedOnWorkerAt: String, //2017-11-08T13:24:33Z
 @SerializedName("status") val status: BuildStatus,
 @SerializedName("status_text") val statusText: String, //success
 @SerializedName("tag") val tag: String?,
 @SerializedName("triggered_at") val triggeredAt: Date, //2017-11-08T13:24:33Z
 @SerializedName("triggered_by") val triggeredBy: String, //manual-api-demo
 @SerializedName("triggered_workflow") val triggeredWorkflow: String //gen-apk
 
 */
