//
//  StorageListViewController.swift
//  GodEye
//
//  Created by USER on 5/6/24.
//

import UIKit

final class StorageListViewController: UIViewController {
    private lazy var tableView: UITableView = {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.delegate = self
        $0.dataSource = self
        $0.backgroundColor = .clear
        return $0
    }(UITableView(frame: .zero, style: .grouped))

    private let storageModels: [StorageListable]
    private let titleText: String

    init(title: String, storageModels: [StorageListable]) {
        self.titleText = title
        self.storageModels = storageModels
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupViews()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        navigationItem.title = titleText
    }
}

extension StorageListViewController {
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

extension StorageListViewController: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        storageModels.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard storageModels.indices ~= section else { return 0 }
        return storageModels[section].count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        tableView.dequeueReusableCell(style: .default, identifier: UITableViewCell.identifier, { (cell: UITableViewCell) in
            cell.backgroundColor = .clear
            cell.textLabel?.textColor = .white
        })
    }

    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        guard storageModels.indices ~= indexPath.section else { return }
        guard storageModels[indexPath.section].indices ~= indexPath.row else { return }
        cell.textLabel?.text = storageModels[indexPath.section].displayText(index: indexPath.row)
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        64
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard storageModels.indices ~= section else { return nil }
        let headerView = UITableViewHeaderFooterView()
        headerView.textLabel?.text = storageModels[section].headerName
        return headerView
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        guard storageModels.indices ~= indexPath.section else { return }
        let model = storageModels[indexPath.section]
        guard model.indices ~= indexPath.row else { return }
        let viewController = StorageViewerViewController(viewerModel: model.viewer(index: indexPath.row))
        navigationController?.pushViewController(viewController, animated: true)
    }
}
