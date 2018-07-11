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


class ProjectListViewController: UITableViewController {
  
  
  @IBOutlet weak var userProfileButton: UIBarButtonItem!
  
  var searchFooter: SearchFooter?
  
  fileprivate var isAuthorised = false
  fileprivate var isFiltering = false
  
  var apps = [CellRepresentable]()
  var activeDataSource = [CellRepresentable]()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    setupSearchAndNavigationUI()
    setupTableView()
    loadTestItems() // dummy items to show a preview until the table view is updated with live data
    setupRefreshing()
    
    checkForAvailableBitriseToken { [weak self] isAuthorised in
      
      self?.isAuthorised = isAuthorised
      
      if isAuthorised {
        self?.getUser()
        self?.getProjects()
      } else {
        self?.presentAuthorizationView()
      }
    }
    
  }
  
  @objc private func getProjects() {
    
    tableView.showAnimatedGradientSkeleton()
    
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
      
      print("Apps count: \(strongSelf.apps.count)")
      print("DS count: \(strongSelf.activeDataSource.count)")
      
      DispatchQueue.main.async {
        strongSelf.finishRefreshing()
        self?.tableView.hideSkeleton()
        self?.tableView.reloadData()        
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
      
      App.sharedInstance
        .apiClient.getUserImage(from: avatarUrl, completion: { [weak self] _, _, _ in
        })
    }
  }
  
  private func presentAuthorizationView() {
    performSegue(withIdentifier: "TokenSegue", sender: nil)
  }
  
  // MARK: - UI Actions
  @IBAction func didTapProfile(_ sender: Any) {
    
    checkForAvailableBitriseToken { [weak self] isAuthorised in
      
      guard isAuthorised else {
        self?.presentAuthorizationView()
        return
      }
      
      // TODO: - Open Profile view if Authorized.
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
    case "TokenSegue":
      let controller = segue.destination as? TokenAuthViewController
      controller?.authorizationDelegate = self
    default:
      return
    }
    
  }
  
  
}


// MARK: - Table View Datasource
extension ProjectListViewController {
  
  override func numberOfSections(in tableView: UITableView) -> Int {
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
  
}


// MARK: - Table View Delegate
extension ProjectListViewController {
  
  override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    tableView.deselectRow(at: indexPath, animated: true)
    
    print("*** Tapped row at \(indexPath.section)")
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
  
  /// Attempts to get a valid stored token from the keychain. If the operation succeeds, calls completion
  /// handler with true result, otherwise with false result.
  /// * Under consideration: to include the token in the closure return
  ///
  /// - Parameter completion: <#completion description#>
  fileprivate func checkForAvailableBitriseToken(_ completion: @escaping (_ isAvailable: Bool) -> Void) {
    
    // Check if Keychain has a valid token. If not, open the token modal. There the user
    // has the option
    guard let _ = App.sharedInstance.getBitriseAuthToken() else {
      completion(false)
      return
    }
    
    completion(true)
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
      
      let search = UISearchController(searchResultsController: nil)
      search.searchBar.placeholder = "Filter by project title"
      search.searchResultsUpdater = self
      search.searchBar.tintColor = Asset.Colors.bitriseGreen.color
      search.obscuresBackgroundDuringPresentation = false
      search.delegate = self
      navigationItem.searchController = search
    } else {
      // Fallback on earlier versions
    }
  }
  
  fileprivate func setupTableView() {
    tableView.prefetchDataSource = self
    searchFooter = createSearchFooter()
    tableView.tableFooterView = searchFooter
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
  
  func setupRefreshing() {
    refreshControl = UIRefreshControl()
    
    // NOTE: - Leave the background property blank to make refresh control have the same bg colour as
    //  the regular tableview background. Otherwise it'll layer colours and will make the control appear darker.
    //  Default colour of the Refresh control is .clear
    //refreshControl?.backgroundColor = selectedMood.themeColorBase
    refreshControl?.tintColor = Asset.Colors.bitriseGreen.color
    // refreshControl?.tintColor = .clear
    refreshControl?.addTarget(self, action: #selector(getProjects),
                              for: .valueChanged)
    tableView.refreshControl = refreshControl
  }
  
  func finishRefreshing() {
    DispatchQueue.main.async { [weak self] in
      if let refreshControl = self?.refreshControl, refreshControl.isRefreshing {
        let lastUpdatedDate = dateFormatter.string(from: Date())
        let title = "Last updated: \(lastUpdatedDate)"
        let attribs = [ NSAttributedString.Key.font: UIFont.systemFont(ofSize: 16),
                        NSAttributedString.Key.foregroundColor: UIColor.darkText ]
        let attributedTitle = NSAttributedString(string: title, attributes: attribs)
        self?.refreshControl?.attributedTitle = attributedTitle
        self?.refreshControl?.endRefreshing()
        //self?.tableView.setContentOffset(CGPoint(x: 0, y: -140), animated: true)
        //self?.scrollToTop()
      }
    }
  }
  
  /// Restores the list back to the start of content. Typically this is done when a new activity
  /// set is being fetched
  fileprivate func scrollToTop() {
    // Set 'y' to 0 to scroll the list all the way to the top. This will also automatically collapse
    // a large title.
    print("scrolling to top")
    tableView.scrollRectToVisible(CGRect(
      x: 0, y: 141.5, width: 1, height: 1), animated: true)
    #warning("setContentOffset() is a temporary workaround for broken Large Titles behaviour")
    tableView.setContentOffset(CGPoint(x: 0, y: 141.5), animated: true)
    print(tableView.contentOffset)
  }
}


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
  }
}


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


extension ProjectListViewController {
  
  override func scrollViewDidScrollToTop(_ scrollView: UIScrollView) {
    print(scrollView.frame)
  }
  
  override func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
    print("\(scrollView.frame) \(scrollView.contentOffset)")
  }
}


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
