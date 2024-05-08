//
//  StorageCoreDataViewerModel.swift
//  GodEye
//
//  Created by USER on 5/7/24.
//

import CoreData

final class StorageCoreDataViewerModel: StorageCoreDatable {
    // MARK: StorageViewModel
    var standardRowList = [String]()
    var rowModels = [StorageRowModel]()
    var columnList = [(String, Bool?)]()
    var filterList: [String] = []

    // MARK: StorageCoreDatable
    let coreDataName: String
    
    private let entityName: String

    private let fetchLimit: Int = 1000
    private var fetchOffset: Int = 0
    private var isEmptyData = false
    private var isFetching = false

    private var columnAttributeTypes = [NSAttributeType]()

    init(coreDataName: String, entityName: String) {
        self.coreDataName = coreDataName
        self.entityName = entityName

        setupColumns()
        fetchData()
    }

    private func setupColumns() {
        guard let entity = container.managedObjectModel.entities.first(where: { $0.name == entityName }) else { return }
        let attributes = columnsSort(entity.attributesByName.map({ ($0.key, $0.value.attributeType) }))
        columnList = attributes.map { ($0.0, nil) }
        columnAttributeTypes = attributes.map { $0.1 }
        filterList = attributes.filter { $0.1.canFilter }.map { $0.0 }
    }

    private func columnsSort(_ values: [(String, NSAttributeType)]) -> [(String, NSAttributeType)] {
        if #available(iOS 15.0, *) {
            let keys: [String] = values.map { $0.0 }.sorted(using: .localizedStandard)
            return keys.compactMap { key in
                if let index = values.firstIndex(where: { $0.0 == key }) {
                    return (key, values[index].1)
                }
                return nil
            }
        } else {
            return values.sorted(by: { $0.0 < $1.0 })
        }
    }

    private func fetchData() {
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: entityName)
        fetchRequest.fetchLimit = fetchLimit
        fetchRequest.fetchOffset = fetchOffset
        if let sort = columnList.compactMap { column -> (String, Bool)? in
            guard let order = column.1 else { return nil }
            return (column.0, order)
        }.first {
            fetchRequest.sortDescriptors = [.init(key: sort.0, ascending: sort.1)]
        }
        if let filterIndex = columnList.map { $0.0 }.firstIndex(of: filterType), !filterType.isEmpty && !filterText.isEmpty {
            let attributeType = columnAttributeTypes[filterIndex]
            if let filter = attributeType.filter(text: filterText) {
                fetchRequest.predicate = NSPredicate(format: "%K CONTAINS[c] %@", argumentArray: [filterType, filter])
            }
        }
        guard let fetchResults = try? context.fetch(fetchRequest) else { return }
        let result: [[String]] = fetchResults.map { result in
            ManagedParser().convertToDictionary(managedObject: result)
        }.map {
            var dict = [String: String]()
            columnList.forEach {
                dict.updateValue("", forKey: $0.0)
            }
            $0.forEach {
                dict.updateValue("\($0.value)", forKey: "\($0.key)")
            }
            return columnList.map { $0.0 }
                .compactMap { dict[$0] }
        } ?? []
        fetchStandardRow(result: result)
        if result.isEmpty {
            isEmptyData = true
            return
        }
        rowModels.append(contentsOf: makeRowModels(valuesList: result))
        fetchOffset += fetchLimit
    }

    private func fetchStandardRow(result: [[String]]) {
        guard standardRowList.isEmpty, !result.isEmpty else { return }
        standardRowList = result[0]
    }
}

// MARK: StorageViewModel
extension StorageCoreDataViewerModel: StorageViewable {
    var title: String { entityName }

    func loadMore(_ completion: @escaping (() -> Void)) {
        guard !isFetching && !isEmptyData else { return }
        isFetching = true
        fetchData()
        completion()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
            self?.isFetching = false
        }
    }

    func refresh(_ completion: @escaping (() -> Void)) {
        isFetching = true
        isEmptyData = false
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

extension NSAttributeType {
    var canFilter: Bool {
        [.stringAttributeType, .integer16AttributeType, .integer32AttributeType, .integer64AttributeType,
         .floatAttributeType, .doubleAttributeType, .decimalAttributeType, .booleanAttributeType, .URIAttributeType].contains(self)
    }

    func filter(text: String) -> Any? {
        switch self {
        case .stringAttributeType: return text
        case .integer16AttributeType, .integer32AttributeType, .integer64AttributeType: return Int(text)
        case .doubleAttributeType: return Double(text)
        case .floatAttributeType: return Float(text)
        case .booleanAttributeType: return Int(text)
        case .decimalAttributeType: return NSDecimalNumber(string: text)
        case .URIAttributeType: return NSURL(string: text)
        default: return nil
        }
    }


    //        case undefinedAttributeType = 0
    //        case integer16AttributeType = 100
    //        case integer32AttributeType = 200
    //        case integer64AttributeType = 300
    //        case decimalAttributeType = 400
    //        case doubleAttributeType = 500
    //        case floatAttributeType = 600
    //        case stringAttributeType = 700
    //        case booleanAttributeType = 800
    //        case dateAttributeType = 900
    //        case binaryDataAttributeType = 1000
    //        case UUIDAttributeType = 1100
    //        case URIAttributeType = 1200
    //        case transformableAttributeType = 1800
    //        case objectIDAttributeType = 2000
    //        case compositeAttributeType = 2100
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
