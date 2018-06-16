//
//  ViewConfigurable.swift
//  bitrise unofficial ios
//
//  Created by Alexei Gudimenko on 12/6/18.
//  Copyright © 2018 Alexei Gudimenko. All rights reserved.
//

import UIKit

protocol ViewConfigurable {
  
  var borderColor: UIColor { get set }
  var borderWidth: CGFloat { get set }
  var cornerRadius: CGFloat { get set }
  
  func setup(with viewModel: ViewRepresentable?) 
}
