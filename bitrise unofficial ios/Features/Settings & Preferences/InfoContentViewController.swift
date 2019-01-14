//
//  InfoContentViewController.swift
//  bitrise unofficial ios
//
//  Created by Alexei Gudimenko on 19/11/18.
//  Copyright © 2018 Alexei Gudimenko. All rights reserved.
//

import UIKit
import MarkdownView
import SafariServices

enum InfoPageSelector {
  case acknowledgements
}

class InfoContentViewController: UIViewController {
  
  @IBOutlet weak var markdownContentView: MarkdownView!
  
  private var content: String = ""
  
  var pageSelector: InfoPageSelector = .acknowledgements
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    setupMarkdownView()
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    loadContentFromFile()
  }
  
  private func setupMarkdownView() {
    markdownContentView.onTouchLink  = { [weak self] request in
      guard let url = request.url, url.scheme == "https" else {
        return false
      }
      
      let safariVC = SFSafariViewController(url: url)
      safariVC.preferredControlTintColor = Asset.Colors.bitriseGreen.color
      self?.present(safariVC, animated: true, completion: nil)
      return true
    }
  }

  private func loadContentFromFile() {
    
    guard let path = Bundle.main.path(forResource: "Acknowledgements", ofType: ".md") else {
      print("Failed to get markdown file at specified path")
      return
    }
    
    do {
      let contentString = try String(contentsOfFile: path, encoding: .utf8)
      //print(contentString)
      markdownContentView.load(markdown: contentString)
    } catch let error {
      print("Markdown String parsing error: \(error.localizedDescription)")
    }
  }
}
