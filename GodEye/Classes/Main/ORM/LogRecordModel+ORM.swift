//
//  LogRecordModel+ORM.swift
//  Pods
//
//  Created by zixun on 17/1/9.
//
//

import Foundation
import SQLite

extension LogRecordModel: RecordORMProtocol {
    static var type: RecordType { .log }

    func mappingToRelation() -> [Setter] {
        [LogRecordModel.col.type <- type.rawValue,
        LogRecordModel.col.date <- date,
        LogRecordModel.col.thread <- thread,
        LogRecordModel.col.file <- file,
        LogRecordModel.col.line <- line,
        LogRecordModel.col.function <- function,
        LogRecordModel.col.message <- message]
    }
    
    static func mappingToObject(with row: Row) -> LogRecordModel {
        LogRecordModel(type: LogRecordModelType(rawValue: row[LogRecordModel.col.type]) ?? .asl,
                      message: row[LogRecordModel.col.message],
                      date: row[LogRecordModel.col.date],
                      thread: row[LogRecordModel.col.thread],
                      file:row[LogRecordModel.col.file],
                      line: row[LogRecordModel.col.line],
                      function: row[LogRecordModel.col.function])
    }
    
    static func configure(tableBuilder: TableBuilder) {
        tableBuilder.column(LogRecordModel.col.type)
        tableBuilder.column(LogRecordModel.col.message)
        tableBuilder.column(LogRecordModel.col.date)
        tableBuilder.column(LogRecordModel.col.thread)
        tableBuilder.column(LogRecordModel.col.file)
        tableBuilder.column(LogRecordModel.col.line)
        tableBuilder.column(LogRecordModel.col.function)
    }
    
    static func configure(select table: Table) -> Table {
        let filterTypes = [LogRecordModelType.asl, .log, .warning, .error].map { $0.rawValue }
        let filterString: String? = nil
        
        return table.select(LogRecordModel.col.type,
                            LogRecordModel.col.message,
                            LogRecordModel.col.date,
                            LogRecordModel.col.thread,
                            LogRecordModel.col.file,
                            LogRecordModel.col.line,
                            LogRecordModel.col.function)
            .filter(filterTypes.contains(LogRecordModel.col.type))
            .filter(LogRecordModel.col.message.like("%%\(filterString ?? "")%%"))
    }
    
    func attributeString(type: RecordORMAttributedType) -> NSAttributedString {
        LogRecordViewModel(self).attributeString(type: type)
    }

    class col: NSObject {
        static let type = Expression<Int>("type")
        static let message = Expression<String>("message")
        static let date = Expression<String?>("date")
        static let thread = Expression<String?>("thread")
        static let file = Expression<String?>("file")
        static let line = Expression<Int?>("line")
        static let function = Expression<String?>("function")

    }
}

