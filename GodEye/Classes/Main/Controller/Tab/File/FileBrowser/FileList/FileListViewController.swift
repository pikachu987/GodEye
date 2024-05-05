//
//  FileListViewController.swift
//  FileBrowser
//
//  Created by Roy Marmelstein on 12/02/2016.
//  Copyright © 2016 Roy Marmelstein. All rights reserved.
//

import UIKit

final class FileListViewController: UIViewController {
    private lazy var navigationTitleView: UILabel = {
        $0.text = initialPath.lastPathComponent
        $0.adjustsFontSizeToFitWidth = true
        $0.minimumScaleFactor = 0.5
        $0.font = .systemFont(ofSize: 17, weight: .bold)
        return $0
    }(UILabel())

    lazy var tableView: UITableView = {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.backgroundColor = .clear
        return $0
    }(UITableView(frame: .zero, style: .plain))

    private lazy var searchBar: UISearchBar = {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.placeholder = "Search"
        $0.backgroundColor = .fileBrowserBackground
        $0.searchBarStyle = .minimal
        $0.enablesReturnKeyAutomatically = false
        return $0
    }(UISearchBar())

    var filterText: String? {
        searchBar.text
    }

    var isFilter: Bool {
        filterText?.isEmpty == false
    }

    let collation = UILocalizedIndexedCollation.current()

    let allowEditing: Bool

    /// Data
    var didSelectFile: ((FBFile) -> ())?

    let previewManager = PreviewManager()
    var sections: [[FBFile]] = []

    // Search controller
    var filteredFiles = [FBFile]()

    private let initialPath: URL

    private var files = [FBFile]()
    private let parser = FileParser.sharedInstance

    init(initialPath: URL, allowEditing: Bool = false) {
        self.initialPath = initialPath
        self.allowEditing = allowEditing
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        setupViews()
        prepareData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        navigationItem.titleView = navigationTitleView
        if navigationController?.viewControllers.first == self {
            navigationItem.leftBarButtonItem = UIBarButtonItem(image: .init(systemName: "xmark"), style: .done, target: self, action: #selector(leftBarButtonItemTapped(_:)))
        }
    }

    @discardableResult
    override func resignFirstResponder() -> Bool {
        searchBar.resignFirstResponder()
        return super.resignFirstResponder()
    }
}

extension FileListViewController {
    func prepareData() {
        // Prepare data
        files = parser.filesForDirectory(initialPath)
        indexFiles()
    }

    func fileForIndexPath(_ indexPath: IndexPath) -> FBFile? {
        var file: FBFile
        if isFilter {
            guard filteredFiles.indices ~= indexPath.row else { return nil }
            file = filteredFiles[indexPath.row]
        } else {
            guard sections.indices ~= indexPath.section else { return nil }
            guard sections[indexPath.section].indices ~= indexPath.row else { return nil }
            file = sections[indexPath.section][indexPath.row]
        }
        return file
    }

    func filterContentForSearchText(_ searchText: String) {
        let lowercaseText = searchText.lowercased()
        filteredFiles = files.filter {
            $0.displayName.lowercased().contains(lowercaseText)
        }
        tableView.reloadData()
    }
}

extension FileListViewController {
    private func setupViews() {
        view.backgroundColor = .fileBrowserBackground
        view.clipsToBounds = true

        view.addSubview(searchBar)
        view.addSubview(tableView)

        NSLayoutConstraint.activate([
            searchBar.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            searchBar.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            searchBar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
        ])

        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: searchBar.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])

        searchBar.delegate = self

        tableView.delegate = self
        tableView.dataSource = self
    }
}

extension FileListViewController {
    private func indexFiles() {
        let selector: Selector = #selector(getter: FBFile.displayName)
        sections = Array(repeating: [], count: collation.sectionTitles.count)
        if let sortedObjects = collation.sortedArray(from: files, collationStringSelector: selector) as? [FBFile] {
            for object in sortedObjects {
                let sectionNumber = collation.section(for: object, collationStringSelector: selector)
                sections[sectionNumber].append(object)
            }
        }
    }

    @objc private func leftBarButtonItemTapped(_ sender: UIBarButtonItem) {
        if navigationController?.viewControllers.first != self {
            navigationController?.popViewController(animated: true)
        } else {
            dismiss(animated: true)
        }
    }
}
