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
      case .aborted:
        if let finishedTime = build.finishedAt {
          return timeSinceBuild(forBuildFinishTime: finishedTime)
        } else {
          return "N/A"
        }
      }
    }
    return "N/A"
  }
  
  var buildStatusColor: UIColor {
    return lastBuild?.status?.color ?? Asset.Colors.bitriseGrey.color
  }
  
  var buildStatusIcon: UIImage {
    return lastBuild?.status?.icon ?? Asset.Icons.close.image
  }
  
  init(with app: BitriseApp) {
    self.app = app
    // get last build info here?
    updateLastBuild()
  }
  
  func cellInstance(_ tableView: UITableView, indexPath: IndexPath) -> UITableViewCell {
    
    guard let cell = tableView
      .dequeueReusableCell(withIdentifier: "ProjectCell") as? ProjectCell else {
        
        return UITableViewCell(style: .default, reuseIdentifier: "ProjectCell")
    }
    
    cell.setup(with: self)
    
    // May be replaced with project status, depending on design and API - alternatively might give
    // user the option of how they want projects colored
    // setDefaultBackgroundColor(in: cell, for: indexPath)
    
    return cell
  }
  
  
  func updateLastBuild() {
    App.sharedInstance.apiClient.getBuilds(for: self.app) { [weak self] success, build, message in
      self?.lastBuild = build
      print("""
        App: \(self?.app.title)
        Last Build finish time: \(build?.finishedAt)
        Status: \(build?.status)
        
        """)
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
      years == 1 ? timeElapsed.append("yr ") : timeElapsed.append("yrs ")
    }
    
    if let months = difference.month, months > 0 {
      timeElapsed.append("\(months) ")
      months == 1 ? timeElapsed.append("mth ") : timeElapsed.append("mths ")
    }

    if let weeks = difference.weekOfYear, weeks > 0 {
      timeElapsed.append("\(weeks) ")
      weeks == 1 ? timeElapsed.append("wk ") : timeElapsed.append("wks ")
    }
    
    if let days = difference.day, days > 0 {
      timeElapsed.append("\(days) d ")
    }
    
    if let hours = difference.hour, hours > 0 {
      timeElapsed.append("\(hours) ")
      hours == 1 ? timeElapsed.append("hr ") : timeElapsed.append("hrs ")
    }
    
    if let minutes = difference.minute, minutes > 0 {
      timeElapsed.append("\(minutes) ")
      minutes == 1 ? timeElapsed.append("min ") : timeElapsed.append("mins ")
    }
    
    if let minutes = difference.minute, minutes == 0,
      let seconds = difference.second, seconds > 0 {
      timeElapsed.append("\(seconds) seconds")
    }
    
    return "\(timeElapsed)ago"
  }
  
}
