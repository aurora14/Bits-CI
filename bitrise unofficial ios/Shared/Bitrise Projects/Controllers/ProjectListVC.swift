//
//  ProjectListViewController.swift
//  bitrise-unofficial-ios
//
//  Created by Alexei Gudimenko on 13/6/18.
//  Copyright © 2018 Alexei Gudimenko. All rights reserved.
//


import UIKit
import Alamofire
import AlamofireImage
import SkeletonView
import ViewAnimator

class ProjectListViewController: UITableViewController, SkeletonTableViewDataSource {
  
  @IBOutlet weak var rightBarContainer: UIView!
  
  @IBOutlet weak var userProfileButton: UIButton!
  
  var searchController: UISearchController = UISearchController(searchResultsController: nil)
  var searchFooter: SearchFooter?
  
  fileprivate var isAuthorised = false
  fileprivate var isFiltering = false
  
  var apps = [CellRepresentable]()
  var activeDataSource = [CellRepresentable]()
  
  override func loadView() {
    super.loadView()
    refreshControl = UIRefreshControl()
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    setupSearchAndNavigationUI()
    setupTableView()
    setupProfileButton()
    loadTestItems() // dummy items to show a preview until the table view is updated with live data
    setupRefreshing()
    tableView.showAnimatedSkeleton()
    loadDataWithAuthorization()
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    navigationItem.largeTitleDisplayMode = .always
    
    App.sharedInstance.checkForAvailableBitriseToken { [weak self] isValid in
      
      guard isValid else {
        self?.apps.removeAll()
        DispatchQueue.main.async {
          self?.tableView.reloadData()
          self?.presentAuthorizationView()          
        }
        return
      }
    }
  }
  
  @objc private func getProjects() {
    
    App.sharedInstance.apiClient.getUserApps { [weak self] success, projects, message in
      
      guard let strongSelf = self else {
        assertionFailure("Couldn't create a strong-self scoped object")
        return
      }
      
      guard let p = projects else {
        print("*** projects returned null")
        DispatchQueue.main.async {
          strongSelf.finishRefreshing()
          strongSelf.tableView.hideSkeleton()
        }
        return
      }
      
      strongSelf.apps = p
      self?.activeDataSource = strongSelf.apps
      
      DispatchQueue.main.async {
        strongSelf.finishRefreshing()
        self?.tableView.hideSkeleton()
        self?.tableView.reloadData()
        self?.setupAnimations()
      }
      
      return
    }
  }
  
  private func getUser() {
    
    App.sharedInstance.apiClient.getUserProfile { [weak self] isSignedIn, user, message in
      
      guard isSignedIn, let u = user else {
        return
      }
      
      guard let avatarUrl = u.avatarUrl else {
        print("*** User doesn't have an avatar link associated with their account")
        return
      }
      
      let size = CGSize(width: 24, height: 24)
      
      App.sharedInstance
        .apiClient.getUserImage(from: avatarUrl, completion: { [weak self] _, image, _ in
          DispatchQueue.main.async {
            guard let i = image else {
              self?.userProfileButton.setImage(
                Asset.Icons.user.image.af_imageAspectScaled(toFit: size),
                for: .normal)
              return
            }
            self?.userProfileButton.setImage(i.af_imageAspectScaled(toFit: size), for: .normal)
          }
        })
    }
  }
  
  private func presentAuthorizationView() {
    performSegue(withIdentifier: "TokenSegue", sender: nil)
  }
  
  // MARK: - UI Actions
  @IBAction func didTapProfile(_ sender: Any) {
    
    App.sharedInstance.checkForAvailableBitriseToken { [weak self] isAuthorised in
      
      guard isAuthorised else {
        self?.presentAuthorizationView()
        return
      }
      
    }
  }
  
  
  // MARK: - Navigation
  
  // In a storyboard-based application, you will often want to do a little preparation before navigation
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    // Get the new view controller using segue.destination.
    // Pass the selected object to the new view controller.
    
    guard let identifier = segue.identifier else {
      assertionFailure("Segue \(segue.debugDescription) missing identifier.")
      return
    }
    
    switch identifier {
      
    case StoryboardSegue.Main.tokenSegue.rawValue:
      
      let controller = segue.destination as? TokenAuthViewController
      controller?.authorizationDelegate = self
      
    case StoryboardSegue.Main.projectDetailSegue.rawValue:
      
      let controller = segue.destination as? ProjectDetailViewController
      print("Sender: \(sender.debugDescription)")
      if let s = sender as? BitriseProjectViewModel {
        controller?.projectVM = s
      }
      
    default: return
    }
    
  }
  
}


