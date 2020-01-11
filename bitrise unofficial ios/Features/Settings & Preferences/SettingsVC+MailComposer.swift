//
//  SettingsVC+MailComposer.swift
//  bitrise unofficial ios
//
//  Created by Alexei Gudimenko on 29/1/19.
//  Copyright © 2019 Alexei Gudimenko. All rights reserved.
//

import UIKit
import MessageUI

extension SettingsViewController: MFMailComposeViewControllerDelegate {
  
  // TODO: - this needs its own section or abstraction. For now, it can live in an extension
  func startMailComposer() {
    
    guard MFMailComposeViewController.canSendMail() else {
      assertionFailure("The loaded environment is unable to send mail. Try testing on a different platform")
      // TODO: - present error to the user with alternative actions
      // TODO: - log error to analytics
      return
    }
    
    let composer = MFMailComposeViewController()
    composer.mailComposeDelegate = self
    
    // TODO: - add localised subjects
    // TODO: - move these strings to auto-gen or plist files
    composer.setSubject("Bits CI: App Support & Feedback - #Your issue here#")
    composer.setToRecipients(["animated_stardust_dev@gmx.com"])
    composer.setMessageBody(L10n.contactSupportBody, isHTML: false)
    
    present(composer, animated: true, completion: nil)
  }
  
  func mailComposeController(_ controller: MFMailComposeViewController,
                             didFinishWith result: MFMailComposeResult, error: Error?) {
    
    switch result {
    case .sent:
      // log sent analytics
      self.dismiss(animated: true, completion: nil)
    case .failed:
      // log failed error
      if error != nil { print ("Email couldn't be sent: \(String(describing: error?.localizedDescription))") }
    case .saved:
      // close controller or no-op
      self.dismiss(animated: true, completion: nil)
    case .cancelled:
      // close controller
      self.dismiss(animated: true, completion: nil)
    default:
      print("Mail composer error: \(String(describing: error?.localizedDescription))")
    }
  }
}

