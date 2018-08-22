//
//  ProjectBuildVM.swift
//  bitrise unofficial ios
//
//  Created by Alexei Gudimenko on 24/7/18.
//  Copyright © 2018 Alexei Gudimenko. All rights reserved.
//

import UIKit
import SwiftDate


class ProjectBuildViewModel: CellRepresentable {
  
  var rowHeight: CGFloat = 84
  
  var build: Build
  
  var buildStatusColor: UIColor {
    guard let color = build.status?.color else {
      return Asset.Colors.bitriseGrey.color
    }
    return color
  }
  
  var buildStatusText: String {
    guard let statusText = build.status?.text else {
      return "N/A"
    }
    return statusText.capitalized
  }
  
  var buildTriggeredAt: String {
    
    guard let startDate = DateInRegion(
      build.triggeredAt,
      format: DateFormats.iso8601,
      region: SwiftDate.defaultRegion) else {
        return build.triggeredAt
    }
    
    return startDate.toString()
  }
  
  var workflow: String {
    return build.triggeredWorkflow
  }
  
  /// Returns branch used in the build
  var branch: String {
    return build.branch
  }
  
  /// Returns a difference between trigger time and finish time
  var duration: String {
    
    guard let finishedAt = build.finishedAt else {
      print("*** No finish time available")
      return "N/A"
    }
    
    guard let endTime = DateInRegion(
      finishedAt,
      format: DateFormats.iso8601,
      region: SwiftDate.defaultRegion) else {
        print("*** End time couldn't be parsed")
        return "N/A"
    }
    
    guard let startTime = DateInRegion(
      build.triggeredAt,
      format: DateFormats.iso8601,
      region: SwiftDate.defaultRegion) else {
        print("*** Start time couldn't be parsed")
        return "N/A"
    }
    
    let durationComponents = endTime.date - startTime.date
    
    var duration = ""
    
    if let hours = durationComponents.hour, abs(hours) > 0 {
      duration.append("\(hours)")
      duration.append("h ")
    }
    
    if let minutes = durationComponents.minute, abs(minutes) > 0 {
      duration.append("\(minutes)")
      duration.append("m ")
    }
    
    if let seconds = durationComponents.second, abs(seconds) > 0 {
      duration.append("\(seconds)s")
    }
    
    return "\(duration)"
  }
  
  var buildNumber: String {
    return "#\(build.buildNumber)"
  }
  
  init(with build: Build) {
    self.build = build
  }
  
  func cellInstance(_ tableView: UITableView, indexPath: IndexPath) -> UITableViewCell {
    
    guard let cell = tableView
      .dequeueReusableCell(withIdentifier: "BuildCell") as? BuildCell else {
        
        return UITableViewCell(style: .default, reuseIdentifier: "BuildCell")
    }
    
    cell.setup(with: self)
    
    return cell
  }
}
