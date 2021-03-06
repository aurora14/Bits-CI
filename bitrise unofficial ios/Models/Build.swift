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
  case aborted
  case abortedWithSuccess
  
  var text: String {
    switch self {
    case .inProgress: return "IN PROGRESS"
    case .success:    return "SUCCESS"
    case .failure:    return "FAILING"
    case .aborted:    return "ABORTED"
    case .abortedWithSuccess: return "CANCELLED BY USER"
    }
  }
  
  var color: UIColor {
    switch self {
    case .inProgress: return Asset.Colors.bitrisePurple.color
    case .success:    return Asset.Colors.bitriseGreen.color
    case .failure:    return Asset.Colors.bitriseOrange.color
    case .aborted:    return Asset.Colors.bitriseYellow.color
    case .abortedWithSuccess: return BuildStatus.aborted.color
    }
  }
  
  /// Build status icon for use on white backgrounds
  var icon: UIImage {
    switch self {
    case .inProgress: return Asset.Icons.buildRunning.image
    case .success:    return Asset.Icons.buildSucceeded.image
    case .failure:    return Asset.Icons.buildFailed.image
    case .aborted:    return Asset.Icons.buildAborted.image
    case .abortedWithSuccess: return BuildStatus.aborted.icon
    }
  }
  
  /// Build status icon for use on darker solid colour backgrounds
  var iconWhite: UIImage {
    switch self {
    case .inProgress: return Asset.Icons.buildRunningWhite.image
    case .success:    return Asset.Icons.buildSucceededWhite.image
    case .failure:    return Asset.Icons.buildFailedWhite.image
    case .aborted:    return Asset.Icons.buildAbortedWhite.image
    case .abortedWithSuccess: return BuildStatus.aborted.iconWhite
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
    stackConfigType = try container.decodeIfPresent(String.self, forKey: .stackConfigType) ??
    "Stack Configuration Unavailable"
    stackIdentifier = try container.decode(String.self, forKey: .stackIdentifier)
    startedOnWorkerAt = try container.decodeIfPresent(String.self, forKey: .startedOnWorkerAt)
    statusText = try container.decode(String.self, forKey: .statusText)
    tag = try container.decodeIfPresent(String.self, forKey: .tag)
    triggeredAt = try container.decode(String.self, forKey: .triggeredAt)
    triggeredBy = try container.decodeIfPresent(String.self, forKey: .triggeredBy) ?? "Not Available"
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
