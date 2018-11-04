//
//  BitriseYMLViewController.swift
//  bitrise unofficial ios
//
//  Created by Alexei Gudimenko on 18/7/18.
//  Copyright © 2018 Alexei Gudimenko. All rights reserved.
//

import UIKit
import XLPagerTabStrip
import FirebasePerformance

class BitriseYMLViewController: TabPageViewController {
  
  var ymlTextView: UITextView?
  var projectVM: BitriseProjectViewModel
  
  var ymlText: String?
  
  init(itemInfo: IndicatorInfo, forAppViewModel appVM: BitriseProjectViewModel) {
    let trace = Performance.startTrace(name: "YML Initialisation")
    projectVM = appVM
    super.init(itemInfo: itemInfo)
    trace?.stop()
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    setupTextView()
  }
  
  
  private func setupTextView() {
    
    createTextView()
    setupTextViewContentManagement()
    setupTextViewConstraints()
    updateTextViewContent()
   
  }
  
  
  private func createTextView() {
    ymlTextView = UITextView(frame: .zero)
    ymlTextView?.textContainerInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
    view.addSubview(self.ymlTextView!)
  }
  
  
  private func setupTextViewConstraints() {
    
    let margins = view.layoutMarginsGuide
    
    ymlTextView?.translatesAutoresizingMaskIntoConstraints = false
    
    ymlTextView?.leadingAnchor.constraint(equalTo: margins.leadingAnchor, constant: 0).isActive = true
    ymlTextView?.trailingAnchor.constraint(equalTo: margins.trailingAnchor, constant: 0).isActive = true
    ymlTextView?.topAnchor.constraint(equalTo: margins.topAnchor, constant: 0).isActive = true
    ymlTextView?.bottomAnchor.constraint(equalTo: margins.bottomAnchor, constant: 0).isActive = true
    
  }
  
  
  private func setupTextViewContentManagement() {
    ymlTextView?.autocorrectionType = .no
    ymlTextView?.dataDetectorTypes = .link
    ymlTextView?.autocapitalizationType = .none
    ymlTextView?.isEditable = false
  }
  
  
  private func updateTextViewContent() {
    guard let yml = ymlText else {
      ymlTextView?.text = "Bitrise YML isn't available for this application"
      return
    }
    let trace = Performance.startTrace(name: "Populating YML Text View")
    ymlTextView?.text = yml
    trace?.stop()
  }
  
  
  private func presentTextView() {
    DispatchQueue.main.async {
      self.view.addSubview(self.ymlTextView!)
    }
  }
  
}
