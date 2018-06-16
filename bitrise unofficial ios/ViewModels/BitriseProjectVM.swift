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
  
  init(with app: BitriseApp) {
    self.app = app
  }
  
  func cellInstance(_ tableView: UITableView, indexPath: IndexPath) -> UITableViewCell {
    
    guard let cell = tableView
      .dequeueReusableCell(withIdentifier: "ProjectCell", for: indexPath) as? ProjectCell else {
        
        return UITableViewCell(style: .default, reuseIdentifier: "ProjectCell")
    }
    
    cell.setup(with: self)
    
    // May be replaced with project status, depending on design and API - alternatively might give
    // user the option of how they want projects colored
    setDefaultBackgroundColor(in: cell, for: indexPath)
    
    return cell
  }
  
  private func setDefaultBackgroundColor(in cell: UITableViewCell, for indexPath: IndexPath) {
    
    print("*** Set default background colours")
    
    switch indexPath.section % 5 {
    case 0:
      cell.setContentViewColor(to: UIColor(named: "LightBlue"))
    case 1:
      cell.setContentViewColor(to: UIColor(named: "SaladGreen"))
    case 2:
      cell.setContentViewColor(to: UIColor(named: "CanaryYellow"))
    case 3:
      cell.setContentViewColor(to: UIColor(named: "FieldGreen"))
    case 4:
      cell.setContentViewColor(to: UIColor(named: "LushPurple"))
    default:
      cell.setContentViewColor(to: UIColor(named: "TestViewFill"))
    }
  }
}
