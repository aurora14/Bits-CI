//
//  BuildListViewController.swift
//  bitrise unofficial ios
//
//  Created by Alexei Gudimenko on 18/7/18.
//  Copyright © 2018 Alexei Gudimenko. All rights reserved.
//

import UIKit
import XLPagerTabStrip
import SVProgressHUD

class BuildListViewController: TabPageTableViewController {

  var projectVM: BitriseProjectViewModel
  
  let selectionFeedbackGenerator = UISelectionFeedbackGenerator()
  
  init(style: UITableView.Style, itemInfo: IndicatorInfo, forAppViewModel appVM: BitriseProjectViewModel) {
    projectVM = appVM
    super.init(style: style, itemInfo: itemInfo)
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    tableView.register(UINib(nibName: "BuildCell", bundle: nil), forCellReuseIdentifier: "BuildCell")
    tableView.separatorStyle = .singleLine
    tableView.separatorInset = .zero
    
    selectionFeedbackGenerator.prepare()
    
    NotificationCenter.default.addObserver(self,
                                           selector: #selector(refreshBuilds),
                                           name: .didStartNewBuildNotification,
                                           object: nil)
  }
  
  deinit {
    NotificationCenter.default.removeObserver(self,
                                              name: .didStartNewBuildNotification,
                                              object: nil)
  }
  
  @objc private func updateViews() {
    selectionFeedbackGenerator.selectionChanged()
    tableView.reloadData()
  }
}

// MARK: - table view datasource
extension BuildListViewController {
  
  override func numberOfSections(in tableView: UITableView) -> Int {
    return projectVM.buildList.count
  }
  
  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return 1
  }
  
  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    return projectVM.buildList[indexPath.section].cellInstance(tableView, indexPath: indexPath)
  }
  
  override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    return projectVM.buildList[indexPath.section].rowHeight
  }
  
  override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
    return 4
  }
}

// MARK: - table view delegate
extension BuildListViewController {
  
  override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    tableView.deselectRow(at: indexPath, animated: true)
  }
  
  override func tableView(_ tableView: UITableView,
                          leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
    
    let build = projectVM.buildList[indexPath.section].build
    
    guard let buildStatus = build.status else { return nil }
    
    switch buildStatus {
    case .inProgress:
      return createSwipeConfiguration(forRequestAction: .abort, forRowAt: indexPath)
    default:
      return nil
    }
    
  }
  
  override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
    return createSwipeConfiguration(forRequestAction: .rebuild, forRowAt: indexPath)
  }
  
  @available(iOS 11.0, *)
  /// <#Description#>
  ///
  /// - Parameters:
  ///   - action: <#action description#>
  ///   - indexPath: <#indexPath description#>
  /// - Returns: <#return value description#>
  private func createSwipeConfiguration(forRequestAction action: BuildAction, forRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
    
    guard !projectVM.buildList.isEmpty else {
      return nil
    }
    
    switch action {
    case .abort:
      // TODO: - refine this behaviour. Currently the side menu behaviour overrides the swipe to the right, so swipe to the left needs to
      // function in a similar manner to the way it does on iOS 10
      let build = projectVM.buildList[indexPath.section].build
      let abort = UIContextualAction(style: .destructive, title: action.title,
                                      handler: { _, _, success in
                                        self.abortBuild(withID: build.slug, forAppID: self.projectVM.app.slug)
                                        success(true)
      })
      abort.backgroundColor = action.color
      //abort.image = action.icon
      return UISwipeActionsConfiguration(actions: [abort])
    case .rebuild:
      let rebuild = UIContextualAction(style: .normal, title: action.title, handler: { _, _, success in
        self.rebuild(at: indexPath)
        success(true)
      })
      rebuild.backgroundColor = action.color
      //rebuild.image = action.icon
      return UISwipeActionsConfiguration(actions: [rebuild])
    }
  }
}

extension BuildListViewController {
  
  @objc fileprivate func refreshBuilds() {
    App.sharedInstance.apiClient.getBuilds(for: projectVM.app) { _, buildList, _ in
      // TODO: - add a temporary status update strip that shows the fetching status
      self.projectVM.buildList = buildList ?? []
      DispatchQueue.main.async {
        self.tableView.reloadData()
      }
    }
  }
  
  @objc fileprivate func abortBuild(withID buildSlug: Slug, forAppID appSlug: Slug) {
    
    let abortParams = AbortBuildParams(
      abortReason: "Cancelled via the mobile app",
      abortWithSuccess: true,
      skipNotifications: true)
    
    App.sharedInstance.apiClient.abortBuild(for: buildSlug, inApp: appSlug, withParams: abortParams) {
      self.refreshBuilds()
    }
  }
  
  @objc fileprivate func rebuild(at indexPath: IndexPath) {
    
    let build = projectVM.buildList[indexPath.section].build
    
    DispatchQueue.main.async {
      SVProgressHUD.setDefaultStyle(.dark)
      SVProgressHUD.show(withStatus: "Starting Build")
    }
    
    // create a new parameter payload.
    let buildData = BuildData(
      branch: build.branch,
      workflowId: build.triggeredWorkflow,
      commitMessage: build.commitMessage ?? "",
      commitHash: build.commitHash ?? "")
    
    App.sharedInstance.apiClient
      .startNewBuild(for: projectVM.app, withBuildParams: buildData) { _, _ in
        DispatchQueue.main.async {
          SVProgressHUD.dismiss()
          self.refreshBuilds()
        }
    }
  }
}
