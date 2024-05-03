//
//  UIView+AppBaseKit.swift
//  Pods
//
//  Created by zixun on 16/9/25.
//
//

import Foundation
import UIKit

extension UIView {
    
    /**
     if view or subviews is first responder, find and resign it
     
     - returns: retun true if find and resign first responder, otherwise return false
     */
    public func findAndResignFirstResponder() -> Bool {
        if isFirstResponder {
            resignFirstResponder()
            return true
        }
        
        for subview in subviews {
            if subview.findAndResignFirstResponder() {
                return true
            }
        }
        
        return false
    }
}
