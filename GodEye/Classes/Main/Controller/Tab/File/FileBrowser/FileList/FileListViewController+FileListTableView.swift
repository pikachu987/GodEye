//
//  FileListViewController+FileListTableView.swift
//  FileBrowser
//
//  Created by Roy Marmelstein on 14/02/2016.
//  Copyright © 2016 Roy Marmelstein. All rights reserved.
//

import UIKit

extension FileListViewController: UITableViewDataSource, UITableViewDelegate {
    
    //MARK: UITableViewDataSource, UITableViewDelegate

    func numberOfSections(in tableView: UITableView) -> Int {
        isFilter ? 1 : sections.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isFilter {
            return filteredFiles.count
        }
        guard sections.indices ~= section else { return 0 }
        return sections[section].count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellIdentifier = "FileCell"
        var cell = UITableViewCell(style: .subtitle, reuseIdentifier: cellIdentifier)
        if let reuseCell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier) {
            cell = reuseCell
        }
        cell.backgroundColor = .clear
        cell.contentView.backgroundColor = .clear
        cell.selectionStyle = .blue
        let selectedFile = fileForIndexPath(indexPath)
        let attributedString = NSMutableAttributedString(string: selectedFile?.displayName ?? "")
        attributedString.highlight(highlightText: filterText)
        cell.textLabel?.attributedText = attributedString
        cell.detailTextLabel?.text = selectedFile.map {
            convertSizeToReadableString(with: $0.size)
        }
        cell.imageView?.image = selectedFile?.type.image
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        resignFirstResponder()
        guard let selectedFile = fileForIndexPath(indexPath) else { return }
        if selectedFile.isDirectory {
            let fileListViewController = FileListViewController(initialPath: selectedFile.filePath,
                                                                allowEditing: allowEditing)
            fileListViewController.didSelectFile = didSelectFile
            navigationController?.pushViewController(fileListViewController, animated: true)
        } else {
            if let didSelectFile = didSelectFile {
                dismiss(animated: true)
                didSelectFile(selectedFile)
            } else {
                let filePreview = previewManager.previewViewControllerForFile(selectedFile, fromNavigation: true)
                navigationController?.pushViewController(filePreview, animated: true)
            }
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if isFilter {
            return nil
        } else if sections[section].count > 0 {
            return collation.sectionTitles[section]
        } else {
            return nil
        }
    }
    
    func sectionIndexTitles(for tableView: UITableView) -> [String]? {
        if isFilter {
            return nil
        }
        return collation.sectionIndexTitles
    }
    
    func tableView(_ tableView: UITableView, sectionForSectionIndexTitle title: String, at index: Int) -> Int {
        if isFilter {
            return 0
        }
        return collation.section(forSectionIndexTitle: index)
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if (editingStyle == .delete) {
            let selectedFile = fileForIndexPath(indexPath)
            selectedFile?.delete()

            prepareData()
            guard tableView.numberOfSections ~= indexPath.section else { return }
            tableView.reloadSections([indexPath.section], with: .automatic)
        }
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        allowEditing
    }
}
