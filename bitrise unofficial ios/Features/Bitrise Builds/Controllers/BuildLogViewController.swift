//
//  BuildLogViewController.swift
//  bitrise unofficial ios
//
//  Created by Alexei Gudimenko on 26/9/18.
//  Copyright © 2018 Alexei Gudimenko. All rights reserved.
//

import UIKit
import XLPagerTabStrip
import SVProgressHUD

/// Presents a scene containing the build's log. Currently the log is fetched from the API.
/// By default the API returns a single chunk; this is the trailing part of the log, as
/// you'd see on Bitrise.io without expanding the log to its full version.
///
/// For now, we'll just call the API every time. In the future we'll cache the logs, tagging the cache
/// entries with the build slug for easy retrieval.
class BuildLogViewController: TabPageViewController {
  
  var logTextView: UITextView?
  var buildVM: ProjectBuildViewModel
  
  var log: BuildLog?
  
  // these vars are the in-memory cache for the log text contents.
  private var shortLogVersion: String = ""
  private var fullLogVersion: String = ""
  
  // MARK: - Initialisers
  init(itemInfo: IndicatorInfo, forBuildViewModel buildVM: ProjectBuildViewModel) {
    self.buildVM = buildVM
    super.init(itemInfo: itemInfo)
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  // MARK: - View lifecycle & setup
  override func viewDidLoad() {
    super.viewDidLoad()
    
    setupLogsTextView()
    
    guard let app = buildVM.app else { return }
    getBuildLog(forBuildID: buildVM.build.slug, forAppID: app.slug) {
      
    }
  }

  private func setupLogsTextView() {
    let margins = view.layoutMarginsGuide
    
    logTextView = UITextView(frame: .zero)
    
    guard let l = logTextView else {
      assertionFailure("Label showing log content couldn't be initialised")
      return
    }
    
    logTextView?.text = ""
    logTextView?.isEditable = false
    logTextView?.autocorrectionType = .no
    logTextView?.dataDetectorTypes = [ .link ]
    
    logTextView?.textContainerInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
    
    view.addSubview(l) // make sure you add the textview to the parent view before adding constraints
    
    logTextView?.translatesAutoresizingMaskIntoConstraints = false
    
    logTextView?.leadingAnchor.constraint(equalTo: margins.leadingAnchor, constant: 0).isActive = true
    logTextView?.trailingAnchor.constraint(equalTo: margins.trailingAnchor, constant: 0).isActive = true
    logTextView?.topAnchor.constraint(equalTo: margins.topAnchor, constant: 0).isActive = true
    logTextView?.bottomAnchor.constraint(equalTo: margins.bottomAnchor, constant: 0).isActive = true
    
  }
  
  // MARK: - Log retrieval and presentation
  private func getBuildLog(forBuildID buildID: Slug, forAppID appID: Slug, completion: @escaping () -> Void) {
    
    SVProgressHUD.setDefaultStyle(.dark)
    SVProgressHUD.show(Asset.Icons.projects.image, status: "Fetching the build log. Please wait...")
    
    App.sharedInstance.apiClient.getLog(forBuildID: buildID, inApp: appID) { _, log, message in
      
      print("ProjectBuildVM: Fetch log result - \(message) ")
      print("Log is archived: \(log?.isArchived)")
      
      SVProgressHUD.dismiss()
      
      guard let l = log else { return }
      
      self.updateUIWithContentsOf(l)
      
      // TODO: - fetch the full log using the temporary URL
      
    }
  }
  
  
  private func updateUIWithContentsOf(_ buildLog: BuildLog) {
    
    // Extract the text contents from the log chunks and save them.
    shortLogVersion = buildLog.logChunks.map { $0.chunk }.joined(separator: "\n")
    
    // Update the contents
    DispatchQueue.main.async {
      self.logTextView?.text = self.shortLogVersion
    }
  }
  
}

