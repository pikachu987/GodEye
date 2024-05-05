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
    
    static var filterTypes: [RecordORMFilterType] {
        [.init(title: "ALL", value: nil)] +
        LogRecordModelType.allCases
            .map { .init(title: $0.string, value: "\($0.rawValue)") }
    }
    
    static func mappingToObject(with row: Row) -> LogRecordModel {
        LogRecordModel(type: LogRecordModelType(rawValue: row[Col.type]) ?? .asl,
                      message: row[Col.message],
                      date: row[Col.date],
                      thread: row[Col.thread],
                      file:row[Col.file],
                      line: row[Col.line],
                      function: row[Col.function])
    }
    
    static func configure(tableBuilder: TableBuilder) {
        tableBuilder.column(Col.type)
        tableBuilder.column(Col.message)
        tableBuilder.column(Col.date)
        tableBuilder.column(Col.thread)
        tableBuilder.column(Col.file)
        tableBuilder.column(Col.line)
        tableBuilder.column(Col.function)
    }
    
    static func configure(select table: Table, filterType: RecordORMFilterType, filterText: String) -> Table {
        let table = table.select(Col.type,
                                 Col.message,
                                 Col.date,
                                 Col.thread,
                                 Col.file,
                                 Col.line,
                                 Col.function)
        if let value = filterType.value, let rawValue = Int(value) {
            let filterTable = table.filter(Col.type == rawValue)
            if filterText.isEmpty { return filterTable }
            return filterTable.filter(Col.message.like("%\(filterText)%") ||
                        Col.date.like("%\(filterText)%") ||
                        Col.thread.like("%\(filterText)%") ||
                        Col.file.like("%\(filterText)%") ||
                        Col.function.like("%\(filterText)%"))
        } else {
            if filterText.isEmpty { return table }
            return table.filter(Col.message.like("%\(filterText)%") ||
                                Col.date.like("%\(filterText)%") ||
                                Col.thread.like("%\(filterText)%") ||
                                Col.file.like("%\(filterText)%") ||
                                Col.function.like("%\(filterText)%"))
        }
    }

    func mappingToRelation() -> [Setter] {
        [Col.type <- type.rawValue,
         Col.date <- date,
         Col.thread <- thread,
         Col.file <- file,
         Col.line <- line,
         Col.function <- function,
         Col.message <- message]
    }

    func attributeString(type: RecordORMAttributedType, filterType: RecordORMFilterType?, filterText: String?) -> NSAttributedString {
        LogRecordViewModel(self).attributeString(type: type, filterType: filterType, filterText: filterText)
    }

    class Col: NSObject {
        static let type = Expression<Int>("type")
        static let message = Expression<String>("message")
        static let date = Expression<String?>("date")
        static let thread = Expression<String?>("thread")
        static let file = Expression<String?>("file")
        static let line = Expression<Int?>("line")
        static let function = Expression<String?>("function")
    }
}

