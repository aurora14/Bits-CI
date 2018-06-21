//
//  BitriseProjectViewModel.swift
//  bitrise-unofficial-ios
//
//  Created by Alexei Gudimenko on 13/6/18.
//  Copyright © 2018 Alexei Gudimenko. All rights reserved.
//

import UIKit

struct BitriseProjectViewModel: CellRepresentable {
  
  var rowHeight: CGFloat = 84
  
  var app: BitriseApp
  
  // TODO: - perform any necessary transformations here
  var title: String {
    return app.title
  }
  
  var isDisabled: Bool {
    return app.isDisabled
  }
  
  var isPublic: Bool {
    return app.isPublic
  }
  
  init(with app: BitriseApp) {
    self.app = app
  }
  
  func cellInstance(_ tableView: UITableView, indexPath: IndexPath) -> UITableViewCell {
    
    guard let cell = tableView
      .dequeueReusableCell(withIdentifier: "ProjectCell") as? ProjectCell else {
        
        return UITableViewCell(style: .default, reuseIdentifier: "ProjectCell")
    }
    
    cell.setup(with: self)
    
    // May be replaced with project status, depending on design and API - alternatively might give
    // user the option of how they want projects colored
    setDefaultBackgroundColor(in: cell, for: indexPath)
    
    return cell
  }
  
  private func setDefaultBackgroundColor(in cell: UITableViewCell, for indexPath: IndexPath) {
    
    //print("*** Set default background colours for section \(indexPath.section) \(indexPath.section % 5)")
    
    switch indexPath.section % 5 {
    case 0:
      cell.setContentViewColor(to: Asset.Colors.lightBlue.color)
    case 1:
      cell.setContentViewColor(to: Asset.Colors.saladGreen.color)
    case 2:
      cell.setContentViewColor(to: Asset.Colors.canaryYellow.color)
    case 3:
      cell.setContentViewColor(to: Asset.Colors.fieldGreen.color)
    case 4:
      cell.setContentViewColor(to: Asset.Colors.lushPurple.color)
    default:
      cell.setContentViewColor(to: Asset.Colors.testViewFill.color)
    }
  }
}
