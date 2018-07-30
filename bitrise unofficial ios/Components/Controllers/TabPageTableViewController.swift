//
//  TabPageTableViewController.swift
//  bitrise unofficial ios
//
//  Created by Alexei Gudimenko on 16/7/18.
//  Copyright © 2018 Alexei Gudimenko. All rights reserved.
//

import UIKit
import XLPagerTabStrip

class TabPageTableViewController: UITableViewController, IndicatorInfoProvider {
  
  var itemInfo = IndicatorInfo(title: "View")
  
  init(style: UITableView.Style, itemInfo: IndicatorInfo) {
    self.itemInfo = itemInfo
    super.init(style: style)
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    // Uncomment the following line to preserve selection between presentations
    // self.clearsSelectionOnViewWillAppear = false
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem
  }
  
  func indicatorInfo(for pagerTabStripController: PagerTabStripViewController) -> IndicatorInfo {
    return itemInfo
  }
  
}
