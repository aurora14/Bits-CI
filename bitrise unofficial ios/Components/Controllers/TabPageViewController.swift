//
//  TabPageViewController.swift
//  bitrise unofficial ios
//
//  Created by Alexei Gudimenko on 16/7/18.
//  Copyright © 2018 Alexei Gudimenko. All rights reserved.
//

import UIKit
import XLPagerTabStrip

class TabPageViewController: UIViewController, IndicatorInfoProvider {
  
  var itemInfo = IndicatorInfo(title: "View")
  
  init(itemInfo: IndicatorInfo) {
    self.itemInfo = itemInfo
    super.init(nibName: nil, bundle: nil)
  }
  
  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    // Do any additional setup after loading the view.
  }
  
  
  func indicatorInfo(for pagerTabStripController: PagerTabStripViewController) -> IndicatorInfo {
    
    return itemInfo
  }
  
  /*
   // MARK: - Navigation
   
   // In a storyboard-based application, you will often want to do a little preparation before navigation
   override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
   // Get the new view controller using segue.destination.
   // Pass the selected object to the new view controller.
   }
   */
  
}
