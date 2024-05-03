//
//  LogModel.swift
//  Pods
//
//  Created by zixun on 17/1/10.
//
//

import Foundation

public enum Log4gType: Int {
    case log = 1
    case warning = 2
    case error = 3
}

open class LogModel: NSObject {
    public let type: Log4gType

    /// date for Time stamp
    public let date: Date

    /// thread which log the message
    public let thread: Thread

    /// filename with extension
    public let file: String

    /// number of line in source code file
    public let line: Int

    /// name of the function which log the message
    public let function: String

    /// message be logged
    public let message: String

    init(type: Log4gType,
         thread: Thread,
         message: String,
         file: String,
         line: Int,
         function: String) {
        self.date = Date()
        self.type = type
        self.thread = thread
        self.file = file
        self.line = line
        self.function = function
        self.message = message
        super.init()
    }
}
