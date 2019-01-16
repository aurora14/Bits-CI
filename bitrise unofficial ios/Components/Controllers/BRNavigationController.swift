//
//  BRNavigationController.swift
//  bitrise unofficial ios
//
//  Created by Alexei Gudimenko on 26/9/18.
//  Copyright © 2018 Alexei Gudimenko. All rights reserved.
//

import UIKit

/// Component build on top of UINavigationController to provide any necessary
/// customisations that either aren't accessible normally or would need to be
/// modified for every usage of a standard UINavigationController
class BRNavigationController: UINavigationController {
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    // Set the background of the containing view to the main interface background
    // colour. In our case it's white, but may alter.
    // TODO: - set this property depending on the light or dark theme, once themes
    // are supported.
    view.backgroundColor = .white
  }

}
