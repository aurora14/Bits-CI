//
//  BuildDetailViewController.swift
//  bitrise unofficial ios
//
//  Created by Alexei Gudimenko on 25/9/18.
//  Copyright © 2018 Alexei Gudimenko. All rights reserved.
//

import UIKit
import XLPagerTabStrip

class BuildDetailViewController: ButtonBarPagerTabStripViewController {
  
  var buildVM: ProjectBuildViewModel?
  
  override func viewDidLoad() {
    setupPagerTabStripSettings()
    super.viewDidLoad()
    
    // Do any additional setup after loading the view.
    if let buildViewModel = buildVM {
      title = "Build \(buildViewModel.buildNumber)"
    } else {
      title = "Build Details"
    }
    
    setupNavigationBar()
    setupSwipeToGoBack(withPopGestureRecognizerEnabled: true, consumesGesture: false)
  }
  
  override func viewWillAppear(_ animated: Bool) {
    navigationItem.largeTitleDisplayMode = .never
    //nav and tab bar should be opaque to correctly display the tabs and their content
    navigationController?.navigationBar.isTranslucent = false
    tabBarController?.tabBar.isTranslucent = false
    super.viewWillAppear(animated)
  }
  
  override func viewWillDisappear(_ animated: Bool) {
    navigationItem.largeTitleDisplayMode = .always
    super.viewWillDisappear(animated)
  }
  
  private func setupPagerTabStripSettings() {
    settings.style.buttonBarBackgroundColor = .white
    settings.style.buttonBarItemBackgroundColor = .white
    settings.style.selectedBarBackgroundColor = Asset.Colors.bitriseGreen.color
    
    settings.style.buttonBarMinimumLineSpacing = 0
    settings.style.buttonBarItemsShouldFillAvailableWidth = true
    
    settings.style.buttonBarItemFont = UIFont.systemFont(ofSize: 14, weight: .regular)
    settings.style.selectedBarHeight = 2.0
    
    changeCurrentIndexProgressive = { (oldCell: ButtonBarViewCell?,
      newCell: ButtonBarViewCell?, progressPercentage: CGFloat,
      changeCurrentIndex: Bool, animated: Bool) -> Void in
      
      guard changeCurrentIndex == true else { return }
      oldCell?.label.textColor = Asset.Colors.bitriseGrey.color
      newCell?.label.textColor = Asset.Colors.bitriseGreen.color
    }
  }
  
  private func setupNavigationBar() {
    
  }

  override func viewControllers(for pagerTabStripController: PagerTabStripViewController) -> [UIViewController] {
    
    // #warning this must return at least one page.
    guard let b = buildVM else {
      fatalError("No build viewmodel instance found. Can't initialise build detail pages")
    }
    
    let page1 = BuildLogViewController(itemInfo: "LOG", forBuildViewModel: b)
    
    return [page1]
  }
}
