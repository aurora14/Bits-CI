//
//  UIButton+ViewConfigurable.swift
//  bitrise unofficial ios
//
//  Created by Alexei Gudimenko on 15/8/18.
//  Copyright © 2018 Alexei Gudimenko. All rights reserved.
//

import UIKit

@IBDesignable
extension UIButton: ViewConfigurable {
  
  @IBInspectable
  var borderColor: UIColor {
    get {
      return UIColor(cgColor: layer.borderColor ?? UIColor.clear.cgColor)
    }
    set {
      layer.borderColor = newValue.cgColor
    }
  }
  
  @IBInspectable
  var borderWidth: CGFloat {
    get {
      return layer.borderWidth
    }
    set {
      layer.borderWidth = newValue
    }
  }
  
  @IBInspectable
  var cornerRadius: CGFloat {
    get {
      return layer.cornerRadius
    }
    set {
      layer.cornerRadius = newValue
    }
  }
  
  func setup(with viewModel: ViewRepresentable?) {
    setNeedsDisplay()
  }

}
