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
            // 给每一个key，value前后加上一个“
            let dictMap = postString.map({"\"\($0.key)\":\"\($0.value)\""})
            POSTJavaScript = "post('\(string)\',{\(dictMap.joined(separator: ","))})"
            loadHost(string: "WKJSPOST")
        }
    }
    
    fileprivate func loadHost(string:String) {
        let path = Bundle.main.path(forResource: string, ofType: "html")
        // 获得html内容
        do {
            let html = try String(contentsOfFile: path!, encoding: String.Encoding.utf8)
            // 加载js
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
        // 连接是否为空
        guard let urlStr = snapShotsArray?.last else { return }
        // 转换成URL
        let url = URL(string: urlStr as! String)
        // 转换成NSURLRequest
        let lastRequest = NSURLRequest(url: url!)
        // 如果url是很奇怪的就不push
        if request.url?.absoluteString == "about:blank"{ return }
        // 如果url一样就不进行push
        if (lastRequest.url?.absoluteString == request.url?.absoluteString) {return}
        // snapshotView
        let currentSnapShotView = webView.snapshotView(afterScreenUpdates: true);
        //向数组添加字典
        snapShotsArray = [["request":request,"snapShotView":currentSnapShotView]]
    }
    
    open override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "estimatedProgress"{
            // 设置进度条透明度
            progressView.alpha = CGFloat(1.0 - webView.estimatedProgress)
            // 给进度条添加进度和动画
            progressView.setProgress(Float(webView.estimatedProgress), animated: true)
            // 结束进度
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
    
    //服务器开始请求的时候调用
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        self.delegate?.webView(webView, decidePolicyFor: navigationAction, decisionHandler: decisionHandler)
        
        let navigationURL = navigationAction.request.url?.absoluteString
        if let requestURL = navigationURL?.removingPercentEncoding {
            //拨打电话
            //兼容安卓的服务器写法:<a class = "mobile" href = "tel://电话号码"></a>
            //或者:<a class = "mobile" href = "tel:电话号码"></a>
            if requestURL.hasPrefix("tel://") {
                //取消WKWebView 打电话请求
                decisionHandler(.cancel);
                //用openURL 这个API打电话
                if let mobileURL:URL = URL(string: requestURL) {
                    UIApplication.shared.open(mobileURL)
                }
            }
            // 支付宝支付
            if requestURL.hasPrefix("alipay://") {
                
                var urlString = requestURL.mySubString(from: 23)
                urlString = urlString.replacingOccurrences(of: "alipays", with: webConfig!.aliPayScheme)
                
                if let strEncoding = urlString.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed) {
                    
                    let payString = "alipay://alipayclient/?\(strEncoding)"
                    
                    if let urlalipayURL:URL = URL(string: payString) {
                        if #available(iOS 10.0, *) {
                            UIApplication.shared.open(urlalipayURL, options: convertToUIApplicationOpenExternalURLOptionsKeyDictionary([:]), completionHandler: { result in
                                self.webView.reload()
                            })
                        } else {
                            UIApplication.shared.openURL(urlalipayURL)
                        }
                    }
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
    
    //开始加载
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        self.delegate?.webView(webView, didStartProvisionalNavigation: navigation)
    }
    
    //这个是网页加载完成，导航的变化
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        self.delegate?.webView(webView, didFinish: navigation)
        // 判断是否需要加载（仅在第一次加载）
        if needLoadJSPOST == true {
            // 调用使用JS发送POST请求的方法
            run_JavaScript(javaScript: POSTJavaScript)
            // 将Flag置为NO（后面就不需要加载了）
            needLoadJSPOST = false
        }
    }
    
    //跳转失败的时候调用
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        self.delegate?.webView(webView, didFail: navigation, withError: error)
        print(error)
    }
    // 内容加载失败时候调用
    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        self.delegate?.webView(webView, didFailProvisionalNavigation: navigation, withError: error)
        progressView.isHidden = true
        print(error)
    }
    
    // 打开新窗口委托
    func webView(_ webView: WKWebView, createWebViewWith configuration: WKWebViewConfiguration, for navigationAction: WKNavigationAction, windowFeatures: WKWindowFeatures) -> WKWebView? {
        if navigationAction.targetFrame?.isMainFrame == nil {
            webView.load(navigationAction.request)
        }
        return nil
    }
}

// MARK: - WKUIDelegate 不实现该代理方法 网页内调用弹窗时会抛出异常,导致程序崩溃
extension WebView: WKUIDelegate{
    
    // 获取js 里面的提示
    func webView(_ webView: WKWebView, runJavaScriptAlertPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping () -> Void) {
        
        let alert = UIAlertController(title: "提示", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "确定", style: .default, handler: { (_) -> Void in
            completionHandler()
        }))
        alert.addAction(UIAlertAction(title: "取消", style: .cancel, handler: { (_) -> Void in
            completionHandler()
        }))
        target?.present(alert, animated: true, completion: nil)
    }
    
    // js 信息的交流
    func webView(_ webView: WKWebView, runJavaScriptConfirmPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping (Bool) -> Void) {
        
        let alert = UIAlertController(title: "提示", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "确定", style: .default, handler: { (_) -> Void in
            completionHandler(true)
        }))
        alert.addAction(UIAlertAction(title: "取消", style: .cancel, handler: { (_) -> Void in
            completionHandler(false)
        }))
        target?.present(alert, animated: true, completion: nil)
    }
    
    // 交互。可输入的文本。
    func webView(_ webView: WKWebView, runJavaScriptTextInputPanelWithPrompt prompt: String, defaultText: String?, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping (String?) -> Void) {
        
        let alert = UIAlertController(title: prompt, message: defaultText, preferredStyle: .alert)
        
        alert.addTextField { (textField: UITextField) -> Void in
            textField.textColor = UIColor.red
        }
        alert.addAction(UIAlertAction(title: "确定", style: .default, handler: { (_) -> Void in
            completionHandler(alert.textFields![0].text!)
        }))
        target?.present(alert, animated: true, completion: nil)
    }
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertToUIApplicationOpenExternalURLOptionsKeyDictionary(_ input: [String: Any]) -> [UIApplication.OpenExternalURLOptionsKey: Any] {
	return Dictionary(uniqueKeysWithValues: input.map { key, value in (UIApplication.OpenExternalURLOptionsKey(rawValue: key), value)})
}
