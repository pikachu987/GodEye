//
//  RecordTableViewCell.swift
//  Pods
//
//  Created by zixun on 16/12/28.
//
//

import UIKit

protocol RecordTableViewCellDelete: AnyObject {
    func recordTableViewCellTapped(_ sender: RecordTableViewCell)
    func recordTableViewCellMoreTapped(_ sender: RecordTableViewCell)
}

final class RecordTableViewCell: UITableViewCell {
    weak var delegate: RecordTableViewCellDelete?

    static let reuseIdentifier = NSStringFromClass(RecordTableViewCell.classForCoder())

    private lazy var logTextView: UITextView = {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.isEditable = false
        $0.isScrollEnabled = false
        $0.textContainer.lineFragmentPadding = 0
        $0.textContainerInset = .zero
        $0.textAlignment = .left
        $0.clipsToBounds = true
        $0.font = .courier(with: 12)
        $0.textColor = .white
        $0.backgroundColor = .clear
        $0.linkTextAttributes = [:]
        return $0
    }(UITextView())

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        backgroundColor = .clear
        selectionStyle = .none
        
        contentView.addSubview(logTextView)

        NSLayoutConstraint.activate([
            logTextView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 5),
            logTextView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -5),
            logTextView.topAnchor.constraint(equalTo: contentView.topAnchor),
            logTextView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)])

        logTextView.delegate = self
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func prepareForReuse() {
        super.prepareForReuse()

        logTextView.attributedText = nil
    }

    func bind(_ attributedText: NSAttributedString) {
        logTextView.attributedText = attributedText
    }
}

extension RecordTableViewCell {
    @objc private func tapped(_ sender: UITapGestureRecognizer) {
        delegate?.recordTableViewCellTapped(self)
    }
}

extension RecordTableViewCell {
    class func boundingHeight(with width: CGFloat,
                              attributedText: NSAttributedString) -> CGFloat {
        let size = CGSize(width: width, height: CGFloat.greatestFiniteMagnitude)
        let rect = attributedText.boundingRect(with: size, options: [.usesLineFragmentOrigin, .usesDeviceMetrics, .usesFontLeading,.truncatesLastVisibleLine], context: nil)
        return max(rect.size.height, 10.5)
    }
}

extension RecordTableViewCell: UITextViewDelegate {
    func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange, interaction: UITextItemInteraction) -> Bool {
        if URL.absoluteString == "moreTap" {
            delegate?.recordTableViewCellMoreTapped(self)
        } else if URL.absoluteString == "tap" {
            delegate?.recordTableViewCellTapped(self)
        }

        return false
    }
}
