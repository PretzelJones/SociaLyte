//
//  UIBarButtonItem.swift
//  WKWebViewSwift
//
//  Created by Sean Patterson on 10/21/2018.
//  Copyright © 2018 Bosson Design. All rights reserved.
//

import UIKit

///MARK: Classification method can be extracted to use elsewhere
extension UIBarButtonItem {
    /// create UIBarButtonItem
    ///
    /// - parameter title:    title
    /// - parameter image:    image
    /// - parameter imageH:   highlight
    /// - parameter target:   target
    /// - parameter action:   action
    ///
    /// - returns: UIBarButtonItem
    convenience init(title: String?,image:String?,imageH:String? ,target: AnyObject?, action: Selector) {
        
        let backItemImage = UIImage.init(named: image ?? "")
        let backItemHlImage = UIImage.init(named: imageH ?? "")
        
        let backButton = UIButton.init(type: .system)
        
        backButton .setTitle(title, for: .normal)
        
        backButton.titleLabel?.font = UIFont.systemFont(ofSize: 17)
        
        backButton .setImage(backItemImage, for: .normal)
        backButton .setImage(backItemHlImage, for: .highlighted)
        
        if #available(iOS 11.0, *) {
            backButton.contentEdgeInsets = UIEdgeInsets.init(top: 0, left: -15,bottom: 0, right: 0);
            backButton.imageEdgeInsets = UIEdgeInsets.init(top: 0, left: -15,bottom: 0, right: 0);
        }
        backButton.sizeToFit()
        backButton.addTarget(target, action: action, for: .touchUpInside)
        
        self.init(customView: backButton)
    }
}
