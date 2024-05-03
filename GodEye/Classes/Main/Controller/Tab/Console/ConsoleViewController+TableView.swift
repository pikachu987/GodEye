//
//  ConsoleViewController+TableView.swift
//  Pods
//
//  Created by zixun on 16/12/28.
//
//

import Foundation

private final class ConsoleTableViewModel: NSObject {
    private(set) var title: String
    private(set) var detail: String

    init(title: String, detail: String) {
        self.title = title
        self.detail = detail
        super.init()
    }
}

extension ConsoleViewController {
    func reloadRow(of type: RecordType) {
        guard let indexPath = indexPath(of: type) else { return }
        guard dataSource.indices ~= indexPath.section else { return }
        guard dataSource[indexPath.section].indices ~= indexPath.row else { return }
        tableView.reloadRows(at: [indexPath], with: .none)
    }
    
    private func indexPath(of type: RecordType) -> IndexPath? {
        for i in 0..<dataSource.count {
            let types = dataSource[i]
            for j in 0..<types.count {
                if dataSource[i][j] == type {
                    return IndexPath(row: j, section: i)
                }
            }
        }
        return nil
    }
}

extension ConsoleViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        64
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        guard dataSource.indices ~= indexPath.section else { return }
        guard dataSource[indexPath.section].indices ~= indexPath.row else { return }
        let type = dataSource[indexPath.section][indexPath.row]
        let viewController = ConsolePrintViewController(type: type)
        navigationController?.pushViewController(viewController, animated: true)
        printViewController = viewController
        type.cleanUnread()
        reloadRow(of: type)
    }
}

extension ConsoleViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        dataSource.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard dataSource.indices ~= section else { return 0 }
        return dataSource[section].count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        tableView.dequeueReusableCell(style: .subtitle, identifier: ConsoleTableViewCell.identifier, { (cell: ConsoleTableViewCell) in })
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        guard dataSource.indices ~= indexPath.section else { return }
        guard dataSource[indexPath.section].indices ~= indexPath.row else { return }
        let cell = cell as? ConsoleTableViewCell
        cell?.bind(type: dataSource[indexPath.section][indexPath.row])
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0: return "RECORD"
        case 1: return "Terminal"
        default: return ""
        }
    }
}

private final class ConsoleTableViewCell: UITableViewCell {
    private lazy var unreadView: UIView = {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.backgroundColor = .red
        $0.clipsToBounds = true
        $0.layer.cornerRadius = 10
        return $0
    }(UIView())

    private lazy var unreadLabel: UILabel = {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.textAlignment = .center
        $0.font = .systemFont(ofSize: 12)
        $0.text = nil
        $0.textColor = .white
        return $0
    }(UILabel())

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        backgroundColor = .clear
        textLabel?.textColor = .white
        detailTextLabel?.textColor = .gray
        accessoryType = .disclosureIndicator

        contentView.addSubview(unreadView)
        unreadView.addSubview(unreadLabel)

        NSLayoutConstraint.activate([
            unreadView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10),
            unreadView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
        ])

        NSLayoutConstraint.activate([
            unreadLabel.leadingAnchor.constraint(equalTo: unreadView.leadingAnchor, constant: 6),
            unreadLabel.trailingAnchor.constraint(equalTo: unreadView.trailingAnchor, constant: -6),
            unreadLabel.topAnchor.constraint(equalTo: unreadView.topAnchor, constant: 3),
            unreadLabel.bottomAnchor.constraint(equalTo: unreadView.bottomAnchor, constant: -3),
        ])
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func bind(type: RecordType)  {
        textLabel?.text = type.title
        detailTextLabel?.text = type.detail

        let unread = type.unread
        if unread == 0 {
            unreadView.isHidden = true
            unreadLabel.text = nil
        } else if unread >= 100 {
            unreadView.isHidden = false
            unreadLabel.text = "99+"
        } else {
            unreadView.isHidden = false
            unreadLabel.text = String(unread)
        }
    }
}
