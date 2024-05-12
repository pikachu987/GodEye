//
//  UIAlertController+AppExtension.swift
//  Pods
//
//  Created by zixun on 16/9/25.
//
//

import Foundation
import UIKit

extension UIAlertController {
    
    static func quickTip(message: String, navigation: UINavigationController?, title: String = "Tip", cancelButtonTitle: String = "OK") {
        let alertView = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertView.addAction(UIAlertAction(title: cancelButtonTitle, style: .cancel))
        navigation?.present(alertView, animated: true, completion: nil)
    }
    
    static func quickConfirm(message: String,
                                   title: String,
                                   destructive: Bool = false,
                                   navigation: UINavigationController?,
                                   cancelButtonTitle: String = "No",
                                   confirmButtonTitle: String = "Yes",
                                   clickedButtonAtIndex: @escaping ( _ buttonIndex: Int) -> ()) {
        let alertView = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertView.addAction(UIAlertAction(title: cancelButtonTitle, style: .cancel) { _ in
            clickedButtonAtIndex(0)
        })
        
        let style = destructive == false ? UIAlertAction.Style.default : .destructive
        alertView.addAction(UIAlertAction(title: confirmButtonTitle, style: style) { _ in
            clickedButtonAtIndex(1)
        })
        
        navigation?.present(alertView, animated: true, completion: nil)
    }
}
