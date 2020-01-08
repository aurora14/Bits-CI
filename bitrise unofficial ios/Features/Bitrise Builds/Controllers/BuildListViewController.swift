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

protocol BuildRowTapDelegate: class {
  func didSelectBuild(at indexPath: IndexPath)
}

class BuildListViewController: TabPageTableViewController {
  
  weak var buildRowTapDelegate: BuildRowTapDelegate?

  var projectVM: BitriseProjectViewModel
  
  var buildList: [ProjectBuildViewModel] {
    didSet {
      updateViews()
    }
  }
  
  let selectionFeedbackGenerator = UISelectionFeedbackGenerator()
  
  init(style: UITableView.Style, itemInfo: IndicatorInfo, forAppViewModel appVM: BitriseProjectViewModel) {
    projectVM = appVM
    buildList = projectVM.buildList
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
    DispatchQueue.main.async {
      self.selectionFeedbackGenerator.selectionChanged()
      self.tableView.reloadData()
    }
  }
}

// MARK: - Table view datasource
extension BuildListViewController {
  
  override func numberOfSections(in tableView: UITableView) -> Int {
    return buildList.count
  }
  
  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return 1
  }
  
  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    return buildList[indexPath.section].cellInstance(tableView, indexPath: indexPath)
  }
  
  override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    return buildList[indexPath.section].rowHeight
  }
  
  override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
    return 4
  }
}

// MARK: - Table view delegate
extension BuildListViewController {
  
  override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    tableView.deselectRow(at: indexPath, animated: true)
    buildRowTapDelegate?.didSelectBuild(at: indexPath)
    // access through parent, because Build List is contained in a pager controller and isn't
    // created in the storyboard. Of course we could change that or just use push() to invoke
    // the controller, but all the other navigation is done through segues, so this seemed to
    // be more consistent.
    //parent?.perform(segue: StoryboardSegue.Main.buildDetailSegue)
  }
  
  override func tableView(_ tableView: UITableView,
                          leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
    
    let build = buildList[indexPath.section].build
    
    guard let buildStatus = build.status else { return nil }
    
    switch buildStatus {
    case .inProgress:
      return createSwipeConfiguration(forRequestAction: .abort, forRowAt: indexPath)
    default:
      return nil
    }
    
  }
  
  override func tableView(_ tableView: UITableView,
                          trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
    return createSwipeConfiguration(forRequestAction: .rebuild, forRowAt: indexPath)
  }
  
  @available(iOS 11.0, *)
  /// Creates a swipe configuration for a cell. Used in conjunction with the leading and trailing
  /// swipe configuration methods. Currently returns a configuration object with a single action.
  /// In the future, there is consideration to make `action` into an array, so that multiple
  /// actions can be returned. 
  ///
  /// - Parameters:
  ///   - action: Build Action to create a configuration for.
  ///   - indexPath: path of the cell/item that the action is created for
  /// - Returns: A swipe configuration that can be used as a return in tableView(_:leadingSwipeActionsConfigurationForRowAt:) and its trailing configuration counterpart.
  private func createSwipeConfiguration(forRequestAction action: BuildAction,
                                        forRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
    
    if buildList.isEmpty { return nil }
    
    switch action {
    case .abort:
      let build = buildList[indexPath.section].build
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

// MARK: - Build action helpers
extension BuildListViewController {
  
  @objc fileprivate func refreshBuilds() {
    App.sharedInstance.apiClient.getBuilds(for: projectVM.app) { _, buildList, _ in
      // TODO: - add a temporary status update strip that shows the fetching status
      self.buildList = buildList ?? []
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
    
    let build = buildList[indexPath.section].build
    
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
        
        NotificationCenter
          .default
          .post(name: .didStartNewBuildNotification, object: self)
        
        DispatchQueue.main.async {
          SVProgressHUD.dismiss()
        }
    }
  }
}
