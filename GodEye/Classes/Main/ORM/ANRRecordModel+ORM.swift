//
//  ANRRecordModel+ORM.swift
//  Pods
//
//  Created by zixun on 17/1/9.
//
//

import Foundation
import SQLite

extension ANRRecordModel: RecordORMProtocol {
    static var type: RecordType { .anr }

    static var filterTypes: [RecordORMFilterType] {
        [.init(title: "all", value: nil)] +
        FilterType.allCases
            .map { .init(title: $0.title, value: "\($0.value)") }
    }

    static func mappingToObject(with row: Row) -> ANRRecordModel {
        ANRRecordModel(threshold: row[Col.threshold],
                       mainThreadBacktrace: row[Col.mainThreadBacktrace],
                       allThreadBacktrace: row[Col.allThreadBacktrace])
    }
    
    static func configure(tableBuilder: TableBuilder) {
        tableBuilder.column(Col.threshold)
        tableBuilder.column(Col.mainThreadBacktrace)
        tableBuilder.column(Col.allThreadBacktrace)
    }
    
    static func configure(select table: Table, filterType: RecordORMFilterType, filterText: String) -> Table {
        let table = table.select(Col.threshold,
                                 Col.mainThreadBacktrace,
                                 Col.allThreadBacktrace)
        guard !filterText.isEmpty else { return table }
        if let value = filterType.value {
            return table.filter(Expression<String>(value).like("%\(filterText)%"))
        } else {
            return table.filter(Col.mainThreadBacktrace.like("%\(filterText)%") ||
                                Col.allThreadBacktrace.like("%\(filterText)%"))
        }
    }
    
    static func prepare(sequence: AnySequence<Row>) -> [ANRRecordModel] {
        sequence.map { row -> ANRRecordModel in
            ANRRecordModel(threshold: row[Col.threshold],
                           mainThreadBacktrace: row[Col.mainThreadBacktrace],
                           allThreadBacktrace: row[Col.allThreadBacktrace])
        }
    }

    func mappingToRelation() -> [Setter] {
        [Col.threshold <- threshold,
         Col.mainThreadBacktrace <- mainThreadBacktrace,
         Col.allThreadBacktrace <- allThreadBacktrace]
    }

    func attributeString(type: RecordORMAttributedType, filterType: RecordORMFilterType?, filterText: String?) -> NSAttributedString {
        ANRRecordViewModel(self).attributeString(type: type, filterType: filterType, filterText: filterText)
    }

    class Col: NSObject {
        static let threshold = Expression<Double>("threshold")
        static let mainThreadBacktrace = Expression<String?>("mainThreadBacktrace")
        static let allThreadBacktrace = Expression<String?>("allThreadBacktrace")
    }

    enum FilterType: FilterTypeable {
        case mainThreadBacktrace
        case allThreadBacktrace

        var title: String {
            switch self {
            case .mainThreadBacktrace: return "mainThread"
            case .allThreadBacktrace: return "allThread"
            }
        }

        var value: String {
            switch self {
            case .mainThreadBacktrace: return "mainThreadBacktrace"
            case .allThreadBacktrace: return "allThreadBacktrace"
            }
        }

        func equal(filterType: RecordORMFilterType?) -> Bool {
            filterType?.title == title && filterType?.value == value
        }
    }
}