// MARK: - Table View Datasource
extension ProjectListViewController {
  
  override func numberOfSections(in collectionSkeletonView: UITableView) -> Int {
    if isFiltering {
      searchFooter?.setIsFilteringToShow(filteredItemCount: activeDataSource.count, of: apps.count)
    } else {
      searchFooter?.setNotFiltering()
    }
    return activeDataSource.count
  }
  
  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return 1 // one per section, since we can't set distance between cells - we use sections, one
    // for each project
  }
  
  override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
    return 8 // just enough for a subtle but clear separation of the cells
  }
  
  override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    return activeDataSource[indexPath.section].rowHeight
  }
  
  override func tableView(_ tableView: UITableView,
                          cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let vm = activeDataSource[indexPath.section] as? BitriseProjectViewModel
    vm?.viewRefreshDelegate = self
    vm?.indexPath = indexPath
    return activeDataSource[indexPath.section].cellInstance(tableView, indexPath: indexPath)
  }
  
  func collectionSkeletonView(_ skeletonView: UITableView, cellIdenfierForRowAt indexPath: IndexPath) -> ReusableCellIdentifier {
    return "ProjectCell"
  }
  
}


// MARK: - Table View Delegate
extension ProjectListViewController {
  
  override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    
    if searchController.isActive { searchController.isActive = false }
    
    //print("*** Tapped row at \(indexPath.section)")
    
    let project = activeDataSource[indexPath.section] as? BitriseProjectViewModel
    
    perform(segue: StoryboardSegue.Main.projectDetailSegue, sender: project)
    
    tableView.deselectRow(at: indexPath, animated: true)
  }
}

// MARK: - Table View Prefetch
extension ProjectListViewController: UITableViewDataSourcePrefetching {
  
  // TODO: - Finish implementation of these for smooth scrolling
  
  func tableView(_ tableView: UITableView, prefetchRowsAt indexPaths: [IndexPath]) {
    for _ in indexPaths {
      
    }
  }
  
  func tableView(_ tableView: UITableView, cancelPrefetchingForRowsAt indexPaths: [IndexPath]) {
    for _ in indexPaths {
      
    }
  }
  
}


// MARK: - Helpers
extension ProjectListViewController {
  
