//
//  ViewController.swift
//  WKWebViewSwift
//
//  Created by Sean Patterson on 10/21/2018.
//  Copyright © 2018 Bosson Design. All rights reserved.
//

import UIKit
import WebKit
import StoreKit

class ViewController: UIViewController {

    @IBOutlet weak var webView: WebView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //code for review popup
        if #available(iOS 10.3, *) {
            kReviewMe().showReviewView(afterMinimumLaunchCount: 4)
        }else{
            // Review View is unvailable for lower versions. Please use your custom view.
        }
   
        //self.automaticallyAdjustsScrollViewInsets = false
        
        // webView style
        var config = WkwebViewConfig()
        config.isShowScrollIndicator = false
        config.isProgressHidden = false
        
        webView.delegate = self as? WKWebViewDelegate
        
        // Load URL
        webView.webConfig = config
        webView.webloadType(self, .URLString(url: "https://m.facebook.com"))
        
        // Load Local URL
//        config.scriptMessageHandlerArray = ["valueName"]
//        webView.webConfig = config
//        webView.delegate = self
//        webView.webloadType(self, .HTMLName(name: "test"))
//
        // POST Load
//        let mobile = ""
//        let pop = ""
//        let auth = ""
//        let param = ["mobile":"\(mobile)","pop":"\(pop)","auth":"\(auth)"];
//        webView.webConfig = config
//        webView.webloadType(self, .POST(url: "http://xxxxx", parameters: param))
        
        
    }
    @IBAction func refreshClick(_ sender: UIBarButtonItem) {
        webView.reload()
    }
    
}

    func webViewUserContentController(_ scriptMessageHandlerArray: [String], didReceive message: WKScriptMessage) {
        print(message.body)
    }
    
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        print("Loading")
    }
