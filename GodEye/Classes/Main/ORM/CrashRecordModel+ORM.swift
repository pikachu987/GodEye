//
//  CrashRecordModel+ORM.swift
//  Pods
//
//  Created by zixun on 17/1/9.
//
//

import Foundation
import SQLite

extension CrashRecordModel: RecordORMProtocol {
    static var type: RecordType { .crash }
    
    func mappingToRelation() -> [Setter] {
        [CrashRecordModel.col.type <- type.rawValue,
         CrashRecordModel.col.name <- name,
         CrashRecordModel.col.reason <- reason,
         CrashRecordModel.col.appinfo <- appinfo,
         CrashRecordModel.col.callStack <- callStack]
    }
    
    static func mappingToObject(with row: Row) -> CrashRecordModel {
        let type = CrashModelType(rawValue: row[CrashRecordModel.col.type]) ?? .signal
        let name = row[CrashRecordModel.col.name]
        let reason = row[CrashRecordModel.col.reason]
        let appinfo = row[CrashRecordModel.col.appinfo]
        let callStack = row[CrashRecordModel.col.callStack]
        return CrashRecordModel(type: type, name: name, reason: reason, appinfo: appinfo, callStack: callStack)
    }
    
    static func configure(tableBuilder: TableBuilder) {
        tableBuilder.column(CrashRecordModel.col.type)
        tableBuilder.column(CrashRecordModel.col.name)
        tableBuilder.column(CrashRecordModel.col.reason)
        tableBuilder.column(CrashRecordModel.col.appinfo)
        tableBuilder.column(CrashRecordModel.col.callStack)
    }
    
    static func configure(select table: Table) -> Table {
        table.select(CrashRecordModel.col.type,
                     CrashRecordModel.col.name,
                     CrashRecordModel.col.reason,
                     CrashRecordModel.col.appinfo,
                     CrashRecordModel.col.callStack)
    }
    
    func attributeString(type: RecordORMAttributedType) -> NSAttributedString {
        CrashRecordViewModel(self).attributeString(type: type)
    }
    
    class col: NSObject {
        static let type = Expression<Int>("type")
        static let name = Expression<String>("name")
        static let reason = Expression<String>("reason")
        static let appinfo = Expression<String>("appinfo")
        static let callStack = Expression<String>("callStack")
    }
}