  fileprivate func loadDataWithAuthorization() {
    App.sharedInstance.checkForAvailableBitriseToken { [weak self] isAuthorised in
      
      self?.isAuthorised = isAuthorised
      
      if isAuthorised {
        self?.getUser()
        self?.getProjects()
      } else {
        self?.apps.removeAll()
        self?.presentAuthorizationView()
      }
    }
  }

  
  /// Configures the search UI (the embedded navigation-bar version as it shows in iOS 11;
  /// we aren't supporting < 11.0 at this point).
  /// Some things to keep in mind:
  /// - 'obscuresBackgroundDuringPresentation' needs to be set to false. We aren't using a
  /// custom Search Results Controller, therefore if it's set to true (which
  fileprivate func setupSearchAndNavigationUI() {
    if #available(iOS 11.0, *) {
      navigationController?.navigationBar.prefersLargeTitles = true
      navigationController?.navigationBar.isTranslucent = true
      navigationItem.largeTitleDisplayMode = .always //locking this permanently for now, will figure out the workaround for broken .automatic behaviour later
      title = "Projects"
      
      searchController.searchBar.placeholder = "Filter by project title"
      searchController.searchResultsUpdater = self
      searchController.searchBar.tintColor = Asset.Colors.bitriseGreen.color
      searchController.obscuresBackgroundDuringPresentation = false
      searchController.delegate = self
      navigationItem.searchController = searchController
    } else {
      // Fallback on earlier versions
    }
  }
  
  /// Sets up the right bar button container and the embedded profile button
  ///
  /// Clifton Labrum solved the issue of the button not recognizing touches when embedded in a custom view
  /// used for the bar button item - done by explicitly setting constraints onto this container view.
  /// Alternative solution described below:
  ///
  /// Adding to Clifton Labrum, this is the way to go. Apple changed the way navigation bars work in iOS 11.
  /// This can also be done in Storyboard but through descendant constraints.
  /// The Custom view inside UIBarButtonItem can NOT be given constraints directly. Instead, provide its
  /// subviews with constraints, and the Custom view will get its constraints implicitly.
  ///
  /// Reference: https://stackoverflow.com/questions/46306796/uibutton-in-navigation-bar-not-recognizing-taps-in-ios-11
  fileprivate func setupProfileButton() {
    rightBarContainer.widthAnchor.constraint(equalToConstant: 64).isActive = true
    rightBarContainer.heightAnchor.constraint(equalToConstant: 36).isActive = true
    userProfileButton.imageView?.contentMode = .scaleAspectFit
    userProfileButton.setImage(Asset.Icons.user.image, for: .normal)
  }
  
  fileprivate func setupTableView() {
    tableView.prefetchDataSource = self
    searchFooter = createSearchFooter()
    tableView.tableFooterView = searchFooter
  }
  
  fileprivate func setupAnimations(withDirection: Direction = .bottom) {
    let fromAnimation = AnimationType.from(direction: .bottom, offset: 24)
    
    let cells = tableView.visibleCells
    UIView.animate(views: cells, animations: [fromAnimation])
  }
  
  fileprivate func createSearchFooter() -> SearchFooter {
    let size = CGSize(width: UIScreen.main.bounds.width - 12, height: 56)
    let frame = CGRect(origin: .zero, size: size)
    let footerView = SearchFooter(frame: frame)
    return footerView
  }
  
  fileprivate func loadTestItems() {
    let testModels: [CellRepresentable] = [
      BitriseProjectViewModel(with: BitriseApp()),
      BitriseProjectViewModel(with: BitriseApp()),
      BitriseProjectViewModel(with: BitriseApp()),
      BitriseProjectViewModel(with: BitriseApp()),
      BitriseProjectViewModel(with: BitriseApp())]
    apps.append(contentsOf: testModels)
    activeDataSource = apps
  }
  
  fileprivate func setupRefreshing() {
    // NOTE: - Leave the background property blank to make refresh control have the same bg colour as
    //  the regular tableview background. Otherwise it'll layer colours and will make the control appear darker.
    //  Default colour of the Refresh control is .clear
    refreshControl?.tintColor = Asset.Colors.bitriseGreen.color
    refreshControl?.addTarget(self, action: #selector(getProjects),
                              for: .valueChanged)
    tableView.refreshControl = refreshControl
  }
  
  fileprivate func finishRefreshing() {
    // Note: - do not assign a title to the embedded refresh control, as it breaks
    // the frame when the control ends refreshing. This is likely due to the call to
    // endRefreshing() which restores the control to its default state; the label that
    // holds the title is either annulled or its size is 0, which also pulls up the
    // content of the scroll view by the amount equal to this label's height.
    DispatchQueue.main.async { [weak self] in
      if let refreshControl = self?.refreshControl, refreshControl.isRefreshing {
        self?.refreshControl?.endRefreshing()
        self?.tableView.layoutIfNeeded()
      }
    }
  }
}

// MARK: - Search & Filter
extension ProjectListViewController: UISearchResultsUpdating, UISearchControllerDelegate {
  
  func updateSearchResults(for searchController: UISearchController) {
    
    if let text = searchController.searchBar.text,
      !text.isEmpty, let projects = apps as? [BitriseProjectViewModel] {
      isFiltering = true
      activeDataSource = projects.filter({ project -> Bool in
        return project.title.uppercased().contains(text.uppercased())
      })
    } else {
      isFiltering = false
      activeDataSource = apps
    }
    tableView.reloadData()
    //setupAnimations()
  }
}


// MARK: - Bitrise Authorization delegate
extension ProjectListViewController: BitriseAuthorizationDelegate {
  
  func didAuthorizeSuccessfully() {
    getUser()
    getProjects()
  }
  
  func didFailToAuthorize(with message: String) {
    
    
  }
  
  func didCancelAuthorization() {
    
  }
  
}


// MARK: - View refresh delegate. Typically any data source updates that are initiated
// from outside of this VC can handle the necessary UI updates here.
extension ProjectListViewController: ViewRefreshDelegate {
  
  func update(at indexPath: IndexPath?) {
    
    guard let path = indexPath else {
      return
    }
    
    DispatchQueue.main.async {
      self.tableView.beginUpdates()
      self.tableView.reloadRows(at: [path], with: .automatic)
      self.tableView.endUpdates()
    }
  }
}
