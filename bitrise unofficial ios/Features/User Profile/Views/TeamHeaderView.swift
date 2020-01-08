//
//  TeamHeaderView.swift
//  bitrise unofficial ios
//
//  Created by Alexei Gudimenko on 16/1/19.
//  Copyright © 2019 Alexei Gudimenko. All rights reserved.
//

import UIKit

class TeamHeaderView: UIView {
  
  @IBOutlet weak var titleLabel: UILabel!
  
  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    backgroundColor = UIColor(white: 0.9, alpha: 0.66)
  }
}
