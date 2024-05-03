//
//  MonitorPercentView.swift
//  Pods
//
//  Created by zixun on 17/1/5.
//
//

import Foundation

class MonitorBaseView: UIButton {
    private lazy var contentLabel: UILabel = {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.text = "Unknow"
        $0.textColor = .white
        $0.textAlignment = .right
        $0.numberOfLines = 0
        $0.font = UIFont(name: "HelveticaNeue-UltraLight", size: 32)
        return $0
    }(UILabel())

    private lazy var infoLabel: UILabel = {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.font = .systemFont(ofSize: 12)
        $0.textColor = .white
        return $0
    }(UILabel())

    let type: MonitorSystemType

    init(type: MonitorSystemType) {
        self.type = type
        super.init(frame: .zero)

        setupViews()
        bind()
    }

    private func setupViews() {
        backgroundColor = .clear

        addSubview(infoLabel)
        addSubview(contentLabel)

        NSLayoutConstraint.activate([
            infoLabel.topAnchor.constraint(equalTo: topAnchor, constant: 10),
            infoLabel.leadingAnchor.constraint(equalTo: leadingAnchor),
            infoLabel.trailingAnchor.constraint(equalTo: trailingAnchor)
        ])

        NSLayoutConstraint.activate([
            contentLabel.leadingAnchor.constraint(equalTo: leadingAnchor),
            contentLabel.trailingAnchor.constraint(equalTo: trailingAnchor),
            contentLabel.centerYAnchor.constraint(equalTo: centerYAnchor),
        ])
    }

    private func bind() {
        infoLabel.text = type.info
        contentLabel.text = type.initialValue
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension MonitorBaseView {
    private func attributes(size: CGFloat) -> [NSAttributedString.Key : Any] {
        [.font: UIFont(name: "HelveticaNeue-UltraLight", size: size),
         .foregroundColor: UIColor.white]
    }
    
    private func contentString(_ string: String, unit: String) -> NSAttributedString {
        let result = NSMutableAttributedString()
        result.append(NSAttributedString(string: string, attributes: attributes(size: 32)))
        result.append(NSAttributedString(string: " \(unit)", attributes: attributes(size: 16)))
        return result
    }
}

extension MonitorBaseView {
    func bind(_ value: Double, unit: String) {
        contentLabel.attributedText = contentString(String(format: "%.1f", value), unit: unit)
    }
}
