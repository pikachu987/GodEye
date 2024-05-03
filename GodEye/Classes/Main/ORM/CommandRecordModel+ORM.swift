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

    func mappingToRelation() -> [Setter] {
        [CommandRecordModel.col.command <- command,
         CommandRecordModel.col.actionResult <- actionResult]
    }
    
    static func mappingToObject(with row: Row) -> CommandRecordModel {
        CommandRecordModel(command: row[CommandRecordModel.col.command],
                           actionResult: row[CommandRecordModel.col.actionResult])
    }
    
    static func configure(tableBuilder: TableBuilder) {
        tableBuilder.column(CommandRecordModel.col.command)
        tableBuilder.column(CommandRecordModel.col.actionResult)
    }
    
    static func configure(select table: Table) -> Table {
        table.select(CommandRecordModel.col.command,
                     CommandRecordModel.col.actionResult)
    }
    
    func attributeString(type: RecordORMAttributedType) -> NSAttributedString {
        CommandRecordViewModel(self).attributeString(type: type)
    }
    
    class col: NSObject {
        static let command = Expression<String>("command")
        static let actionResult = Expression<String>("actionResult")
    }
}
