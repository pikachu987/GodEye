//
//  FBFile.swift
//  FileBrowser
//
//  Created by Roy Marmelstein on 14/02/2016.
//  Copyright © 2016 Roy Marmelstein. All rights reserved.
//

import UIKit

/// FBFile is a class representing a file in FileBrowser
@objc class FBFile: NSObject {
    /// Display name. String.
    @objc let displayName: String
    // is Directory. Bool.
    let isDirectory: Bool
    /// File extension.
    let fileExtension: String?
    /// File attributes (including size, creation date etc).
    let fileAttributes: NSDictionary?
    /// NSURL file path.
    let filePath: URL
    // FBFileType
    let type: FBFileType

    // Size
    var size: UInt64 {
        var size: UInt64 = 0
        switch type {
        case .Directory:
            size = (try? FileManager.default.allocatedSizeOfDirectory(at: filePath)) ?? 0
        default:
            size = fileAttributes?.fileSize() ?? 0
        }
        return size
    }
    
    func delete() {
        do {
            try FileManager.default.removeItem(at: filePath)
        } catch {
            print("An error occured when trying to delete file:\(filePath) Error:\(error)")
        }
    }
    
    /**
     Initialize an FBFile object with a filePath
     
     - parameter filePath: NSURL filePath
     
     - returns: FBFile object.
     */
    init(filePath: URL) {
        self.filePath = filePath
        isDirectory = checkDirectory(filePath)
        if isDirectory {
            fileAttributes = nil
            fileExtension = nil
            type = .Directory
        } else {
            fileAttributes = getFileAttributes(filePath)
            fileExtension = filePath.pathExtension
            if let fileExtension = fileExtension {
                type = FBFileType(rawValue: fileExtension) ?? .Default
            }
            else {
                type = .Default
            }
        }
        displayName = filePath.lastPathComponent
    }
}

extension FBFile {
    var webBodyString: String? {
        guard let data = try? Data(contentsOf: filePath) else { return nil }
        let rawString: String = {
            // Prepare plist for display
            if $0 == .PLIST {
                if let plistDescription = try? (PropertyListSerialization.propertyList(from: data, options: [], format: nil) as AnyObject).description {
                    return plistDescription
                }
            } else if $0 == .JSON, let pretty = data.replacePretty {
                // Prepare json file for display
                return pretty
            }
            return String(data: data, encoding: .utf8) ?? ""
        }(type)
        return "<pre>\(rawString)</pre>"
    }
}

/**
 FBFile type
 */
enum FBFileType: String {
    /// Directory
    case Directory = "directory"
    /// GIF file
    case GIF = "gif"
    /// JPG file
    case JPG = "jpg"
    /// PLIST file
    case JSON = "json"
    /// PDF file
    case PDF = "pdf"
    /// PLIST file
    case PLIST = "plist"
    /// PNG file
    case PNG = "png"
    /// ZIP file
    case ZIP = "zip"
    /// Any file
    case Default = "file"
    
    /**
     Get representative image for file type
     
     - returns: UIImage for file type
     */
    var image: UIImage? {
        let bundle =  Bundle(for: FileParser.self)
        var fileName = String()
        switch self {
        case .Directory: fileName = "folder@2x.png"
        case .JPG, .PNG, .GIF: fileName = "image@2x.png"
        case .PDF: fileName = "pdf@2x.png"
        case .ZIP: fileName = "zip@2x.png"
        default: fileName = "file@2x.png"
        }
        let file = UIImage(named: fileName, in: bundle, compatibleWith: nil)
        return file
    }
}

/**
 Check if file path NSURL is directory or file.
 
 - parameter filePath: NSURL file path.
 
 - returns: isDirectory Bool.
 */
func checkDirectory(_ filePath: URL) -> Bool {
    var isDirectory = false
    do {
        var resourceValue: AnyObject?
        try (filePath as NSURL).getResourceValue(&resourceValue, forKey: URLResourceKey.isDirectoryKey)
        if let number = resourceValue as? NSNumber , number == true {
            isDirectory = true
        }
    }
    catch { }
    return isDirectory
}

func getFileAttributes(_ filePath: URL) -> NSDictionary? {
    let path = filePath.path
    let fileManager = FileParser.sharedInstance.fileManager
    do {
        let attributes = try fileManager.attributesOfItem(atPath: path) as NSDictionary
        return attributes
    } catch {}
    return nil
}
