//
//  SettingViewController.swift
//  Pods
//
//  Created by zixun on 17/1/10.
//
//

import UIKit

final class SettingViewController: UIViewController {
    typealias Action = SettingConfiguration.ActionModel
    private lazy var tableView: UITableView = {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.delegate = self
        $0.dataSource = self
        $0.backgroundColor = .clear
        return $0
    }(UITableView(frame: .zero, style: .grouped))

    private let switches = SwitchConfig.allCases
    private var actions: [Action] {
        GodEye.configuration?.setting.actionList ?? []
    }

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
        guard switches.indices ~= index else { return }
        switches[index].isOn(sender.isOn)
    }
}

extension SettingViewController: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        actions.isEmpty ? 1 : 2
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return switches.count
        } else if section == 1 {
            return actions.count
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        tableView.dequeueReusableCell(style: .subtitle, identifier: UITableViewCell.identifier, { (cell: UITableViewCell) in
            cell.backgroundColor = .clear
            cell.textLabel?.textColor = .white
            cell.detailTextLabel?.textColor = .gray
            if indexPath.section == 0 {
                let accessoryView = UISwitch()
                accessoryView.isOn = false
                accessoryView.addTarget(self, action: #selector(switchValueChanged(_:)), for: .valueChanged)
                cell.accessoryView = accessoryView
            } else {
                cell.accessoryView = nil
            }
        })
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.section == 0 {
            guard let accessoryView = cell.accessoryView as? UISwitch, switches.indices ~= indexPath.row else { return }
            accessoryView.tag = indexPath.row
            let switchValue = switches[indexPath.row]
            cell.detailTextLabel?.text = switchValue.desc
            cell.textLabel?.text = switchValue.title
            accessoryView.isOn = switchValue.isOn
        } else if indexPath.section == 1 {
            guard actions.indices ~= indexPath.row else { return }
            let action = actions[indexPath.row]
            cell.detailTextLabel?.text = action.desc
            cell.textLabel?.text = action.title
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        64
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if indexPath.section == 0 {
            guard let cell = tableView.cellForRow(at: indexPath), let accessoryView = cell.accessoryView as? UISwitch else { return }
            accessoryView.sendActions(for: .touchUpInside)
        } else if indexPath.section == 1 {
            guard actions.indices ~= indexPath.row else { return }
            let action = actions[indexPath.row]
            action.action()
        }
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0: return "Switch"
        case 1: return "Action"
        default: return nil
        }
    }
}

extension SettingViewController {
    enum SwitchConfig: CaseIterable {
        case asl
        case log4g
        case crash
        case network
        case arn
        case leak

        var title: String {
            switch self {
            case .asl: return "ASL Eye Switch"
            case .log4g: return "Log4G Switch"
            case .crash: return "Crash Eye Switch"
            case .network: return "Network Eye Switch"
            case .arn: return "ANR Eye Switch"
            case .leak: return "Leak Eye Switch"
            }
        }

        var desc: String {
            switch self {
            case .asl: return "eye of Apple System Logs"
            case .log4g: return "monitor of log4g"
            case .crash: return "eye of crash stack information"
            case .network: return "eye of network request and response"
            case .arn: return "eye of application not responding"
            case .leak: return "eye of object leak"
            }
        }

        var isOn: Bool {
            switch self {
            case .asl: return EyesManager.shared.isASLEyeOpening()
            case .log4g: return EyesManager.shared.isLog4GEyeOpening()
            case .crash: return EyesManager.shared.isCrashEyeOpening()
            case .network: return EyesManager.shared.isNetworkEyeOpening()
            case .arn: return EyesManager.shared.isANREyeOpening()
            case .leak: return EyesManager.shared.isLeakEyeOpening()
            }
        }

        func isOn(_ value: Bool) {
            let manager = EyesManager.shared
            switch self {
            case .asl:
                value ? manager.openASLEye() : manager.closeASLEye()
            case .log4g:
                value ? manager.openLog4GEye() : manager.closeLog4GEye()
            case .crash:
                value ? manager.openCrashEye() : manager.closeCrashEye()
            case .network:
                value ? manager.openNetworkEye() : manager.closeNetworkEye()
            case .arn:
                value ? manager.openANREye() : manager.closeANREye()
            case .leak:
                value ? manager.openLeakEye() : manager.closeLeakEye()
            }
        }
    }
}
