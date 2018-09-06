//
//  BuildListViewController.swift
//  bitrise unofficial ios
//
//  Created by Alexei Gudimenko on 18/7/18.
//  Copyright © 2018 Alexei Gudimenko. All rights reserved.
//

import UIKit
import XLPagerTabStrip

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
}

extension BuildListViewController {
  
  @objc fileprivate func refreshBuilds() {
    App.sharedInstance.apiClient.getBuilds(for: projectVM.app) { _, buildList, _ in
      self.projectVM.buildList = buildList ?? []
      DispatchQueue.main.async {
        self.tableView.reloadData()
      }
    }
  }
}
