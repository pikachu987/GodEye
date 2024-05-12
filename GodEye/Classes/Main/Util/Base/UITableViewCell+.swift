//
//  UITableViewCell+.swift
//  Pods
//
//  Created by zixun on 17/1/4.
//
//

import UIKit

extension UITableViewCell {
    static var identifier: String {
        NSStringFromClass(classForCoder())
    }
}
