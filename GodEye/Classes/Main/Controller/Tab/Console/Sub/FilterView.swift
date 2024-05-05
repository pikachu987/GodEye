//
//  ConsolePrintViewController.swift
//  Pods
//
//  Created by zixun on 16/12/28.
//
//

import UIKit

final class FilterView: UIView {
    private lazy var containerView: UIView = {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.backgroundColor = .systemBlue
        return $0
    }(UIView())

    private lazy var textLabel: UILabel = {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.textColor = .white
        return $0
    }(UILabel())

    private lazy var arrowImageView: UIImageView = {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.tintColor = .white
        return $0
    }(UIImageView(image: .init(systemName: "chevron.down")))

    init() {
        super.init(frame: .zero)

        addSubview(containerView)
        containerView.addSubview(textLabel)
        containerView.addSubview(arrowImageView)

        NSLayoutConstraint.activate([
            containerView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 8),
            containerView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -8),
            containerView.topAnchor.constraint(equalTo: topAnchor, constant: 12),
            containerView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -12)
        ])

        NSLayoutConstraint.activate([
            textLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 8),
            textLabel.centerYAnchor.constraint(equalTo: containerView.centerYAnchor)
        ])

        NSLayoutConstraint.activate([
            arrowImageView.leadingAnchor.constraint(equalTo: textLabel.trailingAnchor, constant: 8),
            arrowImageView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -8),
            arrowImageView.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            arrowImageView.widthAnchor.constraint(equalToConstant: 12),
            arrowImageView.heightAnchor.constraint(equalToConstant: 18)
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func updateTitle(_ title: String) {
        textLabel.text = title
    }
}
