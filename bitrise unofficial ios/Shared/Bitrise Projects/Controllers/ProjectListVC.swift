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


class ProjectListViewController: UITableViewController {
  
  
  @IBOutlet weak var userProfileButton: UIBarButtonItem!
  
  
  fileprivate var isAuthorised = false
  fileprivate var isFiltering = false
  
  var apps = [CellRepresentable]()
  var activeDataSource = [CellRepresentable]()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    // Do any additional setup after loading the view.
    
    setupSearchUI()
    
    checkForAvailableBitriseToken { [weak self] isAuthorised in
      
      self?.isAuthorised = isAuthorised
      
      print("")
      
      if isAuthorised {
        self?.getUser()
        self?.getProjects()
      } else {
        self?.presentAuthorizationView()
      }
    }
    
    // debug only
    //loadTestItems()
  }
  
  private func getProjects() {
    
    App.sharedInstance.apiClient.getUserApps { [weak self] success, projects, message in
      
      guard let strongSelf = self else {
        assertionFailure("Couldn't create a strong-self scoped object")
        return
      }
      
      guard let p = projects else {
        print("*** projects returned null")
        return
      }
      
      strongSelf.apps = p
      self?.activeDataSource = strongSelf.apps
      
      print("Apps count: \(strongSelf.apps.count)")
      print("DS count: \(strongSelf.activeDataSource.count)")
      
      DispatchQueue.main.async {
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


// MARK: - Collection View Datasource
extension ProjectListViewController {
  
  override func numberOfSections(in tableView: UITableView) -> Int {
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
    return activeDataSource[indexPath.section].cellInstance(tableView, indexPath: indexPath)
  }
}


// MARK: - Collection View Delegate
extension ProjectListViewController {
  
  override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    tableView.deselectRow(at: indexPath, animated: true)
    
    print("*** Tapped row at \(indexPath.section)")
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
  
  fileprivate func setupSearchUI() {
    if #available(iOS 11.0, *) {
      let search = UISearchController(searchResultsController: nil)
      // TODO: - replace with actual property that can be filtered, e.g. name
      search.searchBar.placeholder = "Filter by project title"
      search.searchResultsUpdater = self
      self.navigationItem.searchController = search
    } else {
      // Fallback on earlier versions
    }
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
}


extension ProjectListViewController: UISearchResultsUpdating {
  
  func updateSearchResults(for searchController: UISearchController) {
    
    if let text = searchController.searchBar.text,
      !text.isEmpty, let projects = apps as? [BitriseProjectViewModel] {
      activeDataSource = projects.filter({ project -> Bool in
        print("\(text) \(project.title.lowercased())")
        return project.title.uppercased().contains(text.uppercased())
      })
      print(apps.count)
    } else {
      activeDataSource = apps
      print(apps.count)// TODO: - optionally, sort these by name or something else
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
