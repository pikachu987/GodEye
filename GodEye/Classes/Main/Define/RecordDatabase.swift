//
//  RecordDatabase.swift
//  GodEye
//
//  Created by USER on 5/6/24.
//

import Foundation

enum RecordDatabase {
    static var databasePath: String = {
        do {
            var path = try FileManager.default.url(for: .applicationSupportDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
            if #available(iOS 16.0, *) {
                path.append(path: "GodEye.sqlite")
            } else {
                path.appendPathComponent("GodEye.sqlite")
            }
            return path.absoluteString
        } catch {
            fatalError()
        }
    }()
    // AppPathForDocumentsResource(relativePath: "/GodEye.sqlite")
}
