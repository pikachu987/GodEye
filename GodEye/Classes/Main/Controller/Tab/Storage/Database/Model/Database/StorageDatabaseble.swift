//
//  StorageDatabaseble.swift
//  GodEye
//
//  Created by USER on 5/7/24.
//

import SQLite

protocol StorageDatabaseble {
    var databasePath: String { get }
}

extension StorageDatabaseble {
    var connection: Connection? {
        get {
            var key = "\(#file)+\(#line)"
            do {
                guard let result = objc_getAssociatedObject(self, &key) as? Connection else {
                    let result = try Connection(databasePath)
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
}
