//
//  NSFileManager+AppBaseKit.swift
//  Pods
//
//  Created by zixun on 16/9/25.
//
//

import Foundation

extension FileManager {
    
    class func createDirectoryIfNotExists(path: String) -> Bool {

        let fileManager = self.default
        var isDir: ObjCBool = false
        let exists = fileManager.fileExists(atPath: path, isDirectory: &isDir)
        if exists == false || !isDir.boolValue {
            do {
                try fileManager.createDirectory(atPath: path, withIntermediateDirectories: true, attributes: nil)
            } catch {
                return false
            }
        }
        return true
    }
    
    class func removeItemIfExists(path: String) -> Bool {
        let fileManager = self.default
        var isDir: ObjCBool = false
        let exists = fileManager.fileExists(atPath: path, isDirectory: &isDir)
        if exists == true {
            do {
                try fileManager.removeItem(atPath: path)
            } catch {
                return false
            }
        }
        return true
    }
}
