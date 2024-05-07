//
//  StorageViewController.swift
//  GodEye
//
//  Created by USER on 5/6/24.
//

import UIKit

final class StorageViewController: UIViewController {
    private lazy var tableView: UITableView = {
        $0.contentInset = .init(top: 40, left: 0, bottom: 0, right: 0)
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.delegate = self
        $0.dataSource = self
        $0.backgroundColor = .clear
        return $0
    }(UITableView(frame: .zero, style: .plain))

    private let models = StorageType.allCases

    override func viewDidLoad() {
        super.viewDidLoad()

        setupViews()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        navigationItem.title = "Storage"
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: .init(systemName: "xmark"), style: .done, target: self, action: #selector(leftBarButtonItemTapped(_:)))
    }
}

extension StorageViewController {
    private func setupViews() {
        view.backgroundColor = .niceBlack
        view.clipsToBounds = true

        view.addSubview(tableView)

        NSLayoutConstraint.activate([
            tableView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }
}

extension StorageViewController {
    @objc private func leftBarButtonItemTapped(_ sender: UIBarButtonItem) {
        GodEyeTabBarController.hide()
    }
}

extension StorageViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        models.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        tableView.dequeueReusableCell(style: .default, identifier: UITableViewCell.identifier, { (cell: UITableViewCell) in
            cell.backgroundColor = .clear
            cell.textLabel?.textColor = .white
        })
    }

    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.textLabel?.text = models[indexPath.row].title
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        64
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let model = models[indexPath.row]
        switch model {
        case .database:
            var models = [StorageDatabaseModel(databasePath: RecordDatabase.databasePath)]
            GodEye.configuration.map { $0.storage.databasePaths.map { StorageDatabaseModel(databasePath: $0) } }.map {
                models.append(contentsOf: $0)
            }
            let viewController = StorageListViewController(title: "Database", storageModels: models)
            navigationController?.pushViewController(viewController, animated: true)
        case .coreData:
            let models = GodEye.configuration.map { $0.storage.coreDataNames.map { StorageCoreDataModel(coreDataName: $0) } } ?? []
            let viewController = StorageListViewController(title: "CoreData", storageModels: models)
            navigationController?.pushViewController(viewController, animated: true)
        case .userDefaults:
            let html = UserDefaults.standard.dictionaryRepresentation().toHTML
            let viewController = WebViewViewContoller(title: "UserDefaults", html: html, shareItem: [html])
            navigationController?.pushViewController(viewController, animated: true)
        case .info:
            let html = Bundle.main.infoDictionary?.toHTML ?? ""
            let viewController = WebViewViewContoller(title: "Info.plist", html: html, shareItem: [html])
            navigationController?.pushViewController(viewController, animated: true)
        }
    }
}

extension StorageViewController {
    enum StorageType: CaseIterable {
        case database
        case coreData
        case userDefaults
        case info

        var title: String {
            switch self {
            case .database: return "Database"
            case .coreData: return "CoreData"
            case .userDefaults: return "UserDefaults"
            case .info: return "Info.plist"
            }
        }
    }
}
