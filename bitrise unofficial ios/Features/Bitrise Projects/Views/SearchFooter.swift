//
//  SearchFooter.swift
//  bitrise unofficial ios
//
//  Created by Alexei Gudimenko on 25/6/18.
//

/*
 * Copyright (c) 2017 Razeware LLC - with modification by Alexei Gudimenko
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */

import UIKit

class SearchFooter: UIView {
  
  let label = UILabel()
  let container = UIView()
  
  override public init(frame: CGRect) {
    super.init(frame: frame)
    configureView()
  }
  
  required public init?(coder: NSCoder) {
    super.init(coder: coder)
    configureView()
  }
  
  func configureView() {
    
//    backgroundColor = Asset.Colors.bitriseGreen.color
    backgroundColor = .clear
    alpha = 0.0
    
    // Configure container
    container.frame = frame
    container.frame.origin.x += 6
    container.frame.origin.y += 4
    //container.frame.size.width -= 6
    
    container.backgroundColor = Asset.Colors.bitriseGreen.color
    
    container.layer.cornerRadius = 6
    container.layer.masksToBounds = true
    container.layer.maskedCorners = [
      .layerMaxXMaxYCorner,
      .layerMaxXMinYCorner,
      .layerMinXMaxYCorner,
      .layerMinXMinYCorner
    ]

    container.clipsToBounds = true
    // Configure label
    label.textAlignment = .center
    label.textColor = UIColor.white
    label.frame = container.frame
    
    container.addSubview(label)
    addSubview(container)
    
  }
  
  override func draw(_ rect: CGRect) {
    label.frame = self.bounds
  }
  
  // MARK: - Animation
  
  fileprivate func hideFooter() {
    UIView.animate(withDuration: 0.7) {[unowned self] in
      self.alpha = 0.0
    }
  }
  
  fileprivate func showFooter() {
    UIView.animate(withDuration: 0.7) {[unowned self] in
      self.alpha = 1.0
    }
  }
}

extension SearchFooter {
  // MARK: - Public API
  
  public func setNotFiltering() {
    label.text = L10n.showingAllApps
    hideFooter()
  }
  
  public func setIsFilteringToShow(filteredItemCount: Int, of totalItemCount: Int) {
    if filteredItemCount == totalItemCount {
      setNotFiltering()
    } else if filteredItemCount == 0 {
      label.text = "No items match your query"
      showFooter()
    } else {
      label.text = "Filtering \(filteredItemCount) of \(totalItemCount)"
      showFooter()
    }
  }
  
}
