//
//  DatabaseConfiguration.swift
//  GodEye
//
//  Created by USER on 5/6/24.
//

import Foundation

//--------------------------------------------------------------------------
// MARK: - DatabaseConfiguration
// DESCRIPTION: Please enter the database you want to view in GodEye.
// Databases only support sqlite, fmdb, and coredata.
//--------------------------------------------------------------------------
open class DatabaseConfiguration: NSObject {
    open var sqliteNames: [String] = []
}
