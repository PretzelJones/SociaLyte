//
//  WkwebViewConfig.swift
//  WKWebViewSwift
//
//  Created by Sean Patterson on 10/21/2018.
//  Copyright © 2018 Bosson Design. All rights reserved.
//

import Foundation
import WebKit

struct WkwebViewConfig {
    
    /// WKScriptMessageHandler
    /// Add a name and you can send a message through this name in JS：valueName Custom name
    /// window.webkit.messageHandlers.valueName.postMessage({body: 'xxx'})
    public var scriptMessageHandlerArray: [String] = [String]()
    
    /// Default min font
    public var minFontSize: CGFloat = 0
    
    /// Display scroll bar
    public var isShowScrollIndicator: Bool = true
    
    /// Turn on gesture interaction
    public var isAllowsBackForwardGestures: Bool = true
    
    /// Whether to allow loading javaScript
    public var isjavaScriptEnabled: Bool = true
    
    /// Whether to allow JS to automatically open the window, must be opened by user interaction
    public var isAutomaticallyJavaScript: Bool = true
    
    /// Whether the shadow progress bar
    public var isProgressHidden:Bool = false
    
    /// Progress bar height
    public var progressHeight:CGFloat = 3
    
    /// Default color
    public var progressTrackTintColor:UIColor = UIColor.clear
    
    /// Loading color
    public var progressTintColor:UIColor = UIColor.green
    
    /// Configure Alipay payment to return successfully APPScheme (not sure what this is)
    //public var aliPayScheme:String = "zhianjia"
    
}
//Page load type
enum WkwebLoadType{
    
    /// Load ordinary URL
    case URLString(url:String)
    
    /// Load local HTML (pass the name on it)
    case HTMLName(name:String)
    
    /// Load POST request (url: request URL, parameters: request parameters)
    case POST(url:String,parameters: [String:Any])
}

protocol WKWebViewDelegate:class {
    
    /// Called when the server starts the request
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void)
    
    /// Page starts loading
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!)
    
    /// Page loading completed
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!)
    
    /// Called when the jump fails
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error)
    
    /// Content loading failed
    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error)
    
    /// Execute JS injection method
    func webViewUserContentController(_ scriptMessageHandlerArray:[String], didReceive message: WKScriptMessage)
    
    /// JS execution callback method
    func webViewEvaluateJavaScript(_ result:Any?,error:Error?)
}

extension WKWebViewDelegate {
    /// Called when the server starts the request
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void){}
    
    /// Page starts loading
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!){}
    
    /// Page loading completed
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!){}
    
    /// Called when the jump fails
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error){}
    
    /// Content loading failed
    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error){}
    
    /// Execute JS injection method
    func webViewUserContentController(_ scriptMessageHandlerArray:[String], didReceive message: WKScriptMessage){}
    
    /// JS execution callback method
    func webViewEvaluateJavaScript(_ result:Any?,error:Error?){}
}

