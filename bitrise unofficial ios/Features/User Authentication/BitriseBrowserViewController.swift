//
//  BitriseBrowserViewController.swift
//  bitrise unofficial ios
//
//  Created by Alexei Gudimenko on 18/6/18.
//  Copyright © 2018 Alexei Gudimenko. All rights reserved.
//

import UIKit
import WebKit


protocol TokenGenerationDelegate: class {
  func didGenerate(_ controller: BitriseBrowserViewController, token value: String, then: (() -> Void)?)
  func didCancelGeneration(_ controller: BitriseBrowserViewController)
}


class BitriseBrowserViewController: UIViewController {
  
  
  @IBOutlet weak var browserView: WKWebView!
  @IBOutlet weak var tokenInputTextField: UITextField!
  @IBOutlet weak var loadingProgressView: UIProgressView!
  
  
  weak var tokenGenerationDelegate: TokenGenerationDelegate?
  
  
  fileprivate var generatedToken = ""
  
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    // Do any additional setup after loading the view.
    setupWebview()
    setWebviewDelegates()
    loadBitriseURL()
  }
  
  
  deinit {
    browserView.removeObserver(self,
                               forKeyPath: #keyPath(WKWebView.estimatedProgress),
                               context: nil)
  }
  
  
  @IBAction func didTapCancel(_ sender: Any) {
    
    browserView.stopLoading()
    tokenGenerationDelegate?.didCancelGeneration(self)
    dismiss(animated: true, completion: nil)
  }
  
  
  @IBAction func didTapRefresh(_ sender: Any) {
    browserView.reload()
  }
  
  
  @IBAction func didTapSave(_ sender: Any) {
    
    guard let tokenValue = tokenInputTextField.text else {
      generatedToken = ""
      showInvalidTokenError()
      return
    }
    
    log.debug("*** Token text: \(tokenValue)")
    
    App.sharedInstance.apiClient.validateGeneratedToken(tokenValue) { [weak self] isValid, message in
      
      guard let strongSelf = self else { return }
      
      if isValid {
        self?.tokenGenerationDelegate?.didGenerate(strongSelf, token: tokenValue, then: nil)
        DispatchQueue.main.async {
          self?.dismiss(animated: true, completion: nil)
        }
        //print(message)
      } else {
        log.error("Token validation failed with error: \(message)")
      }
    }
  }
  
  
  private func setupWebview() {
    browserView
      .addObserver(self, forKeyPath: #keyPath(WKWebView.estimatedProgress),
                   options: .new, context: nil)
  }
  
  
  private func setWebviewDelegates() {
    browserView.navigationDelegate = self
    browserView.uiDelegate = self
  }
  
  
  private func showInvalidTokenError() {
    print("*** Invalid token")
  }
  
  
  override func observeValue(forKeyPath keyPath: String?, of object: Any?,
                             change: [NSKeyValueChangeKey: Any]?,
                             context: UnsafeMutableRawPointer?) {
    
    // https://stackoverflow.com/questions/47562977/swift-4-approach-for-observevalueforkeypath
    // use the link above to address the block-based KVO violation warning
    
    if keyPath == "estimatedProgress" {
      loadingProgressView.progress = Float(browserView.estimatedProgress)
    }
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


extension BitriseBrowserViewController: WKNavigationDelegate {
  
  fileprivate func loadBitriseURL() {
    
    guard let url = URL(string: "https://app.bitrise.io/me/profile#/security") else {
      assertionFailure("Couldn't return a URL object. Invalid URL string supplied")
      return
    }
    
    browserView.load(URLRequest(url: url))
    
  }
  
  // This function will add web page's title to the title bar
  func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
    title = webView.title
  }
  
  func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
    print("*** Couldn't load page due to \(error.localizedDescription)")
  }
}


extension BitriseBrowserViewController: WKUIDelegate {
  
}
