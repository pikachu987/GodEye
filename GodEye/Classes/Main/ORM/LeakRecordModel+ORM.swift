//
//  LeakRecordModel+ORM.swift
//  Pods
//
//  Created by zixun on 17/1/12.
//
//

import Foundation
import SQLite

extension LeakRecordModel: RecordORMProtocol {
    static var type: RecordType { .leak }
    
    static var filterTypes: [RecordORMFilterType] {
        [.init(title: "all", value: nil)] +
        FilterType.allCases
            .map { .init(title: $0.title, value: "\($0.value)") }
    }

    static func mappingToObject(with row: Row) -> LeakRecordModel {
        LeakRecordModel(clazz: row[Col.clazz],
                        address: row[Col.address])
    }
    
    static func configure(tableBuilder: TableBuilder) {
        tableBuilder.column(Col.clazz)
        tableBuilder.column(Col.address)
    }
    
    static func configure(select table: Table, filterType: RecordORMFilterType, filterText: String) -> Table {
        let table = table.select(Col.clazz,
                                 Col.address)
        guard !filterText.isEmpty else { return table }
        if let value = filterType.value {
            return table.filter(Expression<String>(value).like("%\(filterText)%"))
        } else {
            return table.filter(Col.clazz.like("%\(filterText)%") ||
                                Col.address.like("%\(filterText)%"))
        }
    }

    func mappingToRelation() -> [Setter] {
        [Col.clazz <- clazz,
         Col.address <- address]
    }

    func attributeString(type: RecordORMAttributedType, filterType: RecordORMFilterType?, filterText: String?) -> NSAttributedString {
        LeakRecordViewModel(self).attributeString(type: type, filterType: filterType, filterText: filterText)
    }

    class Col: NSObject {
        static let clazz = Expression<String>("clazz")
        static let address = Expression<String>("address")
    }
    
    enum FilterType: FilterTypeable {
        case clazz
        case address

        var title: String {
            switch self {
            case .clazz: return "class"
            case .address: return "address"
            }
        }

        var value: String {
            switch self {
            case .clazz: return "clazz"
            case .address: return "address"
            }
        }

        func equal(filterType: RecordORMFilterType?) -> Bool {
            filterType?.title == title && filterType?.value == value
        }
    }
}
