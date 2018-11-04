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
    
    // Do any additional setup after loading the view.
    setupTextView()
  }
  
  
  private func setupTextView() {
    
    setupTextViewDimensions()
    setupTextViewContentManagement()
    updateTextViewContent()
    presentTextView()
   
  }
  
  
  private func setupTextViewDimensions() {
    ymlTextView = UITextView(frame: CGRect(
      x: view.frame.origin.x,
      y: view.frame.origin.y,
      width: view.frame.size.width,
      height: view.frame.size.height - 204) //large title + std nav bar + status bar + tab bar
    )
    ymlTextView?.textContainerInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
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
