//
//  PreviewManager.swift
//  FileBrowser
//
//  Created by Roy Marmelstein on 16/02/2016.
//  Copyright © 2016 Roy Marmelstein. All rights reserved.
//

import Foundation

final class PreviewManager: NSObject {
    func previewViewControllerForFile(_ file: FBFile, fromNavigation: Bool) -> UIViewController {
        if [.PLIST, .JSON].contains(file.type), let webBodyString = file.webBodyString {
            return WebviewViewContoller(title: file.displayName,
                                        html: webBodyString,
                                        shareItem: [file.filePath])
        } else {
            if fromNavigation {
                return FBFilePreviewController(filePath: file.filePath)
            } else {
                return PreviewTransitionViewController(file: file)
            }
        }
    }
}
