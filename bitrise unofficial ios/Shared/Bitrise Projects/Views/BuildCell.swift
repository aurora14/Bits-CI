//
//  BuildCell.swift
//  bitrise unofficial ios
//
//  Created by Alexei Gudimenko on 20/7/18.
//  Copyright © 2018 Alexei Gudimenko. All rights reserved.
//

import UIKit

class BuildCell: UITableViewCell, ViewConfigurable {
  
  
  @IBOutlet weak var buildStatusStrip: UIView!
  @IBOutlet weak var buildStatusIcon: UIImageView!
  @IBOutlet weak var buildStatusTextLabel: UILabel!
  @IBOutlet weak var repoBranchIcon: UIImageView!
  @IBOutlet weak var repoBranchNameLabel: UILabel!
  @IBOutlet weak var workflowIcon: UIImageView!
  @IBOutlet weak var workflowNameLabel: UILabel!
  @IBOutlet weak var buildTriggeredTimeLabel: UILabel!
  @IBOutlet weak var buildDurationIcon: UIImageView!
  @IBOutlet weak var buildDurationLabel: UILabel!
  @IBOutlet weak var bitriseBuildNumberLabel: UILabel!
  @IBOutlet weak var separatorView: UIView!
  @IBOutlet weak var contentContainer: ContentContainer!
  
  var borderColor: UIColor = UIColor.black
  
  var borderWidth: CGFloat = 0
  
  var cornerRadius: CGFloat = 3
  
  override var frame: CGRect {
    get {
      return super.frame
    }
    set (newFrame) {
      var frame = newFrame
      frame.origin.y += 2.0
      frame.size.height -= 2.0
      super.frame = frame
    }
  }
  
  override func awakeFromNib() {
    super.awakeFromNib()
    // Initialization code
  }
  
  override func setSelected(_ selected: Bool, animated: Bool) {
    super.setSelected(selected, animated: animated)
    
    // Configure the view for the selected state
  }
  
  func setup(with viewModel: ViewRepresentable?) {
    
    guard let vm = viewModel as? ProjectBuildViewModel else {
      assertionFailure("Incorrect view model selected for cell \(self.debugDescription)")
      return
    }
    
    buildStatusTextLabel.text = vm.buildStatusText
    repoBranchNameLabel.text = vm.branch
    workflowNameLabel.text = vm.workflow
    buildTriggeredTimeLabel.text = vm.buildTriggeredAt
    buildDurationLabel.text = vm.duration
    bitriseBuildNumberLabel.text = vm.buildNumber
    buildStatusIcon.image = vm.buildStatusIcon
    
    // this must be on the main thread for the colour updates to take effect immediately
    DispatchQueue.main.async { 
      self.buildStatusStrip.backgroundColor = vm.buildStatusColor
      self.buildStatusTextLabel.textColor = vm.buildStatusColor
      
      self.buildStatusStrip.setNeedsDisplay()
      self.buildStatusTextLabel.setNeedsDisplay()
    }
    
    contentContainer.layer.cornerRadius = 3
    
    setWorkflowLabelAppearance()
  }
  
  
  private func setWorkflowLabelAppearance() {
    let layer = workflowNameLabel.layer
    layer.cornerRadius = 3
    layer.borderColor = Asset.Colors.bitriseGrey.color.cgColor
    layer.borderWidth = 1
  }
}
