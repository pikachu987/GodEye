//
//  MonitorSysNetFlowView.swift
//  Pods
//
//  Created by zixun on 17/1/6.
//
//

import UIKit

final class MonitorSysNetFlowView: UIButton {
    private lazy var infoLabel: UILabel = {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.font = .systemFont(ofSize: 12)
        $0.textColor = .white
        $0.text = type.info
        return $0
    }(UILabel())

    private lazy var stackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [
            makeVStackView(subviews: [wifiSendLabel, wifiReceivedLabel]),
            makeVStackView(subviews: [wwanSendLabel, wwanReceivedLabel])
        ])
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .horizontal
        stackView.spacing = 20
        stackView.arrangedSubviews[0].widthAnchor.constraint(equalTo: stackView.arrangedSubviews[1].widthAnchor).isActive = true
        return stackView
    }()

    private func makeVStackView(subviews: [UIView]) -> UIStackView {
        let stackView = UIStackView(arrangedSubviews: subviews)
        stackView.axis = .vertical
        return stackView
    }

    private lazy var wifiSendLabel: UILabel = {
        $0.font = .systemFont(ofSize: 12)
        $0.textColor = .white
        $0.textAlignment = .left
        return $0
    }(UILabel())

    private lazy var wifiReceivedLabel: UILabel = {
        $0.font = .systemFont(ofSize: 12)
        $0.textColor = .white
        $0.textAlignment = .left
        return $0
    }(UILabel())

    private lazy var wwanSendLabel: UILabel = {
        $0.font = .systemFont(ofSize: 12)
        $0.textColor = .white
        $0.textAlignment = .left
        return $0
    }(UILabel())

    private lazy var wwanReceivedLabel: UILabel = {
        $0.font = .systemFont(ofSize: 12)
        $0.textColor = .white
        $0.textAlignment = .left
        return $0
    }(UILabel())

    let type: MonitorSystemType

    init(type: MonitorSystemType) {
        self.type = type
        super.init(frame: .zero)

        setupViews()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension MonitorSysNetFlowView {
    private func setupViews() {
        addSubview(infoLabel)
        addSubview(stackView)

        NSLayoutConstraint.activate([
            infoLabel.leadingAnchor.constraint(equalTo: leadingAnchor),
            infoLabel.trailingAnchor.constraint(equalTo: trailingAnchor),
            infoLabel.topAnchor.constraint(equalTo: topAnchor)
        ])

        NSLayoutConstraint.activate([
            stackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10),
            stackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10),
            stackView.topAnchor.constraint(equalTo: infoLabel.bottomAnchor, constant: 10),
            stackView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }

    func bind(wifiSend: UInt64, wifiReceived: UInt64, wwanSend: UInt64, wwanReceived: UInt64) {
        wifiSendLabel.attributedText = attributedString(prefix: "wifi send:", byte: wifiSend)
        wifiReceivedLabel.attributedText = attributedString(prefix: "wifi received:", byte: wifiReceived)
        wwanSendLabel.attributedText = attributedString(prefix: "wwan send:", byte: wwanSend)
        wwanReceivedLabel.attributedText = attributedString(prefix: "wwan received:", byte: wwanReceived)
    }
}

extension MonitorSysNetFlowView {
    private func attributedString(prefix: String, byte: UInt64) -> NSAttributedString {
        let result = NSMutableAttributedString()
        let storage = Double(byte).storageCapacity()

        result.append(NSAttributedString(string: prefix + "  ",
                                         attributes: [.font: UIFont.systemFont(ofSize: 10),
                                                      .foregroundColor: UIColor.white]))
        result.append(NSAttributedString(string: String(format: "%.1f", storage.capacity),
                                         attributes: [.font: UIFont(name: "HelveticaNeue-UltraLight", size: 18),
                                                      .foregroundColor: UIColor.white]))
        result.append(NSAttributedString(string: " \(storage.unit)",
                                         attributes: [.font: UIFont(name: "HelveticaNeue-UltraLight", size: 12),
                                                      .foregroundColor: UIColor.white]))
        return result
    }
}
