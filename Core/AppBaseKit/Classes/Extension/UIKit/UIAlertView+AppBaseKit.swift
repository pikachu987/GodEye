//
//  UIAlertView+AppBaseKit.swift
//  Pods
//
//  Created by zixun on 16/9/25.
//
//

import Foundation
import UIKit

private var key = "kUIAlertViewHandler"
extension UIAlertView {
    
    
    private var handler: UIAlertViewHandler? {
        set {
            objc_setAssociatedObject(self, &key, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
        get {
            (objc_getAssociatedObject(self, &key)).flatMap { $0 as? UIAlertViewHandler }
        }
    }
    
    
    
    static func quickTip(message: String,
                               title: String = "Tip",
                               cancelButtonTitle: String = "OK") {
        UIAlertView(title: title, message: message, delegate: nil, cancelButtonTitle: cancelButtonTitle).show()
    }
    
    static func quickConfirm(message: String,
                                   title: String,
                                   cancelButtonTitle: String = "No",
                                   confirmButtonTitle: String = "Yes",
                                   clickedButtonAtIndex: @escaping ( _ buttonIndex: Int) -> ()) {

        let alert = UIAlertView(title: title,
                                message: message,
                                delegate: nil,
                                cancelButtonTitle: cancelButtonTitle,
                                otherButtonTitles: confirmButtonTitle)
        
        alert.handler = UIAlertViewHandler { (handler, index) in
            clickedButtonAtIndex(index)
        }
        alert.delegate = alert.handler
        alert.show()
    }
}


private class UIAlertViewHandler: NSObject, UIAlertViewDelegate {
    typealias ClickBlock = (_ handler: UIAlertViewHandler, _ index: Int) -> ()

    private var clickBlock: ClickBlock?

    init(clickBlock: @escaping ClickBlock) {
        super.init()
        self.clickBlock = clickBlock
    }
    
    @objc func alertView(alertView: UIAlertView, clickedButtonAtIndex buttonIndex: Int) {
        clickBlock?(self, buttonIndex)
    }
}
