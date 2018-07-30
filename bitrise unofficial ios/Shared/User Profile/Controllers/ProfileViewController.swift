//
//  ProfileViewController.swift
//  bitrise unofficial ios
//
//  Created by Alexei Gudimenko on 26/7/18.
//  Copyright © 2018 Alexei Gudimenko. All rights reserved.
//

import UIKit

class ProfileViewController: UITableViewController {
  
  private var profileHeaderView: ProfileHeaderView?
  
  private let defaultHeaderHeight: CGFloat = 375
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    // Do any additional setup after loading the view.
    setupNavigationBar()
    setupProfileView()
    setupTableView()
    
    // If user isn't authorized, present TokenAuth view
    updateWithUserInfo()
  }
  
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    updateWithUserInfo()
    App.sharedInstance.userUpdateDelegate = self
  }
  
  
  private func setupNavigationBar() {
    navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
    navigationController?.navigationBar.shadowImage = UIImage()
    navigationController?.navigationBar.isTranslucent = true
  }
  
  
  private func setupTableView() {
    
    tableView.allowsSelection = false
    tableView.separatorStyle = .none
    
    tableView.contentInset = UIEdgeInsets(top: -64, left: 0, bottom: 0, right: 0)
    
    // 5. Set tableview's header to the container to show the content.
    tableView.tableHeaderView = profileHeaderView
    tableView.tableHeaderView = nil
    tableView.addSubview(profileHeaderView ?? UIView())

  }
  
  
  /// Instantiates the view showing basic profile info, i.e. username & image.
  /// This should be called before 'setupTableView', so that this view is available to
  /// set as the table view header
  private func setupProfileView() {
    profileHeaderView = ProfileHeaderView.instanceFromNib()
  }
  
  
  private func updateWithUserInfo() {
    guard let user = App.sharedInstance.currentUser else {
      return
    }
    
    profileHeaderView?.backgroundImageView.image = user.avatarImage ?? Asset.Icons.user.image
    profileHeaderView?.foregroundImageView.image = user.avatarImage ?? Asset.Icons.user.image
    profileHeaderView?.usernameLabel.text = user.username ?? "Bitrise User"
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


extension ProfileViewController {
  
  override func numberOfSections(in tableView: UITableView) -> Int {
    return 2
  }
  
  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    // TODO: - fetch user organizations and display them. Return 1 and show default text if no orgs found
    switch section {
    case 0:
      return 0
    default:
      return 1
    }
  }
  
  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    
    guard let cell = tableView.dequeueReusableCell(withIdentifier: "ProfileInfoCell") else {
      let cell = UITableViewCell(style: .default, reuseIdentifier: "ProfileInfoCell")
      cell.textLabel?.text = "User doesn't belong to any organizations"
      cell.textLabel?.font = UIFont.systemFont(ofSize: 12, weight: .light)
      cell.textLabel?.textAlignment = .center
      return cell
    }
    
    cell.textLabel?.text = "Organization support coming soon"
    cell.textLabel?.textAlignment = .center
    
    return cell
  }
  
  override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
    switch section {
    case 0:
      return defaultHeaderHeight
    default:
      return 0
    }
  }
  
  override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
    switch section {
    case 0:
      let view = UIView()
      view.backgroundColor = .clear
      return view
    default:
      return nil
    }
  }
  
  override func scrollViewDidScroll(_ scrollView: UIScrollView) {
    
    if profileHeaderView != nil {
      
      let yPos: CGFloat = -scrollView.contentOffset.y
      
      let defaultHeaderHeight: CGFloat = self.defaultHeaderHeight
      let profileImageDefaultTopSpacing: CGFloat = 84
      let usernameLabelDefaultTopSpacing: CGFloat = 25
      
      // if y position is to be different than 0, reset the header to 0 and resize the header to its
      // original height += the y position
      
      if yPos > 0 {
        
        // start with the original frame
        var newHeaderFrame = profileHeaderView!.frame
        newHeaderFrame.origin.y = scrollView.contentOffset.y
        
        newHeaderFrame.size.height = defaultHeaderHeight + yPos
        
        profileHeaderView?.frame = newHeaderFrame
        tableView.sectionHeaderHeight = newHeaderFrame.size.height
        
        let profileImageTopSpacing: CGFloat = profileImageDefaultTopSpacing + yPos / 2
        profileHeaderView?.profileImageTopSpacingConstraint.constant = profileImageTopSpacing
        
        let usernameTopSpacing: CGFloat = usernameLabelDefaultTopSpacing + yPos / 4
        profileHeaderView?.usernameTopSpacingConstraint.constant = usernameTopSpacing
      }
    }
  }
  
  
  @objc
  func logOut() {
    // confirm
    
    // if yes:
    // - remove stored authorization token
    // - reset UI to defaults (user image)
    // - return to 'Projects' tab
  }
  
}


extension ProfileViewController: UserUpdateDelegate {
  
  func updateViews() {
    DispatchQueue.main.async {
      UIView.animate(withDuration: 0.1) {
        self.updateWithUserInfo()
      }      
    }
  }
  
}
