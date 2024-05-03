//
//  GodEyeViewController.swift
//  Pods
//
//  Created by zixun on 16/12/27.
//
//

import UIKit

final class MonitoringLiteView: UIView {
    private let type: MonitoringType

    private enum Constant {
        static let titleFont: UIFont = .systemFont(ofSize: 9)
        static let valueFont: UIFont = .systemFont(ofSize: 9)
    }

    private lazy var valueLabel: UILabel = {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.textAlignment = .center
        $0.font = Constant.valueFont
        $0.textColor = .black
        $0.adjustsFontSizeToFitWidth = true
        $0.minimumScaleFactor = 0.5
        return $0
    }(UILabel())

    private lazy var bottomView: UIView = {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.backgroundColor = UIColor(red: 112/255, green: 112/255, blue: 112/255, alpha: 1)
        return $0
    }(UIView())

    private lazy var bottomLabel: UILabel = {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.textAlignment = .center
        $0.textColor = .white
        $0.font = Constant.titleFont
        $0.text = type.title
        return $0
    }(UILabel())

    init(type: MonitoringType) {
        self.type = type
        super.init(frame: .zero)

        setupViews()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupViews() {
        backgroundColor = .white

        let lineView = UIView()
        lineView.translatesAutoresizingMaskIntoConstraints = false
        lineView.backgroundColor = .black

        addSubview(valueLabel)
        addSubview(bottomView)
        addSubview(lineView)
        bottomView.addSubview(bottomLabel)

        NSLayoutConstraint.activate([
            valueLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 3),
            valueLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -3),
            valueLabel.topAnchor.constraint(equalTo: topAnchor)
        ])

        NSLayoutConstraint.activate([
            bottomView.topAnchor.constraint(equalTo: valueLabel.bottomAnchor),
            bottomView.leadingAnchor.constraint(equalTo: leadingAnchor),
            bottomView.trailingAnchor.constraint(equalTo: trailingAnchor),
            bottomView.bottomAnchor.constraint(equalTo: bottomAnchor),
            bottomView.heightAnchor.constraint(equalToConstant: 16)
        ])

        NSLayoutConstraint.activate([
            bottomLabel.topAnchor.constraint(equalTo: bottomView.topAnchor),
            bottomLabel.leadingAnchor.constraint(equalTo: bottomView.leadingAnchor),
            bottomLabel.trailingAnchor.constraint(equalTo: bottomView.trailingAnchor),
            bottomLabel.bottomAnchor.constraint(equalTo: bottomView.bottomAnchor)
        ])

        NSLayoutConstraint.activate([
            lineView.topAnchor.constraint(equalTo: topAnchor),
            lineView.trailingAnchor.constraint(equalTo: trailingAnchor),
            lineView.bottomAnchor.constraint(equalTo: bottomAnchor),
            lineView.widthAnchor.constraint(equalToConstant: 1)
        ])
    }
}

extension MonitoringLiteView {
    private func attributes(font: UIFont) -> [NSAttributedString.Key : Any] {
        [.font: font,
         .foregroundColor: UIColor.black]
    }

    private func contentString(_ string: String, unit: String) -> NSAttributedString {
        let result = NSMutableAttributedString()
        result.append(NSAttributedString(string: string, attributes: attributes(font: Constant.valueFont)))
        result.append(NSAttributedString(string: " \(unit)", attributes: attributes(font: Constant.valueFont)))
        return result
    }
}

extension MonitoringLiteView {
    func bind(_ value: Double, unit: String) {
        valueLabel.attributedText = contentString(String(format: "%.1f", value), unit: unit)
    }
}


extension MonitoringLiteView {
    enum MonitoringType {
        case appCPU
        case appRAM
        case appFPS
        case appNET
        case sysCPU
        case sysRAM

        var title: String {
            switch self {
            case .appCPU: return "APP CPU"
            case .appRAM: return "APP MEM"
            case .appFPS: return "APP FPS"
            case .appNET: return "APP NET"
            case .sysCPU: return "SYS CPU"
            case .sysRAM: return "SYS RAM"
            }
        }
    }
}
