//
//  CommandModel.swift
//  Pods
//
//  Created by zixun on 17/1/7.
//
//

import Foundation

final class CommandRecordModel: NSObject {
    let command: String
    let actionResult: String

    init(command: String, actionResult: String) {
        self.command = command
        self.actionResult = actionResult
        super.init()
    }
}
