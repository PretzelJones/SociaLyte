//
//  wk.swift
//  WKWebViewSwift
//
//  Created by Sean Patterson on 10/21/2018.
//  Copyright © 2018 Bosson Design. All rights reserved.
//

import UIKit
import WebKit

@IBDesignable
class WebView: UIView {
    
    // event
    fileprivate var target: AnyObject?
    
    // create webveiew
    fileprivate var webView = WKWebView()
    
    /// progress bar
    fileprivate var progressView = UIProgressView()
    
    /// create webiview configuration item
    fileprivate let configuretion = WKWebViewConfiguration()
    
    // implementing JS requires implementing a proxy method
    fileprivate var POSTJavaScript = String()
    
    // is it the first time loading?
    fileprivate var needLoadJSPOST:Bool?
    
    // WebView configuration item
    var webConfig : WkwebViewConfig?
    
    // save request link
    fileprivate var snapShotsArray:Array<Any>?
    
    // set proxy
    weak var delegate : WKWebViewDelegate?
    
    override public init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    open override func layoutSubviews() {
        super.layoutSubviews()
        webView.frame = CGRect(x: 0, y: 0, width: self.width, height: self.height)
    }
    
    fileprivate func setupUI(webConfig:WkwebViewConfig)  {
        // Webview preferences
        configuretion.preferences = WKPreferences()
        configuretion.preferences.minimumFontSize = webConfig.minFontSize
        configuretion.preferences.javaScriptEnabled = webConfig.isjavaScriptEnabled
        configuretion.preferences.javaScriptCanOpenWindowsAutomatically = webConfig.isAutomaticallyJavaScript
        configuretion.userContentController = WKUserContentController()
        _ = webConfig.scriptMessageHandlerArray.map{configuretion.userContentController.add(self, name: $0)}
        
        webView = WKWebView(frame:frame,configuration: configuretion)
        
        // turn on gesture interaction
        webView.allowsBackForwardNavigationGestures = webConfig.isAllowsBackForwardGestures
        
        // scroll bar
        webView.scrollView.showsVerticalScrollIndicator = webConfig.isShowScrollIndicator
        webView.scrollView.showsHorizontalScrollIndicator = webConfig.isShowScrollIndicator

        // listen for KVO-enabled properties
        webView.addObserver(self, forKeyPath: "estimatedProgress", options: .new, context: nil)
        // content adaptation
        webView.sizeToFit()
        self.addSubview(webView)
        
        progressView = UIProgressView(progressViewStyle: .default)
        progressView.frame = CGRect(x: 0, y: 0, width: webView.width, height: webConfig.progressHeight)
        progressView.trackTintColor = webConfig.progressTrackTintColor
        progressView.progressTintColor = webConfig.progressTintColor
        webView.addSubview(progressView)
        progressView.isHidden = webConfig.isProgressHidden
        
        webView.navigationDelegate = self
        webView.uiDelegate = self
    }
    
    /// load webView
    func webloadType(_ target:AnyObject,_ loadType:WkwebLoadType) {
        self.target = target
        setupUI(webConfig:webConfig ?? WkwebViewConfig())
        
        switch loadType {
            
        case .URLString(let urltring):
            let urlstr = URL(string: urltring)
            let request = URLRequest(url: urlstr!)
            webView.load(request)
            
        case .HTMLName(let string):
            loadHost(string: string)
            
        case .POST(let string, parameters: let postString):
            needLoadJSPOST = true
            // Add one to each key, value before and after“
            let dictMap = postString.map({"\"\($0.key)\":\"\($0.value)\""})
            POSTJavaScript = "post('\(string)\',{\(dictMap.joined(separator: ","))})"
            loadHost(string: "WKJSPOST")
        }
    }
    
    fileprivate func loadHost(string:String) {
        let path = Bundle.main.path(forResource: string, ofType: "html")
        // Get html content
        do {
            let html = try String(contentsOfFile: path!, encoding: String.Encoding.utf8)
            // Load js
            webView.loadHTMLString(html, baseURL: Bundle.main.bundleURL)
        } catch { }
    }
    
    /// Execute JavaScript code
    /// e.g. run_JavaScript(script:"document.getElementById('someElement').innerText")
    ///
    /// Parameter titleStr: title string
    public func run_JavaScript(javaScript:String?) {
        if let javaScript = javaScript {
            webView.evaluateJavaScript(javaScript) { result,error in
                print(error ?? "")
                self.delegate?.webViewEvaluateJavaScript(result, error: error)
            }
        }
    }
    
    /// refresh
    public func reload() {
        webView.reload()
    }
    /// retreat
    public func goBack() {
        webView.goBack()
    }
    /// go ahead
    public func goForward() {
        webView.goForward()
    }
    /// generic webView
    public func removeWebView(){
        webView.removeObserver(self, forKeyPath: "estimatedProgress")
        if let scriptMessage = webConfig?.scriptMessageHandlerArray {
            _ = scriptMessage.map{webView.configuration.userContentController .removeScriptMessageHandler(forName: $0)}
        }
        webView.navigationDelegate = nil
        webView.uiDelegate = nil
        self.removeFromSuperview()
    }
    // request link processing
    fileprivate func pushCurrentSnapshotView(_ request: NSURLRequest) -> Void {
        // Is the connection empty?
        guard let urlStr = snapShotsArray?.last else { return }
        // Convert to URL
        let url = URL(string: urlStr as! String)
        // Convert to NSURLRequest
        let lastRequest = NSURLRequest(url: url!)
        // If the url is very strange, it will not be pushed.
        if request.url?.absoluteString == "about:blank"{ return }
        // If the url is the same, it will not be pushed
        if (lastRequest.url?.absoluteString == request.url?.absoluteString) {return}
        // snapshotView
        let currentSnapShotView = webView.snapshotView(afterScreenUpdates: true);
        //Add a dictionary to the array
        snapShotsArray = [["request":request,"snapShotView":currentSnapShotView]]
    }
    
