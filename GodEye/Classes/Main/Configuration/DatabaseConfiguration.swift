//
//  DatabaseConfiguration.swift
//  GodEye
//
//  Created by USER on 5/6/24.
//

import Foundation

//--------------------------------------------------------------------------
// MARK: - StorageConfiguration
// DESCRIPTION: Please enter the storage you want to view in GodEye.
// storage only support database(sqlite or fmdb or db...), and coredata.
//--------------------------------------------------------------------------
open class StorageConfiguration: NSObject {
    open var databasePaths: [String] = []
    open var coreDataNames: [String] = []
}
