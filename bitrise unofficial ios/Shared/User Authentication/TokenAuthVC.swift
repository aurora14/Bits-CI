//
//  TokenAuthViewController.swift
//  bitrise-unofficial-ios
//
//  Created by Alexei Gudimenko on 12/6/18.
//  Copyright © 2018 Alexei Gudimenko. All rights reserved.
//

import UIKit
import Fabric
import Crashlytics

protocol BitriseAuthorizationDelegate: class {
  
  /// Called when the API returns user information from base_url/me endpoint.
  /// * User enters token into the text field and submits.
  /// * If the token is valid, Bitrise API returns user name, slug and avatar URL
  /// * In that case, call this delegate method and dismiss the TokenAuth View Controller.
  
  func didAuthorizeSuccessfully()
  
  /// Called when the API returns 401 and "Unauthorized" message from the base_url/me endpoint.
  /// * User enters token into the text field and submits
  /// * Invalid token & Unauth 401 result
  /// * DO NOT dismiss the view controller. Highlight the text field border in red and show an error message
  /// * When the user starts editing again, revert the border to the original colour and hide the error msg
  ///
  /// - Parameter error: <#error description#>
  
  func didFailToAuthorize(with message: String)
  
  /// User decided not to submit a token and dismissed the view with the cancel button
  func didCancelAuthorization()
}

class TokenAuthViewController: UIViewController {
  
  @IBOutlet weak var tokenInputTF: UITextField!
  @IBOutlet weak var cancelButton: UIButton!
  
  weak var authorizationDelegate: BitriseAuthorizationDelegate?
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    // Do any additional setup after loading the view.
    setupTextfield()
    setupCancelButton()
  }
  
  @IBAction func didTapCancel(_ sender: Any) {
    
    authorizationDelegate?.didCancelAuthorization()
    
    dismiss(animated: true, completion: nil)
    
  }
  
  @IBAction func didTapGetNewToken(_ sender: Any) {
    
    performSegue(withIdentifier: "GetNewTokenSegue", sender: self)
  }
  
  private func setupCancelButton() {
    
    let width = cancelButton.bounds.width
    let cornerRadius = width / 2
    
    cancelButton.backgroundColor = .white
    
    let layer = cancelButton.layer
    layer.cornerRadius = cornerRadius
    layer.shadowColor = UIColor.black.cgColor
    layer.shadowOpacity = 0.5
    layer.shadowOffset = CGSize(width: 1, height: 1)
    layer.shadowPath = UIBezierPath(roundedRect: cancelButton.bounds, cornerRadius: cornerRadius).cgPath
    layer.masksToBounds = false
  }
  
  /*
   // MARK: - Navigation
   
   // In a storyboard-based application, you will often want to do a little preparation before navigation
   override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
   // Get the new view controller using segue.destinationViewController.
   // Pass the selected object to the new view controller.
   }
   */
  
}


extension TokenAuthViewController: UITextFieldDelegate {
  
  func setupTextfield() {
    tokenInputTF.delegate = self
    tokenInputTF.becomeFirstResponder()
  }
  
  func textFieldShouldReturn(_ textField: UITextField) -> Bool {
    
    guard let token = textField.text else {
      return false
    }
    
    return true
  }
}
