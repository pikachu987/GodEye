//
// Created by zixun on 2018/5/13.
// Copyright (c) 2018 zixun. All rights reserved.
//

import Foundation
import UIKit

extension UIView {
    @objc open func hook_setNeedsLayout() {
        checkThread()
        hook_setNeedsLayout()
    }
    
    @objc open func hook_setNeedsDisplay(_ rect: CGRect) {
        checkThread()
        hook_setNeedsDisplay(rect)
    }

    func checkThread() {
        assert(Thread.isMainThread,"You changed UI element not on main thread")
    }
}

class UIThreadEye: NSObject {
    static func open() {
        if isSwizzled == false {
            isSwizzled = true
            hook()
        } else {
            print("[NetworkEye] already started or hook failure")
        }
    }
    
    static  func close() {
        if isSwizzled == true {
            isSwizzled = false
            hook()
        } else {
            print("[NetworkEye] already stoped or hook failure")
        }
    }
    
    static var isWatching: Bool  {
        get {
            isSwizzled
        }
    }

    private class func hook() {
        _ = UIView.swizzleInstanceMethod(origSelector: #selector(UIView.setNeedsLayout),
                                         toAlterSelector: #selector(UIView.hook_setNeedsLayout))
        _ = UIView.swizzleInstanceMethod(origSelector: #selector(UIView.setNeedsDisplay(_:)),
                                         toAlterSelector: #selector(UIView.hook_setNeedsDisplay(_:)))
    }
    
    private static var isSwizzled: Bool {
        set {
            objc_setAssociatedObject(self, &key.isSwizzled, isSwizzled, .OBJC_ASSOCIATION_ASSIGN)
        }
        get {
            guard let result = objc_getAssociatedObject(self, &key.isSwizzled) as? Bool else { return false }
            return result
        }
    }
    
    private struct key {
        static var isSwizzled: Character = "c"
    }
}
