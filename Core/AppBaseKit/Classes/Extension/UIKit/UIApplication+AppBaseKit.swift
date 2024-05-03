//
//  UIApplication+AppBaseKit.swift
//  Pods
//
//  Created by zixun on 16/9/25.
//
//

import Foundation
import UIKit


// MARK: - MainWindow
extension UIApplication {
    
    public func mainWindow() -> UIWindow? {
        guard let delegate = delegate else {
            return keyWindow
        }
        
        guard delegate.responds(to: #selector(getter: UIApplicationDelegate.window)) else {
            return keyWindow
        }
        
        return delegate.window?.flatMap { $0 }
    }
}

