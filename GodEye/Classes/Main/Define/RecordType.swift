//
//  RecordType.swift
//  Pods
//
//  Created by zixun on 17/1/13.
//
//

import Foundation

private var unreadDic: [RecordType: Int] = [.log: 0,
                                            .crash: 0,
                                            .network: 0,
                                            .anr: 0,
                                            .leak: 0]

enum RecordType {
    case log
    case crash
    case network
    case anr
    case leak
    
    case command
}

// MARK: Filter
extension RecordType {
    var filterTypes: [RecordORMFilterType] {
        switch self {
        case .log: return LogRecordModel.filterTypes
        case .crash: return CrashRecordModel.filterTypes
        case .network: return NetworkRecordModel.filterTypes
        case .anr: return ANRRecordModel.filterTypes
        case .leak: return LeakRecordModel.filterTypes
        case .command: return CommandRecordModel.filterTypes
        }
    }
}

// MARK: Unred
extension RecordType {
    var unread: Int {
        unreadDic[self] ?? 0
    }
    
    func addUnread() {
        unreadDic[self] = unread + 1
    }
    
    func cleanUnread() {
        unreadDic[self] = 0
    }
}

// MARK: Title
extension RecordType {
    var title: String {
        switch self {
        case .log: return "Log"
        case .crash: return "Crash"
        case .network: return "Network"
        case .anr: return "ANR"
        case .leak: return "Leak"
        case .command: return "Terminal"
        default: return ""
        }
    }
    
    var detail: String {
        switch self {
        case .log: return "asl and logger information"
        case .crash: return "crash call stack information"
        case .network: return "request and response information"
        case .anr: return "anr call stack information"
        case .leak: return "memory leak information"
        case .command: return "terminal with commands and results"
        default: return ""
        }
    }
}


// MARK: - ORM
extension RecordType {
    func model() -> RecordORMProtocol.Type? {
        var clazz: AnyClass?
        switch self {
        case .log:
            clazz = LogRecordModel.classForCoder()
        case .crash:
            clazz = CrashRecordModel.classForCoder()
        case .network:
            clazz = NetworkRecordModel.classForCoder()
        case .anr:
            clazz = ANRRecordModel.classForCoder()
        case .command:
            clazz = CommandRecordModel.classForCoder()
        default:
            clazz = nil
        }
        return clazz as? RecordORMProtocol.Type
    }
    
    var tableName: String {
        switch self {
        case .log: return "t_log"
        case .crash: return "t_crash"
        case .network: return "t_natwork"
        case .anr: return "t_anr"
        case .leak: return "t_leak"
        case .command: return "t_command"
        }
    }
}
