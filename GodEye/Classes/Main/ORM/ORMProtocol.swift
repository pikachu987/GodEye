//
//  RecordORMProtocol.swift
//  Pods
//
//  Created by zixun on 16/12/30.
//
//

import Foundation
import SQLite

/// ORM protocol, variable and function which need implement
protocol RecordORMProtocol: AnyObject {
    var isPreview: Bool { get }

    /// type of record, need implement the get func
    static var type: RecordType { get }
    
    /// mapping relation to model
    ///
    /// - Parameter row: relation: SQLite's Row
    /// - Returns: model
    static func mappingToObject(with row: Row) -> Self

    /// configure the tableBuilder while create the table
    ///
    /// - Parameter tableBuilder: TableBuilder
    static func configure(tableBuilder: TableBuilder)
    
    /// configure select conditions in table
    ///
    /// - Parameter table: Table
    /// - Returns: Table
    static func configure(select table: Table) -> Table

    /// NSAttributedString of model
    ///
    /// - Returns: NSAttributedString
    func attributeString(type: RecordORMAttributedType) -> NSAttributedString

    /// mapping model to ORM's relation
    ///
    /// - Returns: relation: SQLite's Setter
    func mappingToRelation() -> [Setter]
}

private var kIsAllShow = "\(#file)+\(#line)"
private var kAddCount = "\(#file)+\(#line)"

extension RecordORMProtocol {
    var isPreview: Bool {
        true
    }
}

// MARK: - Don't need to implement，just get and set immediately
extension RecordORMProtocol {
    internal var isAllShow: Bool {
        get {
            return objc_getAssociatedObject(self, &kIsAllShow) as? Bool ?? true
        }
        set {
            objc_setAssociatedObject(self, &kIsAllShow, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    internal static var addCount: Int {
        get {
            return objc_getAssociatedObject(self, &kAddCount) as? Int ?? 0
        }
        set {
            objc_setAssociatedObject(self, &kAddCount, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
}


// MARK: - function that can call immediately
extension RecordORMProtocol {
    static func create() {
        do {
            let sql = table.create(temporary: false, ifNotExists: true, block: { tableBuilder in
                tableBuilder.column(col_id, primaryKey: true)
                configure(tableBuilder: tableBuilder)
            })
            try self.connection?.run(sql)
        } catch {
            fatalError("create log table failure")
        }
    }
    
    func insert(complete: @escaping (_ success: Bool) -> ()) {
        let insert = Self.table.insert(mappingToRelation())
        
        Self.queue.async {
            do {
                let rowid = try Self.connection?.run(insert)
            } catch {
                DispatchQueue.main.async {
                    complete(false)
                }
            }
            DispatchQueue.main.async {
                complete(true)
            }
        }
    }
    
    func insertSync(complete: @escaping (_ success: Bool) -> ()){
        let insert = Self.table.insert(mappingToRelation())

        do {
            let rowid = try Self.connection?.run(insert)
        } catch {
            complete(false)
        }
        complete(true)
    }
    
    static func select(at index: Int) -> [Self]? {
        let pagesize = 100
        let offset = pagesize * index + Self.addCount

        var select = configure(select: table.select(Self.col_id))
            .order(Self.col_id.desc)
            .limit(pagesize, offset: offset)
        
        do {
            if let sequence = try Self.connection?.prepare(select) {
                let result = sequence.map { Self.mappingToObject(with: $0) }
                return result.reversed()
            }
            return nil
        } catch {
            return nil
        }
    }
    
    
    static func delete(complete: @escaping (_ success:Bool) -> ()) {
        Self.queue.async {
            let delete = table.delete()
            do {
                let rowid = try Self.connection?.run(delete)
                addCount = 0
            } catch {
                DispatchQueue.main.async {
                    complete(false)
                }
            }
            
            DispatchQueue.main.async {
                complete(true)
            }
        }
    }
}

// MARK: - Inner used variable
extension RecordORMProtocol {
    fileprivate static var table: Table {
        get {
            var key = "\(#file)+\(#line)"
            guard let result = objc_getAssociatedObject(self, &key) as? Table else {
                let result = Table(type.tableName)
                objc_setAssociatedObject(self, &key, result, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
                return result
            }
            return result
        }
    }
    
    fileprivate static var connection: Connection? {
        get {
            var key = "\(#file)+\(#line)"
            let path = AppPathForDocumentsResource(relativePath: "/GodEye.sqlite")
            do {
                guard let result = objc_getAssociatedObject(self, &key) as? Connection else {
                    let result = try Connection(path)
                    objc_setAssociatedObject(self, &key, result, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
                    return result
                }
                
                return result
            } catch {
                fatalError("Init GodEye database failue")
                return nil
            }
        }
    }
    
    fileprivate static var queue: DispatchQueue {
        get {
            var key = "\(#file)+\(#line)"
            guard let result = objc_getAssociatedObject(self, &key) as? DispatchQueue else {
                let result = DispatchQueue(label: "RecordDB")
                objc_setAssociatedObject(self, &key, result, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
                return result
            }
            return result
        }
    }
    
    fileprivate static var col_id:Expression<Int64> {
        get {
            var key = "\(#file)+\(#line)"
            guard let result = objc_getAssociatedObject(self, &key) as? Expression<Int64> else {
                let result = Expression<Int64>("id")
                objc_setAssociatedObject(self, &key, result, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
                return result
            }
            return result
        }
    }
}
