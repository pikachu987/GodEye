//
//  StorageSQLite.swift
//  GodEye
//
//  Created by USER on 5/6/24.
//

import SQLite

class StorageSQLite {
    private let databaseName: String

    private lazy var connection: Connection = {
        var key = "\(#file)+\(#line)"
        let path = AppPathForDocumentsResource(relativePath: "/\(databaseName)")
        do {
            return try Connection(path)
        } catch {
            fatalError("Init GodEye database failue")
        }
    }()

    init(databaseName: String) {
        self.databaseName = databaseName
    }


    func selectAllTable() {
        guard let sequences = try? connection.prepare("SELECT name FROM sqlite_master where type='table';") else  { return }
        sequences.row
            .compactMap { $0 }
            .forEach { row in
                print(row)
                print(row as? String)
            }
        let tablenames = sequences.compactMap {
            $0.compactMap { $0 as? String }.first
        }
        print(tablenames)
    }
}
