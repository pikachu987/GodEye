//
//  UIFont+GodEye.swift
//  Pods
//
//  Created by zixun on 16/12/28.
//
//

import UIKit

extension UIFont {
    class func courier(with size: CGFloat) -> UIFont {
        return UIFont(name: "Courier", size: size) ?? .systemFont(ofSize: size)
    }
}
