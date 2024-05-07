//
//  SettingViewController.swift
//  Pods
//
//  Created by zixun on 17/1/10.
//
//

import UIKit

final class SettingViewController: UIViewController {
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

        navigationItem.title = "Setting"
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: .init(systemName: "xmark"), style: .done, target: self, action: #selector(leftBarButtonItemTapped(_:)))
    }
}

extension SettingViewController {
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

extension SettingViewController {
    @objc private func leftBarButtonItemTapped(_ sender: UIBarButtonItem) {
        GodEyeTabBarController.hide()
    }
    
    @objc private func switchValueChanged(_ sender: UISwitch) {
        let index = sender.tag
        if index == 0 {
            let manager = EyesManager.shared
            sender.isOn ? manager.openASLEye() : manager.closeASLEye()
        } else if index == 1 {
            let manager = EyesManager.shared
            sender.isOn ? manager.openLog4GEye() : manager.closeLog4GEye()
        } else if index == 2 {
            let manager = EyesManager.shared
            sender.isOn ? manager.openCrashEye() : manager.closeCrashEye()
        } else if index == 3 {
            let manager = EyesManager.shared
            sender.isOn ? manager.openNetworkEye() : manager.closeNetworkEye()
        } else if index == 4 {
            let manager = EyesManager.shared
            sender.isOn ? manager.openANREye() : manager.closeANREye()
        } else if index == 5 {
            let manager = EyesManager.shared
            sender.isOn ? manager.openLeakEye() : manager.closeLeakEye()
        }
    }
}

extension SettingViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        6
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        tableView.dequeueReusableCell(style: .subtitle, identifier: UITableViewCell.identifier, { (cell: UITableViewCell) in
            cell.backgroundColor = .clear
            cell.textLabel?.textColor = .white
            cell.detailTextLabel?.textColor = .gray
            let accessoryView = UISwitch()
            accessoryView.isOn = false
            accessoryView.addTarget(self, action: #selector(switchValueChanged(_:)), for: .valueChanged)
            cell.accessoryView = accessoryView
        })
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        guard let accessoryView = cell.accessoryView as? UISwitch else { return }
        accessoryView.tag = indexPath.row
        
        if indexPath.row == 0 {
            cell.detailTextLabel?.text = "eye of Apple System Logs"
            cell.textLabel?.text = "ASL Eye Switch"
            accessoryView.isOn = EyesManager.shared.isASLEyeOpening()
        } else if indexPath.row == 1 {
            cell.detailTextLabel?.text = "monitor of log4g"
            cell.textLabel?.text = "Log4G Switch"
            accessoryView.isOn = EyesManager.shared.isLog4GEyeOpening()
        } else if indexPath.row == 2 {
            cell.detailTextLabel?.text = "eye of crash stack information"
            cell.textLabel?.text = "Crash Eye Switch"
            accessoryView.isOn = EyesManager.shared.isCrashEyeOpening()
        } else if indexPath.row == 3 {
            cell.detailTextLabel?.text = "eye of network request and response"
            cell.textLabel?.text = "Network Eye Switch"
            accessoryView.isOn = EyesManager.shared.isNetworkEyeOpening()
        } else if indexPath.row == 4 {
            cell.detailTextLabel?.text = "eye of application not responding"
            cell.textLabel?.text = "ANR Eye Switch"
            accessoryView.isOn = EyesManager.shared.isANREyeOpening()
        } else if indexPath.row == 5 {
            cell.detailTextLabel?.text = "eye of object leak"
            cell.textLabel?.text = "Leak Eye Switch"
            accessoryView.isOn = EyesManager.shared.isLeakEyeOpening()
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        64
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        guard let cell = tableView.cellForRow(at: indexPath), let accessoryView = cell.accessoryView as? UISwitch else { return }
        accessoryView.sendActions(for: .touchUpInside)
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0: return "Console"
        default: return ""
        }
    }
}
