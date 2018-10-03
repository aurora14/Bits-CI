//
//  BuildLogViewController.swift
//  bitrise unofficial ios
//
//  Created by Alexei Gudimenko on 26/9/18.
//  Copyright © 2018 Alexei Gudimenko. All rights reserved.
//

import UIKit
import XLPagerTabStrip

class BuildLogViewController: TabPageViewController {
  
  var buildVM: ProjectBuildViewModel
  
  init(itemInfo: IndicatorInfo, forBuildViewModel buildVM: ProjectBuildViewModel) {
    self.buildVM = buildVM
    super.init(itemInfo: itemInfo)
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

}

