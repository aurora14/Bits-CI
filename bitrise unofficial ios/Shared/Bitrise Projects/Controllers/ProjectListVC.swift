//
//  ProjectListViewController.swift
//  bitrise-unofficial-ios
//
//  Created by Alexei Gudimenko on 13/6/18.
//  Copyright © 2018 Alexei Gudimenko. All rights reserved.
//

import UIKit

class ProjectListViewController: UITableViewController {
  
  
  fileprivate var isAuthorised = false
  fileprivate var isFiltering = false
  
  var apps = [CellRepresentable]()
  var activeDataSource = [CellRepresentable]()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    // Do any additional setup after loading the view.
    validateBitriseToken() { isAuthorised in
      
      self.isAuthorised = isAuthorised
      
      if isAuthorised {
        self.setupSearchUI()
        self.getProjectsAndUser()
      } else {
        self.presentAuthorizationView()
      }
    }
    
    // debug only
    loadTestItems()
  }
  
  private func getProjectsAndUser() {
    
    // make separate API calls: one to get the list of projects, one to get user information.
    
    // cache the user information where relevant
    
    activeDataSource = apps
  }
  
  private func presentAuthorizationView() {
    performSegue(withIdentifier: "TokenSegue", sender: nil)
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
    return 1
  }
  
  override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
    return 8
  }
  
  override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    return activeDataSource[indexPath.row].rowHeight
  }
  
  override func tableView(_ tableView: UITableView,
                          cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    return activeDataSource[indexPath.row].cellInstance(tableView, indexPath: indexPath)
  }
}


// MARK: - Collection View Delegate
extension ProjectListViewController {
 
  override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    tableView.deselectRow(at: indexPath, animated: true)
    
  }
}


// MARK: - Helpers
extension ProjectListViewController {
  
  fileprivate func validateBitriseToken(_ completion: @escaping (Bool) -> Void) {
    
    // Check if Keychain has a valid token. If not, open the token modal. There the user
    // has the option
    
    completion(true)
  }
  
  fileprivate func setupSearchUI() {
    if #available(iOS 11.0, *) {
      let search = UISearchController(searchResultsController: nil)
      // TODO: - replace with actual property that can be filtered, e.g. name
      search.searchBar.placeholder = "Filter by project %property%"
      search.searchResultsUpdater = self
      self.navigationItem.searchController = search
    } else {
      // Fallback on earlier versions
    }
  }
  
  fileprivate func loadTestItems() {
//    let testModels: [CellRepresentable] = [
//      BitriseProjectViewModel(),
//      BitriseProjectViewModel(),
//      BitriseProjectViewModel(),
//      BitriseProjectViewModel(),
//      BitriseProjectViewModel(),]
//    apps.append(contentsOf: testModels)
    activeDataSource = apps
  }
}


extension ProjectListViewController: UISearchResultsUpdating {
  
  func updateSearchResults(for searchController: UISearchController) {
    
    if let text = searchController.searchBar.text, !text.isEmpty {
      activeDataSource = activeDataSource.filter({ (project) -> Bool in
        return true// return project.someProperty.lowercased().contains(searchbartext)
      })
      isFiltering = true
    } else {
      isFiltering = false
      activeDataSource = apps // TODO: - optionally, sort these by name or something else
    }
    tableView.reloadData()
  }
}


extension ProjectListViewController: BitriseAuthorizationDelegate {
  
  func didAuthorizeSuccessfully() {
    
    // update avatar picture w/AlamofireImage
    
    // fetch user's apps
  }
  
  func didFailToAuthorize(with message: String) {
    
    
  }
  
  
  
}
