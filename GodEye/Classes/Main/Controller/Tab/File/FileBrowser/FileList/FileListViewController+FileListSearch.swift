//
//  FileListViewController+FileListSearch.swift
//  FileBrowser
//
//  Created by Roy Marmelstein on 14/02/2016.
//  Copyright © 2016 Roy Marmelstein. All rights reserved.
//

import UIKit

extension FileListViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        searchBar.text.map {
            if $0.isEmpty {
                tableView.contentInset = .init(top: 0, left: 0, bottom: 0, right: 0)
            } else {
                tableView.contentInset = .init(top: 20, left: 0, bottom: 0, right: 0)
            }
            filterContentForSearchText($0)
        }
    }

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
}
