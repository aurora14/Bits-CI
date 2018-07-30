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
    App.sharedInstance.checkForAvailableBitriseToken { [weak self] isAuthorized in
      if isAuthorized {
        self?.updateWithUserInfo()
        App.sharedInstance.userUpdateDelegate = self
      } else {
        self?.presentAuthorizationView()
      }
    }
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
    
    DispatchQueue.main.async {
      self.profileHeaderView?.backgroundImageView.image = user.avatarImage ?? Asset.Icons.user.image
      self.profileHeaderView?.foregroundImageView.image = user.avatarImage ?? Asset.Icons.user.image
      self.profileHeaderView?.usernameLabel.text = user.username ?? "Bitrise User"
    }
  }
  
  @IBAction func didTapLogOut(_ sender: Any) {
    print("Logout button tapped")
    showConfirmationPrompt()
  }
  
  private func showConfirmationPrompt() {
    
    let alertController = UIAlertController(
      title: "Log Out",
      message: "Are you sure you want to log out? " +
      "You may need to generate a new access token next time you wish to use the app.",
      preferredStyle: .actionSheet)
    
    alertController.view.tintColor = Asset.Colors.bitriseGreen.color
    
    let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { action in
      
    }
    
    let logOutAction = UIAlertAction(title: "Log Out", style: .destructive) { action in
      
      // 1. Remove token
      App.sharedInstance.removeBitriseAuthToken {
        App.sharedInstance.checkForAvailableBitriseToken { [weak self] isAuthorized in
          if !isAuthorized {
            print("*** Log out successful")
            self?.resetViewsToDefault()
            self?.presentAuthorizationView()
          } else {
            print("*** Log out may have failed")
          }
        }
      }
    }
    
    alertController.addAction(cancelAction)
    alertController.addAction(logOutAction)
    
    present(alertController, animated: true, completion: nil)
  }
  
  private func resetViewsToDefault() {
    DispatchQueue.main.async {
      self.profileHeaderView?.backgroundImageView.image = Asset.Icons.user.image
      self.profileHeaderView?.foregroundImageView.image = Asset.Icons.user.image
      self.profileHeaderView?.usernameLabel.text = "Bitrise User"
    }
  }
  
  private func presentAuthorizationView() {
    DispatchQueue.main.async {
      self.perform(segue: StoryboardSegue.Main.profileTabTokenSegue)
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
      
    default: return
    }
  }
  
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
  
  func updateUserViews() {
    DispatchQueue.main.async {
      UIView.animate(withDuration: 0.1, delay: 0,
                     options: [.curveEaseOut],
                     animations: {
                      self.updateWithUserInfo()
      }, completion: nil)
    }
  }
  
}


extension ProfileViewController: BitriseAuthorizationDelegate {
  
  func didAuthorizeSuccessfully() {
    updateWithUserInfo()
  }
  
  func didFailToAuthorize(with message: String) {
    resetViewsToDefault()
  }
  
  func didCancelAuthorization() {
    resetViewsToDefault()
  }
  
  
  
}
