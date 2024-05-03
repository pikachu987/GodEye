//
//  LogRecordModel.swift
//  Pods
//
//  Created by zixun on 16/12/28.
//
//

import Foundation

enum LogRecordModelType:Int {
    case asl = 1
    case log = 2
    case warning = 3
    case error = 4
    
    var string: String {
        switch self {
        case .asl: return "ASL"
        case .log: return "LOG"
        case .warning:return "WARNING"
        case .error:return "ERROR"
        }
    }
    
    var color: UIColor {
        switch self {
        case .asl: return UIColor(hex: 0x94C76F)
        case .log: return UIColor(hex: 0x94C76F)
        case .warning: return UIColor(hex: 0xFEC42E)
        case .error: return UIColor(hex: 0xDF1921)
        }
    }
}

final class LogRecordModel: NSObject {
    let type: LogRecordModelType

    /// message be logged
    let message: String

    /// date for Time stamp
    let date: String?

    /// thread which log the message
    let thread: String?

    /// filename with extension
    let file: String?

    /// number of line in source code file
    let line: Int?

    /// name of the function which log the message
    let function: String?

    init(model: LogModel) {
        self.type = Self.type(of: model.type)
        self.message = model.message
        date = model.date.string(with: "yyyy-MM-dd HH:mm:ss")
        thread = model.thread.threadName
        file = model.file
        line = model.line
        function = model.function
        super.init()
    }
    
    init(type: LogRecordModelType,
         message: String,
         date: String? = nil,
         thread: String? = nil,
         file: String? = nil,
         line: Int? = nil,
         function: String? = nil) {
        self.type = type
        self.message = message
        self.date = date
        self.thread = thread
        self.file = file
        self.line = line
        self.function = function
        super.init()
    }
    
    private static func type(of log4gType: Log4gType) -> LogRecordModelType {
        switch log4gType {
        case .log: return .log
        case .warning: return .warning
        case .error: return .error
        }
    }
}
