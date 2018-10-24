//
//  ProfileHeaderView.swift
//  bitrise unofficial ios
//
//  Created by Alexei Gudimenko on 26/7/18.
//  Copyright © 2018 Alexei Gudimenko. All rights reserved.
//

import UIKit
import Lottie

class ProfileHeaderView: UIView {
  
  // Profile UI elements
  @IBOutlet weak var backgroundImageView: UIImageView!
  @IBOutlet weak var foregroundImageView: UIImageView!
  @IBOutlet weak var usernameLabel: UILabel!
  @IBOutlet weak var welcomeLabel: UILabel!
  
  // Blur UI elements
  @IBOutlet weak var foundationVisualEffectView: UIVisualEffectView!
  @IBOutlet weak var vibrancyVisualEffectView: UIVisualEffectView!
  
  // Constraints for username label
  @IBOutlet weak var usernameTopSpacingConstraint: NSLayoutConstraint!
  @IBOutlet weak var usernameLeadingConstraint: NSLayoutConstraint!
  @IBOutlet weak var usernameTrailingConstraint: NSLayoutConstraint!
  @IBOutlet weak var usernameHeightConstraint: NSLayoutConstraint!
  @IBOutlet weak var profileImageTopSpacingConstraint: NSLayoutConstraint!
  
  
  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    usernameLabel?.adjustsFontSizeToFitWidth = true
  }
  
  class func instanceFromNib() -> ProfileHeaderView? {
    
    guard let profileHeaderView = UINib(nibName: "ProfileHeaderView", bundle: nil)
      .instantiate(withOwner: nil, options: nil)[0] as? ProfileHeaderView else {
        assertionFailure("Couldn't instantiate Profile View from provided NIB file")
        return nil
    }
    
    return profileHeaderView
  }
  
}
