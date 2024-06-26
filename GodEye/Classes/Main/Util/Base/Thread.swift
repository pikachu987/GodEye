//
//  Thread.swift
//  Pods
//
//  Created by zixun on 17/1/11.
//
//

import Foundation

extension Thread {
    var threadName: String {
        get {
            if isMainThread {
                return "Main"
            } else if let name = name, !name.isEmpty {
                return name
            } else {
                return String(format:"%p", self)
            }
        }
    }
}
