//
//  CommandRecordModel+ORM.swift
//  Pods
//
//  Created by zixun on 17/1/9.
//
//

import Foundation
import SQLite

extension CommandRecordModel: RecordORMProtocol {
    var isPreview: Bool { false }

    static var type: RecordType { .command }
    
    static var filterTypes: [RecordORMFilterType] {
        [.init(title: "all", value: nil)] +
        FilterType.allCases
            .map { .init(title: $0.title, value: "\($0.value)") }
    }

    static func mappingToObject(with row: Row) -> CommandRecordModel {
        CommandRecordModel(command: row[Col.command],
                           actionResult: row[Col.actionResult])
    }
    
    static func configure(tableBuilder: TableBuilder) {
        tableBuilder.column(Col.command)
        tableBuilder.column(Col.actionResult)
    }
    
    static func configure(select table: Table, filterType: RecordORMFilterType, filterText: String) -> Table {
        let table = table.select(Col.command,
                                 Col.actionResult)
        guard !filterText.isEmpty else { return table }
        if let value = filterType.value {
            return table.filter(Expression<String>(value).like("%\(filterText)%"))
        } else {
            return table.filter(Col.command.like("%\(filterText)%") ||
                                Col.actionResult.like("%\(filterText)%"))
        }
    }

    func mappingToRelation() -> [Setter] {
        [Col.command <- command,
         Col.actionResult <- actionResult]
    }

    func attributeString(type: RecordORMAttributedType, filterType: RecordORMFilterType?, filterText: String?) -> NSAttributedString {
        CommandRecordViewModel(self).attributeString(type: type, filterType: filterType, filterText: filterText)
    }

    class Col: NSObject {
        static let command = Expression<String>("command")
        static let actionResult = Expression<String>("actionResult")
    }

    enum FilterType: FilterTypeable {
        case command
        case result

        var title: String {
            switch self {
            case .command: return "command"
            case .result: return "result"
            }
        }

        var value: String {
            switch self {
            case .command: return "command"
            case .result: return "actionResult"
            }
        }

        func equal(filterType: RecordORMFilterType?) -> Bool {
            filterType?.title == title && filterType?.value == value
        }
    }
}
