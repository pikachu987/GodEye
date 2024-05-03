//
//  UIFont+AppBaseKit.swift
//  Pods
//
//  Created by zixun on 2016/10/29.
//
//

import Foundation
import UIKit

extension UIFont {
    class func allNames() -> [String] {
        UIFont.familyNames
            .map { UIFont.fontNames(forFamilyName: $0) }
            .flatMap { $0 }
    }
}
