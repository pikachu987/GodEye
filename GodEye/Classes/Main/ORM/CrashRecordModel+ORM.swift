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
    
    static var filterTypes: [RecordORMFilterType] {
        [.init(title: "all", value: nil)] +
        FilterType.allCases
            .map { .init(title: $0.title, value: "\($0.value)") }
    }
    
    static func mappingToObject(with row: Row) -> CrashRecordModel {
        let type = CrashModelType(rawValue: row[Col.type]) ?? .signal
        let name = row[Col.name]
        let reason = row[Col.reason]
        let appinfo = row[Col.appinfo]
        let callStack = row[Col.callStack]
        return CrashRecordModel(type: type, name: name, reason: reason, appinfo: appinfo, callStack: callStack)
    }
    
    static func configure(tableBuilder: TableBuilder) {
        tableBuilder.column(Col.type)
        tableBuilder.column(Col.name)
        tableBuilder.column(Col.reason)
        tableBuilder.column(Col.appinfo)
        tableBuilder.column(Col.callStack)
    }
    
    static func configure(select table: Table, filterType: RecordORMFilterType, filterText: String) -> Table {
        let table = table.select(Col.type,
                                 Col.name,
                                 Col.reason,
                                 Col.appinfo,
                                 Col.callStack)
        guard !filterText.isEmpty else { return table }
        if let value = filterType.value {
            return table.filter(Expression<String>(value).like("%\(filterText)%"))
        } else {
            return table.filter(Col.name.like("%\(filterText)%") ||
                                Col.reason.like("%\(filterText)%") ||
                                Col.appinfo.like("%\(filterText)%") ||
                                Col.callStack.like("%\(filterText)%"))
        }
    }

    func mappingToRelation() -> [Setter] {
        [Col.type <- type.rawValue,
         Col.name <- name,
         Col.reason <- reason,
         Col.appinfo <- appinfo,
         Col.callStack <- callStack]
    }

    func attributeString(type: RecordORMAttributedType, filterType: RecordORMFilterType?, filterText: String?) -> NSAttributedString {
        CrashRecordViewModel(self).attributeString(type: type, filterType: filterType, filterText: filterText)
    }

    class Col: NSObject {
        static let type = Expression<Int>("type")
        static let name = Expression<String>("name")
        static let reason = Expression<String>("reason")
        static let appinfo = Expression<String>("appinfo")
        static let callStack = Expression<String>("callStack")
    }

    enum FilterType: FilterTypeable {
        case name
        case reason
        case appinfo
        case callStack

        var title: String {
            if self == .appinfo { return "appInfo" }
            return value
        }

        var value: String {
            switch self {
            case .name: return "name"
            case .reason: return "reason"
            case .appinfo: return "appinfo"
            case .callStack: return "callStack"
            }
        }

        func equal(filterType: RecordORMFilterType?) -> Bool {
            filterType?.title == title && filterType?.value == value
        }
    }
}
