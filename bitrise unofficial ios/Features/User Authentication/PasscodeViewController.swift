//
//  PasscodeViewController.swift
//  bitrise unofficial ios
//
//  Created by Alexei Gudimenko on 5/11/18.
//  Copyright © 2018 Alexei Gudimenko. All rights reserved.
//

import UIKit

protocol PasscodeViewControllerDelegate: class {
  func didCompletePasscodeSetup()
  func didCancelPasscodeSetup()
}

class PasscodeViewController: UIViewController {
  
  weak var delegate: PasscodeViewControllerDelegate?
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    // Do any additional setup after loading the view.
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
