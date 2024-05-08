//
//  StorageDatabaseViewerModel.swift
//  GodEye
//
//  Created by USER on 5/7/24.
//

import SQLite

final class StorageDatabaseViewerModel: StorageDatabaseble {
    // MARK: StorageViewModel
    var standardRowList = [String]()
    var rowModels = [StorageRowModel]()
    var columnList = [(String, Bool?)]()

    // MARK: StorageDatabaseble
    let databasePath: String

    private let tableName: String

    private let fetchLimit: Int = 1000
    private var fetchOffset: Int = 0
    private var rowCount: Int = 0
    private var isFetching = false

    init(databasePath: String, tableName: String) {
        self.databasePath = databasePath
        self.tableName = tableName

        setupColumns()
        fetchStandardRow()
        fetchCount()
        fetchData()
    }

    private func setupColumns() {
        let sequences = try? connection?.prepare("SELECT name FROM PRAGMA_TABLE_INFO('\(tableName)');")
        columnList = sequences?.map { $0.map { $0 ?? "" }.map { "\($0)" }.first ?? "" }.map { ($0, nil) } ?? []
    }

    private func fetchCount() {
        guard let sequences = try? connection?.prepare("SELECT COUNT(*) FROM \(tableName);") else  { return }
        rowCount = Int(sequences.flatMap { ($0.first ?? 0) as? Int64 }.first ?? 0)
    }

    private func fetchStandardRow() {
        guard standardRowList.isEmpty, let sequences = try? connection?.prepare("SELECT * FROM \(tableName) limit 0, 1;") else  { return }
        standardRowList = sequences
            .map { $0 }
            .last?
            .map { $0 ?? "" }
            .map { "\($0)" } ?? []
    }

    private func fetchData() {
        let selectQuery = "SELECT * FROM "
        let whereQuery = !filterText.isEmpty && !filterText.isEmpty ? " WHERE \(filterType) LIKE \"%\(filterText)%\"" : ""
        let orderQuery = columnList.compactMap { column -> (String, String)? in
            guard let order = column.1 else { return nil }
            return (column.0, order ? "ASC" : "DESC")
        }.first.map { " ORDER BY \($0.0) \($0.1)" } ?? ""
        let limitQuery = " LIMIT \(fetchLimit) OFFSET \(fetchOffset)"
        let query = "\(selectQuery)\(tableName)\(whereQuery)\(orderQuery)\(limitQuery);"
        guard let sequences = try? connection?.prepare(query) else  { return }
        let result = sequences.map { $0.map { $0 ?? "" }.map { "\($0)" } }
        rowModels.append(contentsOf: makeRowModels(valuesList: result))
        fetchOffset += fetchLimit
    }
}

// MARK: StorageViewModel
extension StorageDatabaseViewerModel: StorageViewable {
    var title: String { tableName }

    func loadMore(_ completion: @escaping (() -> Void)) {
        guard !isFetching && fetchOffset < rowCount else { return }
        isFetching = true
        fetchData()
        completion()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
            self?.isFetching = false
        }
    }

    func refresh(_ completion: @escaping (() -> Void)) {
        isFetching = true
        fetchCount()
        fetchOffset = 0
        rowModels = []
        fetchData()
        DispatchQueue.main.async {
            completion()
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
            self?.isFetching = false
        }
    }
}

