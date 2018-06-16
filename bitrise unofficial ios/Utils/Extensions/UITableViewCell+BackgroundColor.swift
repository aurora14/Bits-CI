//
//  UITableViewCell+BackgroundColor.swift
//  bitrise unofficial ios
//
//  Created by Alexei Gudimenko on 16/6/18.
//  Copyright © 2018 Alexei Gudimenko. All rights reserved.
//

import UIKit


extension UITableViewCell {
  
  
  func setContentViewColor(to color: UIColor?) {
    
    guard let color = color else {
      contentView.backgroundColor = .clear
      return
    }
    
    contentView.backgroundColor = color
  }
  
}
