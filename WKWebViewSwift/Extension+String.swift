//
//  String+Extension.swift
//  WKWebViewSwift
//
//  Created by Sean Patterson on 10/21/2018.
//  Copyright © 2018 Bosson Design. All rights reserved.
//

import Foundation

extension String {
    /// Intercept string
    ///
    /// - Parameter index: Intercept the string before the index bit
    /// - Returns: Return a new string
    func mySubString(to index: Int) -> String {
        return String(self[..<self.index(self.startIndex, offsetBy: index)])
    }
    /// Intercept string
    ///
    /// - Parameter index: Intercept the string from the index bit to the end
    /// - Returns: Return a new string
    func mySubString(from index: Int) -> String {
        return String(self[self.index(self.startIndex, offsetBy: index)...])
    }
}

