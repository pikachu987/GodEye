//
//  StorageDatabaseViewerModel.swift
//  GodEye
//
//  Created by USER on 5/7/24.
//

import SQLite

final class StorageDatabaseViewerModel: StorageDatabaseble {
    let databasePath: String

    private let tableName: String

    init(databasePath: String, tableName: String) {
        self.databasePath = databasePath
        self.tableName = tableName
    }
}

// MARK: StorageViewModel
extension StorageDatabaseViewerModel: StorageViewable {
    var title: String { tableName }

    var columnList: [String] {
        let sequences = try? connection?.prepare("SELECT name FROM PRAGMA_TABLE_INFO('\(tableName)');")
        return sequences?.map {
            $0.map {
                guard let value = $0 else { return "" }
                return "\(value)"
            }.first ?? ""
        } ?? []
    }

    var standardRowList: [String] {
        guard let sequences = try? connection?.prepare("SELECT * FROM \(tableName) limit 0, 1;") else  { return [] }
        return sequences
            .map { $0 }
            .last?
            .map {
                guard let value = $0 else { return "" }
                return "\(value)"
            } ?? []
    }

    var rowList: [[String]] {
        guard let sequences = try? connection?.prepare("SELECT * FROM \(tableName);") else  { return [] }
        return sequences
            .map { row in
                row.map {
                    guard let value = $0 else { return "" }
                    return "\(value)"
                }
            }
    }
}

