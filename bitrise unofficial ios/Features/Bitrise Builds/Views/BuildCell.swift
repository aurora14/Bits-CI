//
//  BuildCell.swift
//  bitrise unofficial ios
//
//  Created by Alexei Gudimenko on 20/7/18.
//  Copyright © 2018 Alexei Gudimenko. All rights reserved.
//

import UIKit

class BuildCell: UITableViewCell, ViewConfigurable {

  // - General info
  @IBOutlet private var bitriseBuildNumberLabel: UILabel!
  @IBOutlet private var repoBranchIcon: UIImageView!
  @IBOutlet private var repoBranchNameLabel: UILabel!
  @IBOutlet private var workflowIcon: UIImageView!
  @IBOutlet private var workflowNameLabel: UILabel!
  @IBOutlet private var buildTriggeredTimeLabel: UILabel!
  @IBOutlet private var buildDurationIcon: UIImageView!
  @IBOutlet private var buildDurationLabel: UILabel!

  // - Build status
  @IBOutlet private var buildStatusStrip: UIView!
  @IBOutlet private var buildStatusIcon: UIImageView!
  @IBOutlet private var buildStatusTextLabel: UILabel!

  // - Commit messages
  @IBOutlet private var commitMessageLabel: UILabel!
  @IBOutlet private var commitURLTextView: UITextView!

  // - Containers
  @IBOutlet private var contentContainer: ContentContainer!
  @IBOutlet private var branchAndWorkflowStackView: UIStackView!
  
  // View Configurable conformance
  internal var borderColor: UIColor = UIColor.black
  internal var borderWidth: CGFloat = 0
  internal var cornerRadius: CGFloat = 3
  
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

  override func layoutSubviews() {
    super.layoutSubviews()

    self.commitMessageLabel.sizeToFit()
    self.commitURLTextView.textContainerInset = .zero
    self.commitURLTextView.textContainer.lineFragmentPadding = 0

    if self.commitURLTextView.attributedText.string.isEmpty {
      self.commitURLTextView.sizeThatFits(.zero)
    } else {
      self.commitURLTextView.sizeThatFits(commitURLTextView.intrinsicContentSize)
    }
  }
  
  func setup(with viewModel: ViewRepresentable?) {
    
    guard let vm = viewModel as? ProjectBuildViewModel else {
      assertionFailure("Incorrect view model selected for cell \(self.debugDescription)")
      return
    }

    self.updateText(with: vm)
    
    // this must be on the main thread for the colour updates to take effect immediately
    DispatchQueue.main.async {
      self.buildStatusIcon.image = vm.buildStatusIcon
      self.buildStatusStrip.backgroundColor = vm.buildStatusColor
      self.buildStatusTextLabel.textColor = vm.buildStatusColor
      
      self.buildStatusStrip.setNeedsDisplay()
      self.buildStatusTextLabel.setNeedsDisplay()
    }
    
    self.contentContainer.layer.cornerRadius = self.cornerRadius

    self.branchAndWorkflowStackView.setCustomSpacing(4, after: self.workflowIcon)
    
    self.setWorkflowLabelAppearance()
  }

  private func updateText(with viewModel: ProjectBuildViewModel) {
    buildStatusTextLabel.text = viewModel.buildStatusText
    repoBranchNameLabel.text = viewModel.branch
    workflowNameLabel.text = viewModel.workflow
    buildTriggeredTimeLabel.text = viewModel.buildTriggeredAt
    buildDurationLabel.text = viewModel.duration
    bitriseBuildNumberLabel.text = viewModel.buildNumber

    self.commitMessageLabel.attributedText = viewModel.commitMessage

    if let urlAttrString = viewModel.commitURL {
      self.commitURLTextView.attributedText = urlAttrString
    } else {
      self.commitURLTextView.isHidden = true
    }

    self.setNeedsLayout()
    self.layoutIfNeeded()
  }

  private func setWorkflowLabelAppearance() {
    let layer = workflowNameLabel.layer
    layer.cornerRadius = self.cornerRadius
    layer.borderColor = Asset.Colors.bitriseGrey.color.cgColor
    layer.borderWidth = 1
  }
}
