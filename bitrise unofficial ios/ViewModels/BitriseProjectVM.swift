//
//  BitriseProjectViewModel.swift
//  bitrise-unofficial-ios
//
//  Created by Alexei Gudimenko on 13/6/18.
//  Copyright © 2018 Alexei Gudimenko. All rights reserved.
//

import UIKit
import SwiftDate


protocol ViewRefreshDelegate: class {
  func update(at indexPath: IndexPath?)
}


class BitriseProjectViewModel: CellRepresentable {
  
  var rowHeight: CGFloat = 84
  
  weak var viewRefreshDelegate: ViewRefreshDelegate?
  
  /// If the viewmodel is used for a collection or a table view, you may pass the index path
  /// object in itemForRow or cellForRow methods, should you need to do direct updates to items.
  /// Otherwise, this property can remain nil and be ignored.
  var indexPath: IndexPath?
  
  var isReady: Bool = false
  
  var app: BitriseApp
  
  var title: String {
    return app.title
  }
  
  var isDisabled: Bool {
    return app.isDisabled
  }
  
  var isPublic: Bool {
    return app.isPublic
  }
  
  var projectOwner: String {
    if let owner = app.owner {
      return "\(owner.name) / "
    } else {
      return ""
    }
  }
  
  var lastBuild: Build? {
    didSet {
      isReady = true
      viewRefreshDelegate?.update(at: indexPath)
    }
  }
  
  var lastBuildNumber: String {
    return lastBuild == nil ? "" : "\(lastBuild!.buildNumber)"
  }
  
  var lastBuildTime: String {
    if let build = lastBuild, let status = build.status {
      switch status {
      case .success:
        if let finishedTime = build.finishedAt {
          return timeSinceBuild(forBuildFinishTime: finishedTime)
        } else {
          return "N/A"
        }
      case .failure:
        if let finishedTime = build.finishedAt {
          return timeSinceBuild(forBuildFinishTime: finishedTime)
        } else {
          return "N/A"
        }
      case .inProgress: return status.text
      case .aborted, .abortedWithSuccess:
        if let finishedTime = build.finishedAt {
          return timeSinceBuild(forBuildFinishTime: finishedTime)
        } else {
          return "N/A"
        }
      }
    }
    return ""
  }
  
  var buildStatusColor: UIColor {
    return lastBuild?.status?.color ?? Asset.Colors.bitriseGrey.color
  }
  
  var buildStatusIcon: UIImage {
    return lastBuild?.status?.icon ?? UIImage()
  }
  
  var buildList = [ProjectBuildViewModel]()
  
  var bitriseYML: String?
  
  
  init(with app: BitriseApp) {
    self.app = app
    
    guard !app.slug.isEmpty else {
      // if there's no app ID, don't get the last builds (e.g. if loading dummy items)
      return
    }
    
    updateLastBuild()
    DispatchQueue.global(qos: .background).async { [weak self] in
      self?.updateAllBuilds()
      self?.updateYML()
    }
  }

  
  func cellInstance(_ tableView: UITableView, indexPath: IndexPath) -> UITableViewCell {
    
    guard let cell = tableView
      .dequeueReusableCell(withIdentifier: CellReuseIdentifier.projectCell) as? ProjectCell else {
        return UITableViewCell(style: .default, reuseIdentifier: CellReuseIdentifier.projectCell)
    }
    
    cell.setup(with: self)
    
    // May be replaced with project status, depending on design and API - alternatively might give
    // user the option of how they want projects colored
    // setDefaultBackgroundColor(in: cell, for: indexPath)
    
    return cell
  }
  
  
  func updateLastBuild() {
    App
      .sharedInstance
      .apiClient
      .getBuilds(for: self.app, withLimit: 1) { [weak self] _, builds, _ in
      self?.lastBuild = builds?.first?.build
    }
  }
  
  
  func updateAllBuilds() {
    
    // TODO: - assign builds to the BitriseApp model directly instead after the main functionality works
    
    App
      .sharedInstance
      .apiClient
      .getBuilds(for: self.app) { [weak self] _, builds, message in
      
      guard let b = builds else {
        print("*** No builds available, \(message)")
        self?.buildList = [ProjectBuildViewModel]()
        return
      }
      
      self?.buildList = b
    }
  }
  
  
  func updateYML() {
    App.sharedInstance.apiClient.getYMLFor(bitriseApp: self.app) { [weak self] _, yml, _ in
      // if let y = yml { print("YML available") } else { print("yml null") }
      self?.bitriseYML = yml
    }
  }
  
  /// Transforms an iso8601-format string in the Build's 'Finished At' field into a formatted
  /// string stating the length of time elapsed since the build last finished
  ///
  /// - Parameter timeString: <#timeString description#>
  /// - Returns: <#return value description#>
  private func timeSinceBuild(forBuildFinishTime timeString: String) -> String {
    
    guard let lastBuildDate = DateInRegion(timeString,
                                           format: DateFormats.iso8601,
                                           region: SwiftDate.defaultRegion) else {
                                            
                                            return ""
    }
    
    let now = Date()
    
    let difference = now - lastBuildDate.date
    
    var timeElapsed: String = ""
    
    if let years = difference.year, years > 0 {
      timeElapsed.append("\(years) ")
      years == 1 ? timeElapsed.append("\(L10n.yr) ") : timeElapsed.append("\(L10n.yrs) ")
    }
    
    if let months = difference.month, months > 0 {
      timeElapsed.append("\(months) ")
      months == 1 ? timeElapsed.append("\(L10n.mth) ") : timeElapsed.append("\(L10n.mths) ")
    }

    if let weeks = difference.weekOfYear, weeks > 0 {
      timeElapsed.append("\(weeks) ")
      weeks == 1 ? timeElapsed.append("\(L10n.wk) ") : timeElapsed.append("\(L10n.wks) ")
    }
    
    if let days = difference.day, days > 0 {
      timeElapsed.append("\(days) \(L10n.d) ")
    }
    
    if let hours = difference.hour, hours > 0 {
      timeElapsed.append("\(hours) ")
      hours == 1 ? timeElapsed.append("\(L10n.hr) ") : timeElapsed.append("\(L10n.hrs) ")
    }
    
    if let minutes = difference.minute, minutes > 0 {
      timeElapsed.append("\(minutes) ")
      minutes == 1 ? timeElapsed.append("\(L10n.min) ") : timeElapsed.append("\(L10n.mins) ")
    }
    
    if let minutes = difference.minute, minutes == 0,
      let seconds = difference.second, seconds > 0 {
      timeElapsed.append("\(seconds) \(L10n.seconds) ")
    }
    
    return "\(timeElapsed)\(L10n.ago)"
  }
  
}
