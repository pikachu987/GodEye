//
//  FileBrowserNavigationController.swift
//  FileBrowser
//
//  Created by Roy Marmelstein on 14/02/2016.
//  Copyright © 2016 Roy Marmelstein. All rights reserved.
//

import UIKit

/// File browser containing navigation controller.
final class FileBrowserNavigationController: UINavigationController {

    let parser = FileParser.sharedInstance
    
    weak var fileList: FileListViewController?

    /// File types to exclude from the file browser.
    public var excludesFileExtensions: [String]? {
        didSet {
            parser.excludesFileExtensions = excludesFileExtensions
        }
    }
    
    /// File paths to exclude from the file browser.
    public var excludesFilepaths: [URL]? {
        didSet {
            parser.excludesFilepaths = excludesFilepaths
        }
    }
    
    /// Override default preview and actionsheet behaviour in favour of custom file handling.
    public var didSelectFile: ((FBFile) -> ())? {
        didSet {
            fileList?.didSelectFile = didSelectFile
        }
    }

    public convenience init() {
        let parser = FileParser.sharedInstance
        let path = parser.documentsURL
        self.init(initialPath: path, allowEditing: true)
    }

    /// Initialise file browser.
    ///
    /// - Parameters:
    ///   - initialPath: NSURL filepath to containing directory.
    ///   - allowEditing: Whether to allow editing.
    ///   - showCancelButton: Whether to show the cancel button.
    ///   - showSize: Whether to show size for files and directories.
    @objc public convenience init(initialPath: URL? = nil,
                                  allowEditing: Bool = false) {
        
        let validInitialPath = initialPath ?? FileParser.sharedInstance.documentsURL
        
        let fileListViewController = FileListViewController(initialPath: validInitialPath,
                                                            allowEditing: allowEditing)

        self.init(rootViewController: fileListViewController)
        view.backgroundColor = .fileBrowserBackground
        fileList = fileListViewController
    }
}
