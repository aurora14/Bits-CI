//
//  ProjectDetailViewController.swift
//  bitrise unofficial ios
//
//  Created by Alexei Gudimenko on 11/7/18.
//  Copyright © 2018 Alexei Gudimenko. All rights reserved.
//

import UIKit
import XLPagerTabStrip


class ProjectDetailViewController: ButtonBarPagerTabStripViewController {
  
  @IBOutlet weak var detailBarButton: UIBarButtonItem!
  
  /// A viewmodel passed from the project list VC during navigation. Contains
  /// all the information about a single project
  var projectVM: BitriseProjectViewModel?
  
  /// A viewmodel that corresponds a selected row in Build List VC. Populated
  /// when the BuildListVS's delegate method is called by using index path's section
  /// property to select a build from `projectVM.buildList`
  var selectedBuildVM: ProjectBuildViewModel?
  
  let selectionGenerator = UISelectionFeedbackGenerator()
  
  // MARK: - View lifecycle
  override func viewDidLoad() {
    setupPagerTabStripSettings()
    
    super.viewDidLoad()
    selectionGenerator.prepare()
    
    if let viewModel = projectVM {
      setFormattedTitle(with: viewModel)
    } else {
      title = "Detail"
    }
    // Do any additional setup after loading the view.
    setupSwipeToGoBack(withPopGestureRecognizerEnabled: true, consumesGesture: false)
    
    containerView?.isScrollEnabled = false
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
    
    page1.buildRowTapDelegate = self
    
    let page2 = BitriseYMLViewController(itemInfo: "YML",
                                         forAppViewModel: projectVM ??
                                          BitriseProjectViewModel(with: BitriseApp()))
    
    return [page1, page2]
  }
  
  
  @IBAction func didTapBarButton(_ sender: Any) {
    DispatchQueue.global(qos: .utility).async {
      print("*** Project detail bar button tapped")
    }
    self.selectionGenerator.selectionChanged()
    perform(segue: StoryboardSegue.Main.startNewBuildSegue)
  }
  
  // MARK: - Navigation
  
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    
    switch segue.identifier {
    case StoryboardSegue.Main.startNewBuildSegue.rawValue:
      if let controller = segue.destination as? NewBuildViewController {
        controller.app = projectVM?.app
      }
    case StoryboardSegue.Main.buildDetailSegue.rawValue:
      if let controller = segue.destination as? BuildDetailViewController, let b = selectedBuildVM {
        controller.buildVM = b
      }
    default:
      return
    }
  }
  
}


extension ProjectDetailViewController: BuildRowTapDelegate {
  
  func didSelectBuild(at indexPath: IndexPath) {
    // build list uses sections with one row each, rather than one section with multiple rows
    selectedBuildVM = projectVM?.buildList[indexPath.section]
    perform(segue: StoryboardSegue.Main.buildDetailSegue)
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

