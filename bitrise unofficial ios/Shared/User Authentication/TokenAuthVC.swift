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
import SVProgressHUD

class TokenAuthViewController: UIViewController {
  
  @IBOutlet weak var tokenInputTF: UITextField!
  @IBOutlet weak var cancelButton: UIButton!
  @IBOutlet weak var saveTokenButton: UIButton!
  
  weak var authorizationDelegate: BitriseAuthorizationDelegate?
  
  var enteredToken: String = ""
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    // Do any additional setup after loading the view.
    setupTextfield()
    setupCancelButton()
    setupSaveButton()
  }
  
  @IBAction func didTapCancel(_ sender: Any) {
    
    authorizationDelegate?.didCancelAuthorization()
    
    dismiss(animated: true, completion: nil)
    
  }
  
  @IBAction func didTapGetNewToken(_ sender: Any) {
    perform(segue: StoryboardSegue.Main.getNewTokenSegue)
  }
  
  @IBAction func didTapSaveToken(_ sender: Any) {
    
    SVProgressHUD.setShouldTintImages(true)
    SVProgressHUD.setDefaultStyle(.dark)
    SVProgressHUD.show(Asset.Icons.userLrg.image, status: "Getting everything ready")
    
    guard let token = tokenInputTF.text, enteredToken == token else {
      SVProgressHUD.dismiss()
      if enteredToken != tokenInputTF.text {
        assertionFailure("\(L10n.unequalTokenInAuthTF) \(tokenInputTF.text ?? "") <-> \(enteredToken)")
      }
      return
    }
    
    validateAndClose(with: token)
    
  }
  
  
  private func setupCancelButton() {
    
    let width = cancelButton.bounds.width
    let cornerRadius = width / 2
    
    cancelButton.backgroundColor = .white
    
    let layer = cancelButton.layer
    layer.cornerRadius = cornerRadius
    layer.shadowColor = UIColor.black.cgColor
    layer.shadowOpacity = 0.25
    layer.shadowOffset = CGSize(width: 0.75, height: 0.75)
    layer.shadowPath = UIBezierPath(roundedRect: cancelButton.bounds, cornerRadius: cornerRadius).cgPath
    layer.masksToBounds = false
  }
  
  
  private func setupSaveButton() {
    let width = saveTokenButton.bounds.height
    let cornerRadius = width / 2
    
    let layer = saveTokenButton.layer
    layer.cornerRadius = cornerRadius
    layer.shadowColor = UIColor.black.cgColor
    layer.shadowOpacity = 0.25
    layer.shadowOffset = CGSize(width: 0.75, height: 0.75)
    layer.shadowPath = UIBezierPath(roundedRect: saveTokenButton.bounds, cornerRadius: cornerRadius).cgPath
    layer.masksToBounds = false
  }
  
  
  // MARK: - Navigation
  
  // In a storyboard-based application, you will often want to do a little preparation before navigation
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    
    guard let identifier = segue.identifier else {
      assertionFailure("\(segue.debugDescription) is missing an identifier")
      return
    }
    
    switch identifier {
    case StoryboardSegue.Main.getNewTokenSegue.rawValue:
      let navController = segue.destination as? UINavigationController
      let controller = navController?.topViewController as? BitriseBrowserViewController
      controller?.tokenGenerationDelegate = self
    default:
      print("Called \(identifier) segue")
    }
  }
  
}


extension TokenAuthViewController: UITextFieldDelegate {
  
  @objc func textFieldDidChangeValue(_ textField: UITextField) {
    //print("*** \(textField.text ?? "") in \(textField)")
    switch textField {
    default:
      enteredToken = textField.text ?? ""
    }
  }
  
  func setupTextfield() {
    tokenInputTF.delegate = self
    tokenInputTF.becomeFirstResponder()
    tokenInputTF.addTarget(self, action: #selector(textFieldDidChangeValue(_:)), for: [.editingChanged])
  }
  
  func textFieldShouldReturn(_ textField: UITextField) -> Bool {
    
    guard let token = textField.text, token == enteredToken else {
      assertionFailure("\(L10n.unequalTokenInAuthTF) \(tokenInputTF.text ?? "") <-> \(enteredToken)")
      return false
    }
    
    validateAndClose(with: token)
    
    return true
  }
}


extension TokenAuthViewController: TokenGenerationDelegate {
  
  func validateAndClose(with token: AuthToken) {
    App.sharedInstance.apiClient.validateGeneratedToken(token) { [weak self] isValid, message in
      DispatchQueue.main.async {
        SVProgressHUD.dismiss()
      }
      if isValid {
        self?.didGenerate(token: token) {
          DispatchQueue.main.async {
            self?.dismiss(animated: true, completion: nil)
          }
        }
      } else {
        print(message)
      }
    }
  }
  
  func didGenerate(token value: AuthToken, then: (() -> Void)? = nil) {
    enteredToken = value
    DispatchQueue.main.async {
      self.tokenInputTF.text = self.enteredToken
    }
    App.sharedInstance.saveBitriseAuthToken(value) {
      NotificationCenter.default.post(name: .didAuthorizeUserNotification, object: self)
      self.authorizationDelegate?.didAuthorizeSuccessfully(withToken: value)
      then?()
    }
  }
  
  func didCancelGeneration() {
    print("*** User cancelled token generation - not authorized")
  }
  
  
}
