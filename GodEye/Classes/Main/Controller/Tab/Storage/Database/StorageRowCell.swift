//
//  StorageRowCell.swift
//  GodEye
//
//  Created by USER on 5/7/24.
//

import UIKit

final class StorageRowCell: UITableViewCell {
    private lazy var stackView: UIStackView = {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.axis = .horizontal
        return $0
    }(UIStackView())

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        setupViews()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupViews() {
        backgroundColor = .clear

        contentView.addSubview(stackView)

        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: contentView.topAnchor),
            stackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            stackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])
    }

    func bind(model: StorageRowModel) {
        if stackView.arrangedSubviews.count - 1 != model.widths.count {
            stackView.subviews.forEach { $0.removeFromSuperview() }
            model.widths.map { width in
                let view = FieldView(font: model.font, horizontalMargin: model.horizontalMargin, isColumn: model.isColumn)
                view.widthAnchor.constraint(equalToConstant: width + model.horizontalMargin * 2).isActive = true
                return view
            }.forEach {
                stackView.addArrangedSubview($0)
            }
            stackView.addArrangedSubview(UIView())
        }
        model.values.enumerated().forEach {
            let fieldView = stackView.arrangedSubviews.compactMap({ $0 as? FieldView })[$0.offset]
            fieldView.text = $0.element
            fieldView.isFull = model.isFull
        }
    }
}

extension StorageRowCell {
    final class FieldView: UIView {
        private let label: UILabel = {
            $0.translatesAutoresizingMaskIntoConstraints = false
            $0.textColor = .white
            $0.numberOfLines = 4
            return $0
        }(UILabel())

        private let horizontalMargin: CGFloat

        init(font: UIFont, horizontalMargin: CGFloat, isColumn: Bool) {
            self.horizontalMargin = horizontalMargin
            super.init(frame: .zero)

            if isColumn, let boldDescriptor = font.fontDescriptor.withSymbolicTraits(.traitBold) {
                label.font = UIFont(descriptor: boldDescriptor, size: font.pointSize)
            } else {
                label.font = font
            }
            label.textAlignment = isColumn ? .center : .left
            setupViews()
        }

        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }

        private func setupViews() {
            addSubview(label)

            NSLayoutConstraint.activate([
                label.topAnchor.constraint(equalTo: topAnchor, constant: 8),
                label.leadingAnchor.constraint(equalTo: leadingAnchor, constant: horizontalMargin),
                label.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -horizontalMargin),
                label.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -8)
            ])
        }

        var text: String {
            set { label.text = newValue }
            get { label.text ?? "" }
        }

        var isFull: Bool {
            set { label.numberOfLines = newValue ? 0 : 4 }
            get { label.numberOfLines == 0 }
        }
    }
}