    open override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "estimatedProgress"{
            // Set progress bar transparency
            progressView.alpha = CGFloat(1.0 - webView.estimatedProgress)
            // Add progress and animation to the progress bar
            progressView.setProgress(Float(webView.estimatedProgress), animated: true)
            // End progress
            if Float(webView.estimatedProgress) >= 1.0{
                progressView.alpha = 0.0
                progressView .setProgress(0.0, animated: false)
            }
            print(webView.estimatedProgress)
        }
    }
}

// MARK: - WKScriptMessageHandler
extension WebView: WKScriptMessageHandler{
    
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        if let scriptMessage = webConfig?.scriptMessageHandlerArray {
            self.delegate?.webViewUserContentController(scriptMessage, didReceive: message)
        }
    }
}
// MARK: - WKNavigationDelegate
extension WebView: WKNavigationDelegate{
    
    // Called when the server starts the request
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        self.delegate?.webView(webView, decidePolicyFor: navigationAction, decisionHandler: decisionHandler)
        
        let navigationURL = navigationAction.request.url?.absoluteString
        if let requestURL = navigationURL?.removingPercentEncoding {
            //dial number
            //Android-compatible server writing: <a class = "mobile" href = "tel://phone number"></a>
            //Or: <a class = "mobile" href = "tel:phone number"></a>
            if requestURL.hasPrefix("tel://") {
                //Cancel WKWebView call request
                decisionHandler(.cancel);
                //Call with openURL this API
                if let mobileURL:URL = URL(string: requestURL) {
                    UIApplication.shared.open(mobileURL)
                }
            }
        }
        switch navigationAction.navigationType {
        case WKNavigationType.linkActivated:
            pushCurrentSnapshotView(navigationAction.request as NSURLRequest)
            break
        case WKNavigationType.formSubmitted:
            pushCurrentSnapshotView(navigationAction.request as NSURLRequest)
            break
        case WKNavigationType.backForward:
            break
        case WKNavigationType.reload:
            break
        case WKNavigationType.formResubmitted:
            break
        case WKNavigationType.other:
            pushCurrentSnapshotView(navigationAction.request as NSURLRequest)
            break
        }
        decisionHandler(.allow)
    }
    
    //Start loading
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        self.delegate?.webView(webView, didStartProvisionalNavigation: navigation)
    }
    
    //This is the page loading is complete, the navigation changes
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        self.delegate?.webView(webView, didFinish: navigation)
        // Determine if you need to load (only on the first load)
        if needLoadJSPOST == true {
            // Calling a method to send a POST request using JS
            run_JavaScript(javaScript: POSTJavaScript)
            // Set Flag to NO (you don't need to load it later)
            needLoadJSPOST = false
        }
    }
    
    //Called when the jump fails
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        self.delegate?.webView(webView, didFail: navigation, withError: error)
        print(error)
    }
    // Called when content fails to load
    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        self.delegate?.webView(webView, didFailProvisionalNavigation: navigation, withError: error)
        progressView.isHidden = true
        print(error)
    }
    
    // Open a new window delegate
    func webView(_ webView: WKWebView, createWebViewWith configuration: WKWebViewConfiguration, for navigationAction: WKNavigationAction, windowFeatures: WKWindowFeatures) -> WKWebView? {
        if navigationAction.targetFrame?.isMainFrame == nil {
            webView.load(navigationAction.request)
        }
        return nil
    }
}

// MARK: - WKUIDelegate Do not implement the proxy method. An exception is thrown when a popup is called within a web page, causing the program to crash.
extension WebView: WKUIDelegate{
    
    // Get tips in js
    func webView(_ webView: WKWebView, runJavaScriptAlertPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping () -> Void) {
        
        let alert = UIAlertController(title: "Heads Up", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Confirm", style: .default, handler: { (_) -> Void in
            completionHandler()
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (_) -> Void in
            completionHandler()
        }))
        target?.present(alert, animated: true, completion: nil)
    }
    
    // js Information exchange
    func webView(_ webView: WKWebView, runJavaScriptConfirmPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping (Bool) -> Void) {
        
        let alert = UIAlertController(title: "Heads Up", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Confirm", style: .default, handler: { (_) -> Void in
            completionHandler(true)
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (_) -> Void in
            completionHandler(false)
        }))
        target?.present(alert, animated: true, completion: nil)
    }
    
    // Interaction. The text that can be entered.
    func webView(_ webView: WKWebView, runJavaScriptTextInputPanelWithPrompt prompt: String, defaultText: String?, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping (String?) -> Void) {
        
        let alert = UIAlertController(title: prompt, message: defaultText, preferredStyle: .alert)
        
        alert.addTextField { (textField: UITextField) -> Void in
            textField.textColor = UIColor.red
        }
        alert.addAction(UIAlertAction(title: "Confirm", style: .default, handler: { (_) -> Void in
            completionHandler(alert.textFields![0].text!)
        }))
        target?.present(alert, animated: true, completion: nil)
    }
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertToUIApplicationOpenExternalURLOptionsKeyDictionary(_ input: [String: Any]) -> [UIApplication.OpenExternalURLOptionsKey: Any] {
	return Dictionary(uniqueKeysWithValues: input.map { key, value in (UIApplication.OpenExternalURLOptionsKey(rawValue: key), value)})
}
