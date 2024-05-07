//
//  UITableViewCell+.swift
//  Pods
//
//  Created by zixun on 17/1/4.
//
//

import UIKit

extension UITableViewCell {
    class var identifier: String {
        NSStringFromClass(classForCoder())
    }
}
