//
//  WebviewPreviewViewContoller.swift
//  FBFilePreviewController
//
//  Created by Roy Marmelstein on 16/02/2016.
//  Copyright © 2016 Roy Marmelstein. All rights reserved.
//

import UIKit
import QuickLook

final class FBFilePreviewController: QLPreviewController {
    private var filePath: URL

    init(filePath: URL) {
        self.filePath = filePath
        super.init(nibName: nil, bundle: nil)

        dataSource = self
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.clipsToBounds = true
    }
}
extension FBFilePreviewController: QLPreviewControllerDataSource {
    func numberOfPreviewItems(in controller: QLPreviewController) -> Int {
        1
    }

    func previewController(_ controller: QLPreviewController, previewItemAt index: Int) -> QLPreviewItem {
        PreviewItem(filePath: filePath)
    }
}

extension FBFilePreviewController {
    private final class PreviewItem: NSObject, QLPreviewItem {
        /*!
         * @abstract The URL of the item to preview.
         * @discussion The URL must be a file URL.
         */
        var previewItemURL: URL?

        init(filePath: URL) {
            previewItemURL = filePath
        }
    }
}
