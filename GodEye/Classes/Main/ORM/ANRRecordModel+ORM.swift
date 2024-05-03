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

    func mappingToRelation() -> [Setter] {
        [ANRRecordModel.col.threshold <- threshold,
         ANRRecordModel.col.mainThreadBacktrace <- mainThreadBacktrace,
         ANRRecordModel.col.allThreadBacktrace <- allThreadBacktrace]
    }
    
    static func mappingToObject(with row: Row) -> ANRRecordModel {
        ANRRecordModel(threshold: row[ANRRecordModel.col.threshold],
                       mainThreadBacktrace: row[ANRRecordModel.col.mainThreadBacktrace],
                       allThreadBacktrace: row[ANRRecordModel.col.allThreadBacktrace])
    }
    
    static func configure(tableBuilder: TableBuilder) {
        tableBuilder.column(ANRRecordModel.col.threshold)
        tableBuilder.column(ANRRecordModel.col.mainThreadBacktrace)
        tableBuilder.column(ANRRecordModel.col.allThreadBacktrace)
    }
    
    static func configure(select table: Table) -> Table {
        table.select(ANRRecordModel.col.threshold,
                     ANRRecordModel.col.mainThreadBacktrace,
                     ANRRecordModel.col.allThreadBacktrace)
    }
    
    static func prepare(sequence: AnySequence<Row>) -> [ANRRecordModel] {
        sequence.map { row -> ANRRecordModel in
            ANRRecordModel(threshold: row[ANRRecordModel.col.threshold],
                           mainThreadBacktrace: row[ANRRecordModel.col.mainThreadBacktrace],
                           allThreadBacktrace: row[ANRRecordModel.col.allThreadBacktrace])
        }
    }
    
    func attributeString(type: RecordORMAttributedType) -> NSAttributedString {
        ANRRecordViewModel(self).attributeString(type: type)
    }
    
    class col: NSObject {
        static let threshold = Expression<Double>("threshold")
        static let mainThreadBacktrace = Expression<String?>("mainThreadBacktrace")
        static let allThreadBacktrace = Expression<String?>("allThreadBacktrace")
    }
}


