//
//  NewBuildViewController.swift
//  bitrise unofficial ios
//
//  Created by Alexei Gudimenko on 10/8/18.
//  Copyright © 2018 Alexei Gudimenko. All rights reserved.
//

import UIKit
import SkyFloatingLabelTextField
import SVProgressHUD
import Fabric
import Crashlytics
import Lottie

// FIXME: - consider moving this elsewhere. Try to avoid global strings
let didStartNewBuildNotification: String = "didStartNewBuildNotification"

protocol StartBuildDelegate: class {
  func didStartNewBuild(from controller: NewBuildViewController)
  func didCancelNewBuild(from controller: NewBuildViewController)
}

class NewBuildViewController: UIViewController {
  
  @IBOutlet weak var branchTextField: SkyFloatingLabelTextFieldWithIcon!
  @IBOutlet weak var workflowTextField: SkyFloatingLabelTextFieldWithIcon!
  @IBOutlet weak var commitMessageTextField: SkyFloatingLabelTextFieldWithIcon!
  @IBOutlet weak var startBuildButton: UIButton!
  
  @IBOutlet var textFields: [SkyFloatingLabelTextFieldWithIcon]!
  
  weak var startBuildDelegate: StartBuildDelegate?
  
  var app: BitriseApp?
  
  var branch: String = ""
  var workflow: String = ""
  var message: String = ""
  
  // pan/swipe gesture vars
  var initialTouchPoint: CGPoint = CGPoint(x: 0, y: 0)
  
  private var selectionFeedbackGenerator: UISelectionFeedbackGenerator? = UISelectionFeedbackGenerator()
  private var notificationFeedbackGenerator: UINotificationFeedbackGenerator? = UINotificationFeedbackGenerator()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    configureTextFields()
    configureSwipeModal()
    configureProgressViews()
    
    selectionFeedbackGenerator?.prepare()
    notificationFeedbackGenerator?.prepare()
    
//    Answers.logContentView(withName: "Start New Build",
//                           contentType: "Start new app build scene",
//                           contentId: nil, customAttributes: nil)
  }
  
  @IBAction func didTapStartBuild() {
    
    selectionFeedbackGenerator?.selectionChanged()
    
    SVProgressHUD.show(withStatus: "Starting Build")
    // gather stuff from text fields, then send API request
    // Only the branch is required
    
    guard validated().result == .success else {
      branchTextField.errorMessage = branch.isEmpty ? "Required" : ""
      dismissStartHUD()
      DispatchQueue.main.async {
        self.notificationFeedbackGenerator?.notificationOccurred(.warning)
      }
      showErrorAlert(withTitle: "Invalid Build Configuration",
                     withMessage: validated().message)
      return
    }
    
    let buildData = BuildData(branch: branch, workflowId: workflow, commitMessage: message)
    
    App.sharedInstance.apiClient
      .startNewBuild(for: app!, withBuildParams: buildData) { result, message in
        //Answers.logCustomEvent(withName: "Started Build", customAttributes: nil)
        print("*** Start New Build: \(message)")
        switch result {
        case .success:
          print("*** \(message)")
          // 1. close controller
          NotificationCenter
            .default
            .post(name: NSNotification.Name(rawValue: didStartNewBuildNotification), object: nil)
          self.dismissStartHUD()
          DispatchQueue.main.async {
            self.notificationFeedbackGenerator?.notificationOccurred(.success)
          }
          //self.closeTapticEngines()
          self.startBuildDelegate?.didStartNewBuild(from: self)
          self.dismiss(animated: true, completion: nil)
        case .error:
          self.dismissStartHUD()
          DispatchQueue.main.async {
            self.notificationFeedbackGenerator?.notificationOccurred(.error)
          }
          self.showErrorAlert(withTitle: "Failed to Start Build", withMessage: message)
          print("*** \(message)")
        }
    }
  }
  
  @IBAction func didTapDismiss() {
    dismissStartHUD()
    //closeTapticEngines()
    startBuildDelegate?.didCancelNewBuild(from: self)
    dismiss(animated: true, completion: nil)
  }
  
  /// Checks branch, workflow and message variables for valid input and that the app isn't nil
  ///
  /// - Returns: true if all parameters are correct, false if not
  func validated() -> (result: AsyncResult, message: String) {
    // add new validation rules as necessary
    guard !branch.isEmpty else {
      //assertionFailure(L10n.branchParamRequired)
      return (.error, L10n.branchParamRequired)
    }
    
    guard app != nil else {
      assertionFailure("*** App property wasn't initialised in view controller. This property must " +
        "be populated with a valid Bitrise App to allow posting new builds")
      return (.error, "*** App property wasn't initialised in view controller. This property must " +
        "be populated with a valid Bitrise App to allow posting new builds")
    }
    
    return (.success, "Valid Params")
  }
  
  
  private func showErrorAlert(withTitle errorName: String, withMessage errorMessage: String) {
    // TODO: - replace with an alert controller presentation
    print("*** Error \(errorName): \(errorMessage)")
    SVProgressHUD.showError(withStatus: errorMessage)
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


extension NewBuildViewController: UITextFieldDelegate {
  
  func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange,
                 replacementString string: String) -> Bool {
    branchTextField.errorMessage = branch.isEmpty ? "Required" : ""
    return true
  }
  
  func textFieldShouldReturn(_ textField: UITextField) -> Bool {
    // Manage 'done' key action on the software keyboard
    switch textField {
    case branchTextField:
      workflowTextField.becomeFirstResponder()
      branchTextField.errorMessage = branch.isEmpty ? "Required" : ""
    case workflowTextField:
      commitMessageTextField.becomeFirstResponder()
    case commitMessageTextField:
      view.endEditing(true)
    default:
      view.endEditing(true)
    }
    
    return true
  }
  
  @objc func textFieldDidChangeValue(_ textField: UITextField) {
    //print("*** \(textField.text ?? "") in \(textField)")
    switch textField {
    case branchTextField:
      branch = textField.text ?? ""
      branchTextField.errorMessage = branch.isEmpty ? "Required" : ""
    case workflowTextField:
      workflow = textField.text ?? ""
    case commitMessageTextField:
      message = textField.text ?? ""
    default:
      print("*** \(textField.text ?? "") in \(textField)")
    }
  }
  
  func textFieldDidEndEditing(_ textField: UITextField) {
    if textField == branchTextField {
      branchTextField.errorMessage = branch.isEmpty ? "Required" : ""
    }
  }
}


