//
//  ContentContainer.swift
//  bitrise unofficial ios
//
//  Created by Alexei Gudimenko on 15/6/18.
//  Copyright © 2018 Alexei Gudimenko. All rights reserved.
//


import UIKit

@IBDesignable
class ContentContainer: UIView, ViewConfigurable {
  
  
  @IBInspectable
  var borderColor: UIColor = .clear {
    didSet {
      layer.borderColor = borderColor.cgColor
    }
  }
  
  
  @IBInspectable
  var borderWidth: CGFloat = 1 {
    didSet {
      layer.borderWidth = borderWidth
    }
  }
  
  
  @IBInspectable
  var cornerRadius: CGFloat = 3 {
    didSet {
      return layer.cornerRadius = cornerRadius
    }
  }
  
  
  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    setup()
  }
  
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    setup()
  }
  
  
  override func awakeFromNib() {
    setup()
  }
  
  
  override func layoutSubviews() {
    super.layoutSubviews()
    setup()
  }
  
  
  func setup(with viewModel: ViewRepresentable? = nil) {
    
    layer.cornerRadius = cornerRadius
    layer.borderColor = borderColor.cgColor
    layer.borderWidth = borderWidth
    
    setNeedsDisplay()
  }
  
}
