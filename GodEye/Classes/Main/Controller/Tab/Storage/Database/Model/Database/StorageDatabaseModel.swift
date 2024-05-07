//
//  StorageDatabaseModel.swift
//  GodEye
//
//  Created by USER on 5/7/24.
//

import SQLite

final class StorageDatabaseModel: StorageDatabaseble {
    let databasePath: String

    private lazy var tableNames: [String] = {
        guard let sequences = try? connection?.prepare("SELECT name FROM sqlite_master where type='table';") else  { return [] }
        return sequences.compactMap {
            $0.compactMap { $0 as? String }.first
        }
    }()

    init(databasePath: String) {
        self.databasePath = databasePath
    }
}

extension StorageDatabaseModel: StorageListable {
    var count: Int { tableNames.count }
    var indices: Range<Int> { tableNames.indices }
    var headerName: String? { databasePath.components(separatedBy: "/").last }

    func displayText(index: Int) -> String {
        tableNames[index]
    }

    func viewer(index: Int) -> StorageViewable {
        let tableName = tableNames[index]
        return StorageDatabaseViewerModel(databasePath: databasePath, tableName: tableName)
    }
}