// MARK: - Helpers
extension NewBuildViewController {
  
  fileprivate func configureTextFields() {
    
    for f in textFields {
      f.delegate = self
      f.addTarget(self, action: #selector(textFieldDidChangeValue(_:)), for: [.editingChanged])
    }
    
    // When view appears, help the user by automatically making the first text field active.
    branchTextField.becomeFirstResponder()
  }
  
  fileprivate func configureSwipeModal() {
    let panGR = UIPanGestureRecognizer(target: self, action: #selector(didStartPanGesture(_:)))
    view.addGestureRecognizer(panGR)
  }
  
  @IBAction @objc private func didStartPanGesture(_ sender: UIPanGestureRecognizer) {
    let touchPoint = sender.location(in: view?.window)
    
    switch sender.state {
    case .began:
      initialTouchPoint = touchPoint
    case .changed:
      if touchPoint.y - initialTouchPoint.y > 0 {
        self.view.frame = CGRect(x: 0,
                                 y: touchPoint.y - initialTouchPoint.y,
                                 width: view.frame.size.width,
                                 height: view.frame.size.height)
      }
    case .ended, .cancelled:
      if touchPoint.y - initialTouchPoint.y > 100 {
        didTapDismiss()
      } else {
        UIView.animate(withDuration: 0.3, animations: {
          self.view.frame = CGRect(x: 0,
                                   y: 0,
                                   width: self.view.frame.size.width,
                                   height: self.view.frame.size.height)
        })
      }
    default:
      ()
    }
  }
  
  fileprivate func configureProgressViews() {
    SVProgressHUD.setDefaultStyle(.dark)
  }
  
  fileprivate func dismissStartHUD() {
    DispatchQueue.main.async {
      if SVProgressHUD.isVisible() { SVProgressHUD.dismiss() }
    }
  }
  
  fileprivate func closeTapticEngines() {
    notificationFeedbackGenerator = nil
    selectionFeedbackGenerator = nil
  }
}