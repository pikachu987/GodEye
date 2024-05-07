//
//  StorageCoreDatable.swift
//  GodEye
//
//  Created by USER on 5/6/24.
//

import CoreData

protocol StorageCoreDatable {
    var coreDataName: String { get }
}

extension StorageCoreDatable {
    var container: NSPersistentContainer {
        var key = "\(#file)+\(#line)"
        guard let result = objc_getAssociatedObject(self, &key) as? NSPersistentContainer else {
            let result = NSPersistentContainer(name: coreDataName)
            result.loadPersistentStores { NSPersistentStoreDescription, error in
                if let error = error as NSError? {
                    fatalError("Unresolved error \(error), \(error.userInfo)")
                }
            }
            objc_setAssociatedObject(self, &key, result, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            return result
        }
        return result
    }

    var context: NSManagedObjectContext {
        container.viewContext
    }
}
