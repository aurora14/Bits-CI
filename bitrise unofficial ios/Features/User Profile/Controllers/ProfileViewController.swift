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
    
    //NotificationCenter.default.addObserver(self,
    //                                       selector: #selector(didAuthorizeSuccessfully(withToken:)),
    //                                       name: NSNotification.Name(didAuthorizeUserNotification),
    //                                       object: TokenAuthViewController.self)
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
  
  
  /// <#Description#>
  ///
  /// - Parameter bitriseUser: optional user parameter. You can force a UI update with
  ///   explicit user info. If a user object is passed in as an argument, it will take
  ///   precedence over the shared instance version.
  private func updateWithUserInfo(forUser bitriseUser: User? = nil) {
    // TODO: - handle null user
    var currentUser: User? = bitriseUser == nil ? App.sharedInstance.currentUser : bitriseUser
    
    guard let u = currentUser else { return }
    
    DispatchQueue.main.async {
      self.profileHeaderView?.backgroundImageView.image = u.avatarImage ?? Asset.Icons.userLrg.image
      self.profileHeaderView?.foregroundImageView.image = u.avatarImage ?? Asset.Icons.userLrg.image
      self.profileHeaderView?.usernameLabel.text = u.username ?? L10n.bitriseUser
    }
  }
  
  @IBAction func didTapLogOut(_ sender: Any) {
    print("Logout button tapped")
    showConfirmationPrompt()
  }
  
  private func showConfirmationPrompt() {
    
    let alertController = UIAlertController(
      title: L10n.logOut,
      message: L10n.logOutConfirmationMsg,
      preferredStyle: .actionSheet)
    
    alertController.view.tintColor = Asset.Colors.bitriseGreen.color
    
    let cancelAction = UIAlertAction(title: L10n.cancel, style: .cancel) { _ in }
    
    let logOutAction = UIAlertAction(title: L10n.logOut, style: .destructive) { _ in
      self.logOut()
    }
    
    alertController.addAction(cancelAction)
    alertController.addAction(logOutAction)
    
    present(alertController, animated: true, completion: nil)
  }
  
  private func resetViewsToDefault() {
    DispatchQueue.main.async {
      self.profileHeaderView?.backgroundImageView.image = Asset.Icons.userLrg.image
      self.profileHeaderView?.foregroundImageView.image = Asset.Icons.userLrg.image
      self.profileHeaderView?.usernameLabel.text = L10n.bitriseUser
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
      
    case StoryboardSegue.Main.profileTabTokenSegue.rawValue:
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
      cell.textLabel?.text = L10n.noOrganizations
      cell.textLabel?.font = UIFont.systemFont(ofSize: 12, weight: .light)
      cell.textLabel?.textAlignment = .center
      return cell
    }
    
    cell.textLabel?.text = "Organization support coming soon"
    cell.textLabel?.font = UIFont.systemFont(ofSize: 12, weight: .light)
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
    invokeElasticHeader(in: scrollView)
  }
  
  fileprivate func invokeElasticHeader(in scrollView: UIScrollView) {
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
  
  @objc func logOut() {
    // 1. Remove token
    App.sharedInstance.removeBitriseAuthToken {
      App.sharedInstance.checkForAvailableBitriseToken { [weak self] isAuthorized in
        if !isAuthorized {
          print("*** Log out successful")
          // 2. Remove in-memory user instance
          App.sharedInstance.currentUser = nil
          // 3. Update UI
          self?.resetViewsToDefault()
          // 4. Show authorization view
          self?.presentAuthorizationView()
        } else {
          print("*** Log out may have failed")
        }
      }
    }
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
  
  private func updateAvatar(for user: User) {
    
    guard let avatarUrl = user.avatarUrl?.replacingOccurrences(of: "http", with: "https") else {
      print("*** User doesn't have an avatar link associated with their account")
      return
    }
    
    App.sharedInstance
      .apiClient.getUserImage(from: avatarUrl, then: { [weak self] _, image, _ in
        DispatchQueue.main.async {
          guard let i = image else { return }
          self?.profileHeaderView?.backgroundImageView.image = i
          self?.profileHeaderView?.foregroundImageView.image = i
        }
      })
  }
}


extension ProfileViewController: BitriseAuthorizationDelegate {
  
  @objc func didAuthorizeSuccessfully(withToken authorizationToken: AuthToken? = nil) {
    print("*** Auth delegate called")
    if App.sharedInstance.currentUser == nil {
      App.sharedInstance.apiClient.getUserProfile { _, user, _ in
        self.updateWithUserInfo(forUser: user)
        self.updateAvatar(for: user ?? User(username: L10n.bitriseUser, slug: nil, avatarURL: nil))
      }
    } else {
      print("*** User wasn't null \(App.sharedInstance.currentUser.debugDescription)")
      updateWithUserInfo()
    }
  }
  
  func didFailToAuthorize(with message: String) {
    resetViewsToDefault()
  }
  
  func didCancelAuthorization() {
    resetViewsToDefault()
  }

}
