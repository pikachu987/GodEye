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
    
    override func attributeString(type: RecordORMAttributedType, filterType: RecordORMFilterType?, filterText: String?) -> NSAttributedString {
        let result = NSMutableAttributedString()
        result.append(headerString(type: type, filterType: filterType, filterText: filterText))
        result.append(actionString(type: type, filterType: filterType, filterText: filterText))
        return result
    }
    
    private func headerString(type: RecordORMAttributedType, filterType: RecordORMFilterType?, filterText: String?) -> NSAttributedString {
        let highlightText = CommandRecordModel.FilterType.command.highlightText(filterType: filterType, filterText: filterText)
        return headerString(with: type, prefix: "Command", content: model.command, color: UIColor(hex: 0xB754C4), highlightText: highlightText)
    }
    
    private func actionString(type: RecordORMAttributedType, filterType: RecordORMFilterType?, filterText: String?) -> NSAttributedString {
        let highlightText = CommandRecordModel.FilterType.result.highlightText(filterType: filterType, filterText: filterText)
        let attributedString = NSMutableAttributedString(string: model.actionResult, attributes: attributes(with: type, link: .tap))
        attributedString.highlight(highlightText: highlightText)
        return attributedString
    }
}
