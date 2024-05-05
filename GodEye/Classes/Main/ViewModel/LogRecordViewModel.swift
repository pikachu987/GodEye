//
//  LogRecordViewModel.swift
//  Pods
//
//  Created by zixun on 16/12/28.
//
//

import Foundation

class LogRecordViewModel: BaseRecordViewModel<LogRecordModel> {
    init(_ model: LogRecordModel) {
        super.init(model: model)
    }

    override func attributeString(type: RecordORMAttributedType, filterType: RecordORMFilterType?, filterText: String?) -> NSAttributedString {
        let result = NSMutableAttributedString()
        result.append(headerString(type: type, filterType: filterType, filterText: filterText))
        if let additon = additionString(type: type, filterType: filterType, filterText: filterText) {
            result.append(additon)
        }
        return result
    }
    
    private func headerString(type: RecordORMAttributedType, filterType: RecordORMFilterType?, filterText: String?) -> NSAttributedString {
        let highlightText = model.type.highlightText(filterType: filterType, filterText: filterText)
        return headerString(with: type, prefix: model.type.string, content: model.message, color: model.type.color, highlightText: highlightText)
    }
    
    private func additionString(type: RecordORMAttributedType, filterType: RecordORMFilterType?, filterText: String?) -> NSAttributedString? {
        if model.type == .asl { return nil }
        let highlightText = model.type.highlightText(filterType: filterType, filterText: filterText)

        let date = model.date ?? ""
        let thread = model.thread ?? ""
        let file = model.file ?? ""
        let line = model.line ?? -1
        let function = model.function ?? ""
        
        var content: String = "[\(file): \(line)](\(function)) \(date) -> \(thread)"
        let result = NSMutableAttributedString(attributedString: contentString(with: type, content: content, highlightText: highlightText))
        return result
    }
}
