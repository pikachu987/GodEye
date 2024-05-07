//
//  StorageCoreDataViewerModel.swift
//  GodEye
//
//  Created by USER on 5/7/24.
//

import CoreData

final class StorageCoreDataViewerModel: StorageCoreDatable {
    let coreDataName: String
    
    private let entityName: String

    private var entityDescription: NSEntityDescription {
        container.managedObjectModel.entities.first(where: { $0.name == entityName }) ?? .init()
    }

    private lazy var rowDict: [NSDictionary] = {
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: entityName)
        guard let results = try? context.fetch(fetchRequest) else { return [] }
        return results.map { result in
            ManagedParser().convertToDictionary(managedObject: result)
        } ?? []
    }()

    init(coreDataName: String, entityName: String) {
        self.coreDataName = coreDataName
        self.entityName = entityName

    }
}

// MARK: StorageViewModel
extension StorageCoreDataViewerModel: StorageViewable {
    var title: String { entityName }

    var columnList: [String] {
        entityDescription.properties.map { $0.name }.sorted(by: <)
    }
    
    var standardRowList: [String] {
        guard let row = rowDict.last else { return [] }
        return row.sorted(by: { "\($0.key)" < "\($1.key)" }).map { "\($0.value)" }
    }
    
    var rowList: [[String]] {
        rowDict.map {
            $0.sorted(by: { "\($0.key)" < "\($1.key)" }).map { "\($0.value)" }
        }
    }
}

private class ManagedParser {
    private var parsedObjs = NSMutableSet()

    func convertToArray(managedObjects: NSArray?, parentNode: String? = nil) -> NSArray {
        let resultArray = NSMutableArray()

        if let managedObjects = managedObjects as? [NSManagedObject] {
            for managedObject in managedObjects {
                if parsedObjs.member(managedObject) == nil {
                    parsedObjs.add(managedObject)
                    resultArray.add(convertToDictionary(managedObject: managedObject,
                                                             parentNode: parentNode))
                }
            }
        }
        return resultArray
    }

    func convertToDictionary(managedObject: NSManagedObject, parentNode: String? = nil) -> NSDictionary {
        let resultDictonary = NSMutableDictionary()
        let entity = managedObject.entity
        let properties: [String] = (entity.propertiesByName as NSDictionary).allKeys as? [String] ?? []
        let parentNode = parentNode ?? managedObject.entity.name!
        for property in properties {
            if property.caseInsensitiveCompare(parentNode) != .orderedSame {
                let value = managedObject.value(forKey: property)

                if let set = value as? NSSet {
                    resultDictonary[property] = convertToArray(managedObjects: set.allObjects as NSArray, parentNode: parentNode)
                } else if let orderedset = value as? NSOrderedSet {
                    resultDictonary[property] = convertToArray(managedObjects: NSArray(array: orderedset.array), parentNode: parentNode)
                } else if let vManagedObject = value as? NSManagedObject {
                    if parsedObjs.member(managedObject) == nil {
                        parsedObjs.add(managedObject)
                        if vManagedObject.entity.name != parentNode {
                            resultDictonary[property] = convertToDictionary(managedObject: vManagedObject, parentNode: parentNode)
                        }
                    }
                } else if let vData = value {
                    resultDictonary[property] = vData
                }
            }
        }
        return resultDictonary
    }
}
