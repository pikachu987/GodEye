//
//  CrashRecordModel.swift
//  Pods
//
//  Created by zixun on 16/12/28.
//
//

import Foundation

final class CrashRecordModel: NSObject {
    public let type: CrashModelType
    public let name: String
    public let reason: String
    public let appinfo: String
    public let callStack: String
    
    init(model: CrashModel) {
        self.type = model.type
        self.name = model.name
        self.reason = model.reason
        self.appinfo = model.appinfo
        self.callStack = model.callStack
        super.init()
    }
    
    init(type: CrashModelType, name: String, reason: String, appinfo: String, callStack: String) {
        self.type = type
        self.name = name
        self.reason = reason
        self.appinfo = appinfo
        self.callStack = callStack
        super.init()
    }
}
