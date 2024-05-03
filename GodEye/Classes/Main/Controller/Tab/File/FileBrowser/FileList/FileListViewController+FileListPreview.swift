//
//  FileListViewController+FileListPreview.swift
//  FileBrowser
//
//  Created by Roy Marmelstein on 13/02/2016.
//  Copyright © 2016 Roy Marmelstein. All rights reserved.
//

import UIKit
import QuickLook

extension FileListViewController {
    func tableView(_ tableView: UITableView, contextMenuConfigurationForRowAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
        guard let selectedFile = fileForIndexPath(indexPath) else { return nil }
        if selectedFile.isDirectory {
            return nil
        } else {
            let previewProvider: (() -> UIViewController?) = { [weak self] in
                self?.previewManager.previewViewControllerForFile(selectedFile, fromNavigation: false)
            }
            return UIContextMenuConfiguration(identifier: nil, previewProvider: previewProvider) { suggestedActions in
                let inspectAction = UIAction(title: NSLocalizedString("View", comment: ""), image: nil) { [weak self] action in
                    guard let self = self else { return }
                    let viewController = self.previewManager.previewViewControllerForFile(selectedFile, fromNavigation: true)
                    self.navigationController?.pushViewController(viewController, animated: true)
                }
                return UIMenu(title: "", children: [inspectAction])
            }
        }
    }
}
