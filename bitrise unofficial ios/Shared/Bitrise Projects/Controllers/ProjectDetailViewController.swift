//
//  ProjectDetailViewController.swift
//  bitrise unofficial ios
//
//  Created by Alexei Gudimenko on 11/7/18.
//  Copyright © 2018 Alexei Gudimenko. All rights reserved.
//

import UIKit

class ProjectDetailViewController: UIViewController, UIGestureRecognizerDelegate {
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    title = "Builds"
    // Do any additional setup after loading the view.
    configureDefaultInteractiveGestures()
  }
  
  private func configureDefaultInteractiveGestures() {
    navigationController?.interactivePopGestureRecognizer?.delegate = self
    navigationController?.interactivePopGestureRecognizer?.isEnabled = true
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
