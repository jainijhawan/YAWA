//
//  AboutViewController.swift
//  YAWA - Yet Another Weather App
//
//  Created by Jai Nijhawan on 13/12/20.
//  Copyright © 2020 Jai Nijhawan. All rights reserved.
//

import UIKit
import WebKit

class AboutViewController: UIViewController, WKNavigationDelegate  {
  
  @IBOutlet weak var webView: WKWebView!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    webView.navigationDelegate = self
    webView.load(URLRequest(url: URL(string: aboutWebViewUrl)!))
  }
  
  @IBAction func backButtonTapped(_ sender: Any) {
    self.dismiss(animated: true, completion: nil)
  }
  
  func webView(_ webView: WKWebView,
               decidePolicyFor navigationAction: WKNavigationAction,
               decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
    if navigationAction.navigationType == .linkActivated {
      decisionHandler(.cancel)
    } else {
      decisionHandler(.allow)
    }
  }
  
}
