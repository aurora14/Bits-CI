//
//  ProjectDetailViewController.swift
//  bitrise unofficial ios
//
//  Created by Alexei Gudimenko on 11/7/18.
//  Copyright © 2018 Alexei Gudimenko. All rights reserved.
//

import UIKit
import XLPagerTabStrip


class ProjectDetailViewController: ButtonBarPagerTabStripViewController,
UIGestureRecognizerDelegate {
  
  @IBOutlet weak var detailBarButton: UIBarButtonItem!
  
  var projectVM: BitriseProjectViewModel?
  
  let selectionGenerator = UISelectionFeedbackGenerator()
  
  override func viewDidLoad() {
    setupPagerTabStripSettings()
    
    super.viewDidLoad()
    
    if let viewModel = projectVM {
      setFormattedTitle(with: viewModel)
    } else {
      title = "Detail"
    }
    // Do any additional setup after loading the view.
    configureDefaultInteractiveGestures()
    
    selectionGenerator.prepare()
  }
  
  override func viewWillAppear(_ animated: Bool) {
    navigationController?.navigationBar.isTranslucent = false
    tabBarController?.tabBar.isTranslucent = false
    super.viewWillAppear(animated)
  }
  
  override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)
    navigationController?.navigationBar.isTranslucent = true
    tabBarController?.tabBar.isTranslucent = true
  }
  
  private func configureDefaultInteractiveGestures() {
    navigationController?.interactivePopGestureRecognizer?.delegate = self
    navigationController?.interactivePopGestureRecognizer?.isEnabled = true
  }
  
  /// Configures pager tab settings. This method should be called in viewDidLoad() and
  /// before super.viewDidLoad()
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
  
  // MARK: - PagerTabStripDataSource
  
  override func viewControllers(for pagerTabStripController: PagerTabStripViewController) -> [UIViewController] {
    
    let page1 = BuildListViewController(style: .plain, itemInfo: "BUILDS",
                                        forAppViewModel: projectVM ??
                                          BitriseProjectViewModel(with: BitriseApp()))
    let page2 = BitriseYMLViewController(itemInfo: "YML",
                                         forAppViewModel: projectVM ??
                                          BitriseProjectViewModel(with: BitriseApp()))
    
    return [page1, page2]
  }
  
  
  @IBAction func didTapBarButton(_ sender: Any) {
    selectionGenerator.selectionChanged()
  }
  
  // MARK: - Navigation
  
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    
    switch segue.identifier {
    case StoryboardSegue.Main.startNewBuildSegue.rawValue:
      if let controller = segue.destination as? NewBuildViewController {
        controller.app = projectVM?.app
      }
    default:
      return
    }
  }
  
}


extension ProjectDetailViewController {
  
  func setFormattedTitle(with viewModel: BitriseProjectViewModel) {
    let projectTitle =
      viewModel
        .title
        .capitalized
        .replacingOccurrences(of: "-", with: " ")
        .replacingOccurrences(of: "Ios", with: "iOS")
    title = projectTitle
  }
}

