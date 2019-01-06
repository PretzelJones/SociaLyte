//
//  ViewController.swift
//  WKWebViewSwift
//
//  Created by Sean Patterson on 10/21/2018.
//  Copyright © 2018 Bosson Design. All rights reserved.
//

import UIKit
import WebKit
//import StoreKit
//import CoreLocation

class ViewController: UIViewController {
    //class ViewController: UIViewController, CLLocationManagerDelegate {
    
    //var locationManager: CLLocationManager!
    
    @IBOutlet weak var webView: WebView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
      /*
        //required for loaction functionality
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.requestAlwaysAuthorization()
        locationManager.stopUpdatingLocation()
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        */
        //KReviewMe Code
        //kReviewMe().showReviewView(afterMinimumLaunchCount: 5)
        //code for review popup
        /*if #available(iOS 10.3, *) {
            kReviewMe().showReviewView(afterMinimumLaunchCount: 5)
        }else{
            // Review View is unvailable for lower versions. Please use your custom view.
        }*/
        
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

    //@IBAction func refreshClick(_ sender: UIBarButtonItem) {
      //  webView.reload()
    //}
    
}

extension ViewController: WKNavigationDelegate {
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        // show indicator
    }
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        // dismiss indicator
        
        // if url is not valid {
        //    decisionHandler(.cancel)
        // }
        decisionHandler(.allow)
    }

    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        // show error dialog
    }
}

extension ViewController: WKUIDelegate {
    func webView(_ webView: WKWebView, createWebViewWith configuration: WKWebViewConfiguration, for navigationAction: WKNavigationAction, windowFeatures: WKWindowFeatures) -> WKWebView? {
        if navigationAction.targetFrame == nil {
            webView.load(navigationAction.request)
        }
        return nil
    }
}
    func webViewUserContentController(_ scriptMessageHandlerArray: [String], didReceive message: WKScriptMessage) {
        print(message.body)
    }
    
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        print("Loading");
    }
    //handles opening of external links
    func webView(webView: WKWebView!, createWebViewWithConfiguration configuration: WKWebViewConfiguration!, forNavigationAction navigationAction: WKNavigationAction!, windowFeatures: WKWindowFeatures!) -> WKWebView! {
        if navigationAction.targetFrame == nil {
            webView.load(navigationAction.request)
    }
    return nil
}
