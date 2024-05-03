//
//  CommandRecordViewModel.swift
//  Pods
//
//  Created by zixun on 17/1/7.
//
//

import Foundation

class CommandRecordViewModel: BaseRecordViewModel<CommandRecordModel> {
    init(_ model: CommandRecordModel) {
        super.init(model: model)
    }
    
    override func attributeString(type: RecordORMAttributedType) -> NSAttributedString {
        let result = NSMutableAttributedString()
        result.append(headerString(type: type))
        result.append(actionString(type: type))
        return result
    }
    
    private func headerString(type: RecordORMAttributedType) -> NSAttributedString {
        let attributedString = headerString(with: type, prefix: "Command", content: model.command, color: UIColor(hex: 0xB754C4)) as? NSMutableAttributedString ?? .init()
        attributedString.removeAttribute(.link, range: .init(location: 0, length: attributedString.length))
        return attributedString
    }
    
    private func actionString(type: RecordORMAttributedType) -> NSAttributedString {
        NSAttributedString(string: model.actionResult, attributes: attributes(with: type))
    }
}
