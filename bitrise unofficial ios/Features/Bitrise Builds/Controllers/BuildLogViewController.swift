//
//  BuildLogViewController.swift
//  bitrise unofficial ios
//
//  Created by Alexei Gudimenko on 26/9/18.
//  Copyright © 2018 Alexei Gudimenko. All rights reserved.
//

import UIKit
import XLPagerTabStrip

/// Presents a scene containing the build's log. Currently the log is fetched from the API.
/// By default the API returns a single chunk; this is the trailing part of the log, as
/// you'd see on Bitrise.io without expanding the log to its full version.
///
/// For now, we'll just call the API every time. In the future we'll cache the logs, tagging the cache
/// entries with the build slug for easy retrieval.
class BuildLogViewController: TabPageViewController {
  
  var logTextLabel: UILabel?
  var buildVM: ProjectBuildViewModel
  
  init(itemInfo: IndicatorInfo, forBuildViewModel buildVM: ProjectBuildViewModel) {
    self.buildVM = buildVM
    super.init(itemInfo: itemInfo)
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    setupLogsLabel()
  }

  private func setupLogsLabel() {
    let margins = view.layoutMarginsGuide
    
    logTextLabel = UILabel(frame: .zero)
    
    guard let l = logTextLabel else {
      assertionFailure("Label showing log content couldn't be initialised")
      return
    }
    
    logTextLabel?.text = "Log content goes here"
    
    view.addSubview(l) // make sure you add the label to the parent view before adding constraints
    
    logTextLabel?.translatesAutoresizingMaskIntoConstraints = false
    
    logTextLabel?.leadingAnchor.constraint(equalTo: margins.leadingAnchor, constant: 16).isActive = true
    logTextLabel?.trailingAnchor.constraint(equalTo: margins.trailingAnchor, constant: -16).isActive = true
    logTextLabel?.topAnchor.constraint(equalTo: margins.topAnchor, constant: 0).isActive = true
    logTextLabel?.bottomAnchor.constraint(equalTo: margins.bottomAnchor, constant: 0).isActive = true
    
  }
}

