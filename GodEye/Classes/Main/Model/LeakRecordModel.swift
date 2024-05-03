//
//  LeakRecordModel.swift
//  Pods
//
//  Created by zixun on 17/1/12.
//
//

import Foundation

final class LeakRecordModel: NSObject {
    let clazz: String
    let address: String

    init(obj: NSObject) {
        self.clazz = NSStringFromClass(obj.classForCoder)
        self.address = String(format:"%p", obj)
    }
    
    init(clazz: String, address: String) {
        self.clazz = clazz
        self.address = address
        super.init()
    }
}
