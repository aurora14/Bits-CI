//
//  ProjectCell.swift
//  bitrise-unofficial-ios
//
//  Created by Alexei Gudimenko on 13/6/18.
//  Copyright © 2018 Alexei Gudimenko. All rights reserved.
//

import UIKit
import CoreMotion

class ProjectCell: UITableViewCell, ViewConfigurable {
  
  @IBOutlet weak var projectIconImageView: UIImageView!
  @IBOutlet weak var projectNameLabel: UILabel!
  @IBOutlet weak var projectOwnerLabel: UILabel!
  @IBOutlet weak var contentContainer: ContentContainer!
  @IBOutlet weak var buildNumberLabel: UILabel!
  @IBOutlet weak var buildStatusStrip: UIView!
  @IBOutlet weak var buildStatusImageView: UIImageView!
  @IBOutlet weak var timeElapsedSinceLastBuildLabel: UILabel!
  
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
      frame.origin.y += 2.0
      frame.size.width -= 12.0
      frame.size.height -= 2.0
      super.frame = frame
    }
  }
  
  fileprivate let motionManager = CMMotionManager()
  
  fileprivate var longPressGestureRecognizer: UILongPressGestureRecognizer?
  
  fileprivate var isPressed = false
  
  override func awakeFromNib() {
    super.awakeFromNib()
    // Initialization code
    // showAllSkeletons()
    if longPressGestureRecognizer == nil {
      setupLongGestureRecognizer()
    }
  }
  
  func setup(with viewModel: ViewRepresentable?) {
    
    guard let vm = viewModel as? BitriseProjectViewModel else {
      print("*** Skipping view setup: invalid view model for Project List")
      hideAllSkeletons()
      return
    }
    
    setBasicInfo(from: vm)
    setImages(from: vm.app)
    setLastBuildViews(from: vm)
    setCornerRounding()
    setDropShadow()
    
    if longPressGestureRecognizer == nil {
      setupLongGestureRecognizer()
    }
    
    if vm.isReady { hideAllSkeletons() }
  }
  
  private func setCornerRounding(withRadius value: CGFloat = 5) {
    contentView.layer.cornerRadius = value
    contentView.layer.masksToBounds = true
//    buildStatusStrip.layer.cornerRadius = value
//    buildStatusStrip.layer.maskedCorners = [ .layerMinXMinYCorner, .layerMinXMaxYCorner ]
  }
  
  private func setDropShadow() {
    layer.shadowColor = UIColor.black.cgColor
    layer.shadowOpacity = 0.25
    layer.shadowOffset = CGSize(width: 0, height: 3)
    layer.shadowPath = UIBezierPath(roundedRect: bounds, cornerRadius: cornerRadius).cgPath
    layer.masksToBounds = false
  }
  
  private func setBasicInfo(from vm: BitriseProjectViewModel) {
    projectNameLabel.text = vm.title
    projectOwnerLabel.text = vm.projectOwner
  }
  
  private func setImages(from app: BitriseApp) {

    // TODO: - don't set this in the cell, get the viewmodel to return an image. Cell doesn't need to know about anything
    // other than what it needs to show. 
    guard let projectType = app.projectType else {
      print("*** App doesn't have project type")
      return
    }
    
    switch projectType.lowercased() {
    case "ios", "macos": // TODO: - find more appropriate Mac OS icon to diff between mobile & desktop
      projectIconImageView.image = Asset.Icons.applicationIosGrey.image
    case "android":
      projectIconImageView.image = Asset.Icons.applicationAndroidGrey.image
    case "xamarin":
      projectIconImageView.image = Asset.Icons.applicationXamarinGrey.image
    case "react-native":
      projectIconImageView.image = Asset.Icons.applicationReactGrey.image
    default:
      projectIconImageView.image = Asset.Icons.applicationDefault.image
    }
  }
  
  private func setLastBuildViews(from vm: BitriseProjectViewModel) {
    
    buildNumberLabel.text = vm.lastBuildNumber
    buildStatusImageView.image = vm.buildStatusIcon
    timeElapsedSinceLastBuildLabel.text = vm.lastBuildTime
    
    DispatchQueue.main.async {
      self.buildStatusStrip.hideSkeleton()
      self.buildNumberLabel.textColor = vm.buildStatusColor
      self.buildStatusStrip.backgroundColor = vm.buildStatusColor
    }
  }
  
}


extension ProjectCell {
  
  fileprivate func showAllSkeletons() {
    if !contentContainer.isReadyToHideSkeleton {
      DispatchQueue.main.async {
        self.projectIconImageView.showAnimatedSkeleton()
        self.projectNameLabel.showAnimatedSkeleton()
        self.projectOwnerLabel.showAnimatedSkeleton()
        self.buildNumberLabel.showAnimatedSkeleton()
        self.timeElapsedSinceLastBuildLabel.showAnimatedSkeleton()
        self.buildStatusImageView.showAnimatedSkeleton()
        //self.contentContainer.showAnimatedGradientSkeleton()
      }
    }
  }
  
  fileprivate func hideAllSkeletons() {
    DispatchQueue.main.async {
      self.contentContainer.isReadyToHideSkeleton = true
      self.projectIconImageView.hideSkeleton()
      self.projectNameLabel.hideSkeleton()
      self.projectOwnerLabel.hideSkeleton()
      self.buildNumberLabel.hideSkeleton()
      self.timeElapsedSinceLastBuildLabel.hideSkeleton()
      self.buildStatusImageView.hideSkeleton()
    }
  }
}

// MARK: - Long Press handling (including animation)
// REF: - https://github.com/phillfarrugia/appstore-clone/blob/master/AppStoreClone/CollectionViewCells/BaseRoundedCardCell.swift
extension ProjectCell {
  
  override func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
    
    return gestureRecognizer == longPressGestureRecognizer
  }
  
  fileprivate func setupLongGestureRecognizer() {
    longPressGestureRecognizer =
      UILongPressGestureRecognizer(target: self, action: #selector(handleLongPressGesture(gestureRecognizer:)))
    longPressGestureRecognizer?.minimumPressDuration = 0.1
    
    longPressGestureRecognizer?.delegate = self
    
    if let r = longPressGestureRecognizer {
      addGestureRecognizer(r)
    }
  }
  
  @objc fileprivate func handleLongPressGesture(gestureRecognizer: UILongPressGestureRecognizer) {
    switch gestureRecognizer.state {
    case .began:
      longPressBegan()
    case .ended:
      longPressEnded()
    default:
      print("*** Handle LP Gesture: - Gesture Recognizer State [\(gestureRecognizer.state)]")
    }
  }
  
  fileprivate func longPressBegan() {
    if isPressed { return }
    
    isPressed = true
    
    UIView.animate(withDuration: 0.5,
                   delay: 0.0,
                   usingSpringWithDamping: 0.8,
                   initialSpringVelocity: 0.2,
                   options: .beginFromCurrentState,
                   animations: {
                    self.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
    }, completion: { _ in
      
    })
  }
  
  fileprivate func longPressEnded() {
    guard isPressed else { return }
    
    UIView.animate(withDuration: 0.5,
                   delay: 0.0,
                   usingSpringWithDamping: 0.4,
                   initialSpringVelocity: 0.2,
                   options: .beginFromCurrentState,
                   animations: {
                    self.transform = CGAffineTransform.identity
    }, completion: { _ in
      self.isPressed = false
    })
  }
}
