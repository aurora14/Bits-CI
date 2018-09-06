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

protocol StartBuildDelegate: class {
  func didStartNewBuild(from controller: NewBuildViewController)
  func didCancelNewBuild(from controller: NewBuildViewController)
}

class NewBuildViewController: UIViewController {
  
  @IBOutlet weak var projectNameLabel: UILabel!
  @IBOutlet weak var branchTextField: SkyFloatingLabelTextFieldWithIcon!
  @IBOutlet weak var workflowTextField: SkyFloatingLabelTextFieldWithIcon!
  @IBOutlet weak var commitMessageTextField: SkyFloatingLabelTextFieldWithIcon!
  @IBOutlet weak var startBuildButton: UIButton!
  @IBOutlet weak var container: UIView!
  
  @IBOutlet var textFields: [SkyFloatingLabelTextFieldWithIcon]!
  
  weak var startBuildDelegate: StartBuildDelegate?
  
  var app: BitriseApp?
  
  var branch: String = ""
  var workflow: String = ""
  var message: String = ""
  
  // pan/swipe gesture vars
  var containerYOrigin: CGFloat = 36
  var initialTouchPoint: CGPoint?
  
  private var selectionFeedbackGenerator: UISelectionFeedbackGenerator? = UISelectionFeedbackGenerator()
  private var notificationFeedbackGenerator: UINotificationFeedbackGenerator? = UINotificationFeedbackGenerator()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    configureContainer()
    configureProjectNameLabel()
    configureInitTouchPoint()
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
    
    // gather stuff from text fields, then send API request
    // The only required parameter is Branch
    guard validated().result == .success else {
      branchTextField.errorMessage = branch.isEmpty ? "Required" : ""
      DispatchQueue.main.async {
        self.notificationFeedbackGenerator?.notificationOccurred(.warning)
      }
      //      showErrorAlert(withTitle: "Invalid Build Configuration",
      //                     withMessage: validated().message)
      return
    }
    
    SVProgressHUD.show(withStatus: "Starting Build")
    
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
            .post(name: .didStartNewBuildNotification, object: self)
          self.dismissStartHUD()
          DispatchQueue.main.async {
            self.notificationFeedbackGenerator?.notificationOccurred(.success)
          }
          self.startBuildDelegate?.didStartNewBuild(from: self)
          self.didTapDismiss()
        case .error:
          self.dismissStartHUD()
          DispatchQueue.main.async {
            self.notificationFeedbackGenerator?.notificationOccurred(.error)
            self.showErrorAlert(withTitle: "Failed to Start Build", withMessage: message)
          }
          print("*** \(message)")
        }
    }
  }
  
  @IBAction func didTapDismiss() {
    dismissStartHUD()
    closeTapticEngines()
    startBuildDelegate?.didCancelNewBuild(from: self)
    
    UIView.animateKeyframes(withDuration: 1.0, delay: 0, options: [ .calculationModeCubic, .beginFromCurrentState ], animations: {
      UIView.addKeyframe(withRelativeStartTime: 0.0/1.0, relativeDuration: 0.6/1.0, animations: {
        DispatchQueue.main.async {
          self.dismiss(animated: true, completion: nil)
        }
      })
      UIView.addKeyframe(withRelativeStartTime: 0.4/1.0, relativeDuration: 0.6/1.0, animations: {
        DispatchQueue.main.async {
          self.dismiss(animated: true, completion: nil)
        }
      })
    }, completion: nil)
    
    UIView.animate(withDuration: 0.2, delay: 0, options: [ .beginFromCurrentState ], animations: {
      DispatchQueue.main.async {
        self.view.backgroundColor = .clear
      }
    }, completion: { _ in
      UIView.animate(withDuration: 1.0,
                     delay: 0,
                     options: [
                      .curveEaseInOut,
                      .beginFromCurrentState,
                      .preferredFramesPerSecond60,
                      .transitionCrossDissolve ], animations: {
                        DispatchQueue.main.async {
                          self.dismiss(animated: true, completion: nil)
                        }
      }, completion: nil)
    })
    
  }
  
  /// Checks branch, workflow and message variables for valid input and that the app isn't nil
  ///
  /// - Returns: true if all parameters are correct, false if not
  func validated() -> (result: AsyncResult, message: String) {
    // add new validation rules as necessary
    guard !branch.isEmpty else {
      return (.error, L10n.branchParamRequired)
    }
    
    guard app != nil else {
      assertionFailure(L10n.nullAppProperty)
      Answers.logCustomEvent(withName: "New Build Error", customAttributes: ["Reason": "Null App Property"])
      return (.error, L10n.nullAppProperty)
    }
    
    return (.success, "Valid Params")
  }
  
  
  private func showErrorAlert(withTitle errorName: String, withMessage errorMessage: String) {
    // TODO: - replace with an alert controller presentation
    // print("*** Error \(errorName): \(errorMessage)")
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
  
  fileprivate func configureContainer() {
    container.clipsToBounds = true
    container.layer.cornerRadius = 5
    container.layer.maskedCorners = [ .layerMinXMinYCorner, .layerMaxXMinYCorner ]
  }
  
  fileprivate func configureProjectNameLabel() {
    guard let app = app else {
      assertionFailure(L10n.nullAppProperty)
      return
    }
    
    projectNameLabel.text =
      app.title
      .capitalized
      .replacingOccurrences(of: "-", with: " ")
      .replacingOccurrences(of: "Ios", with: "iOS")
  }
  
  fileprivate func configureInitTouchPoint() {
    initialTouchPoint = CGPoint(x: 0, y: containerYOrigin)
  }
  
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
    
    let zeroOrigin: CGFloat = 0
    
    guard let initPoint = initialTouchPoint else {
      return
    }
    
    let touchPoint = sender.location(in: view?.window)
    
    switch sender.state {
    case .began:
      initialTouchPoint = touchPoint
    case .changed:
      if touchPoint.y - initPoint.y > zeroOrigin {
        self.container.frame = CGRect(x: zeroOrigin,
                                      y: touchPoint.y - initPoint.y + containerYOrigin,
                                      width: container.frame.size.width,
                                      height: container.frame.size.height)
      }
    case .ended, .cancelled:
      if touchPoint.y - initPoint.y > 150 {
        didTapDismiss()
      } else {
        UIView.animate(withDuration: 0.4, animations: {
          self.container.frame = CGRect(x: zeroOrigin,
                                        y: self.containerYOrigin,
                                        width: self.container.frame.size.width,
                                        height: self.container.frame.size.height)
        })
      }
    default:
      () // do nothing on any other states
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
