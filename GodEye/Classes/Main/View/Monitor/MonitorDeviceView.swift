//
//  MonitorDeviceView.swift
//  Pods
//
//  Created by zixun on 17/1/5.
//
//

import UIKit

final class MonitorDeviceView: UIButton {
    private lazy var nameLabel: UILabel = {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.font = .boldSystemFont(ofSize: 24)
        $0.textColor = .white
        $0.textAlignment = .left
        return $0
    }(UILabel())

    private lazy var osLabel: UILabel = {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.font = .systemFont(ofSize: 18)
        $0.textColor = .white
        $0.textAlignment = .left
        return $0
    }(UILabel())

    init() {
        super.init(frame: .zero)

        setupViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension MonitorDeviceView {
    private func setupViews() {
        backgroundColor = .clear

        addSubview(nameLabel)
        addSubview(osLabel)

        NSLayoutConstraint.activate([
            nameLabel.leadingAnchor.constraint(equalTo: leadingAnchor),
            nameLabel.trailingAnchor.constraint(equalTo: trailingAnchor),
            nameLabel.topAnchor.constraint(equalTo: topAnchor)
        ])

        NSLayoutConstraint.activate([
            osLabel.leadingAnchor.constraint(equalTo: leadingAnchor),
            osLabel.trailingAnchor.constraint(equalTo: trailingAnchor),
            osLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 6),
            osLabel.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }

    func bind(nameString: String, osString: String) {
        nameLabel.text = nameString
        osLabel.text = "OS Version: \(osString)"
    }
}
