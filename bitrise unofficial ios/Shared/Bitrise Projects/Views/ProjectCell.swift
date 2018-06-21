//
//  ProjectCell.swift
//  bitrise-unofficial-ios
//
//  Created by Alexei Gudimenko on 13/6/18.
//  Copyright © 2018 Alexei Gudimenko. All rights reserved.
//

import UIKit

class ProjectCell: UITableViewCell, ViewConfigurable {
  
  @IBOutlet weak var projectIconImageView: UIImageView!
  
  @IBOutlet weak var projectNameLabel: UILabel!
  
  var borderColor: UIColor = .clear
  
  var borderWidth: CGFloat = 0
  
  var cornerRadius: CGFloat = 0
  
  override var frame: CGRect {
    get {
      return super.frame
    }
    set (newFrame) {
      var frame = newFrame
      frame.origin.x += 6.0
      frame.origin.y += 4.0
      frame.size.width -= 12.0
      frame.size.height -= 4.0
      super.frame = frame
    }
  }
  
  func setup(with viewModel: ViewRepresentable?) {
    
    guard let vm = viewModel as? BitriseProjectViewModel else {
      print("*** Skipping view setup: invalid view model for Project List")
      return
    }
    
    projectNameLabel.text = vm.title
    
    setCornerRounding()
    setDropShadow()
  }
  
  private func setCornerRounding(withRadius value: CGFloat = 5) {
    contentView.layer.cornerRadius = value
    contentView.layer.masksToBounds = true
  }
  
  private func setDropShadow() {
    layer.shadowColor = UIColor.black.cgColor
    layer.shadowOpacity = 0.5
    layer.shadowOffset = CGSize(width: 0, height: 1)
    layer.shadowPath = UIBezierPath(roundedRect: bounds, cornerRadius: 10).cgPath
    layer.masksToBounds = false
  }
}
