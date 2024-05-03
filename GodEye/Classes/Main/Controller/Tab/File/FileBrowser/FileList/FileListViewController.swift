//
//  FileListViewController.swift
//  FileBrowser
//
//  Created by Roy Marmelstein on 12/02/2016.
//  Copyright © 2016 Roy Marmelstein. All rights reserved.
//

import UIKit

final class FileListViewController: UIViewController {
    lazy var tableView: UITableView = {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.backgroundColor = .clear
        return $0
    }(UITableView(frame: .zero, style: .plain))

    let searchController: UISearchController = {
        $0.searchBar.searchBarStyle = .minimal
        $0.searchBar.backgroundColor = .fileBrowserBackground()
        $0.dimsBackgroundDuringPresentation = false
        return $0
    }(UISearchController(searchResultsController: nil))

    private lazy var titleView: UILabel = {
        $0.text = initialPath.lastPathComponent
        $0.adjustsFontSizeToFitWidth = true
        $0.minimumScaleFactor = 0.5
        $0.font = .systemFont(ofSize: 17, weight: .bold)
        return $0
    }(UILabel())

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
    
    deinit {
        if #available(iOS 9.0, *) {
            searchController.loadViewIfNeeded()
        } else {
            searchController.loadView()
        }
    }

    override func viewDidLoad() {
        setupViews()
        prepareData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        navigationItem.titleView = titleView
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: .init(systemName: "xmark"), style: .done, target: self, action: #selector(rightBarButtonItemTapped(_:)))
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
        if searchController.isActive {
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
        view.backgroundColor = .fileBrowserBackground()
        view.clipsToBounds = true

        view.addSubview(tableView)

        NSLayoutConstraint.activate([
            tableView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])

        // Set search bar
        tableView.tableHeaderView = searchController.searchBar

        searchController.searchResultsUpdater = self
        searchController.searchBar.delegate = self
        searchController.delegate = self

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

    @objc private func rightBarButtonItemTapped(_ sender: UIBarButtonItem) {
        dismiss(animated: true)
    }
}
