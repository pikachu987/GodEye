//
//  StorageCoreDataModel.swift
//  GodEye
//
//  Created by USER on 5/7/24.
//

import CoreData

final class StorageCoreDataModel: StorageCoreDatable {
    let coreDataName: String

    private lazy var entityNames: [String] = {
        container.managedObjectModel.entities.compactMap { $0.name }
    }()

    init(coreDataName: String) {
        self.coreDataName = coreDataName
    }
}

extension StorageCoreDataModel: StorageListable {
    var count: Int { entityNames.count }
    var indices: Range<Int> { entityNames.indices }
    var headerName: String? { coreDataName }

    func displayText(index: Int) -> String {
        entityNames[index]
    }

    func viewer(index: Int) -> StorageViewable {
        let entityName = entityNames[index]
        return StorageCoreDataViewerModel(coreDataName: coreDataName, entityName: entityName)
    }
}
