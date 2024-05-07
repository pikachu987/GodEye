//
//  FileViewController.swift
//  Pods
//
//  Created by zixun on 17/1/10.
//
//

import UIKit

final class FileViewController: UIViewController {
    private lazy var tableView: UITableView = {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.delegate = self
        $0.dataSource = self
        $0.backgroundColor = .clear
        return $0
    }(UITableView(frame: .zero, style: .grouped))

    override func viewDidLoad() {
        super.viewDidLoad()

        setupViews()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        navigationItem.title = "File"
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: .init(systemName: "xmark"), style: .done, target: self, action: #selector(leftBarButtonItemTapped(_:)))
    }
}

extension FileViewController {
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

    @objc private func leftBarButtonItemTapped(_ sender: UIBarButtonItem) {
        GodEyeTabBarController.hide()
    }
}

extension FileViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        3
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        tableView.dequeueReusableCell(style: .subtitle, identifier: UITableViewCell.identifier, { (cell: UITableViewCell) in
            cell.backgroundColor = .clear
            cell.textLabel?.textColor = .white
            cell.detailTextLabel?.textColor = .gray
            cell.accessoryType = .disclosureIndicator
        })
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row == 0 {
            cell.detailTextLabel?.text = "document, cache, etc..."
            cell.textLabel?.text = "App Home Folder"
        } else if indexPath.row == 1 {
            let path = Bundle.main.bundlePath
            cell.detailTextLabel?.text = "all file and folder in \(path.NS.lastPathComponent)"
            cell.textLabel?.text = path.NS.lastPathComponent + " Folder"
        } else if indexPath.row == 2 {
            cell.detailTextLabel?.text = "all file and folder in /"
            cell.textLabel?.text = "Root Folder"
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        64
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        var url: URL?
        if indexPath.row == 0 {
            if let str = NSSearchPathForDirectoriesInDomains(.applicationDirectory, .userDomainMask, true).first?.NS.deletingLastPathComponent {
                url = URL(string: str)
            }
        } else if indexPath.row == 1 {
            url = URL(string: Bundle.main.bundlePath)
        } else if indexPath.row == 2 {
            url = URL(string: "/")
        }
        
        url.map {
            let browser = FileBrowserNavigationController(initialPath: $0)
            present(browser, animated: true)
        }
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0: return "Folder"
        default: return nil
        }
    }
}
