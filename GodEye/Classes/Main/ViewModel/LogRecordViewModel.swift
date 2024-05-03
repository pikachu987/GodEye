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

    override func attributeString(type: RecordORMAttributedType) -> NSAttributedString {
        let result = NSMutableAttributedString()
        result.append(headerString(type: type))
        if let additon = additionString(type: type) {
            result.append(additon)
        }
        return result
    }
    
    private func headerString(type: RecordORMAttributedType) -> NSAttributedString {
        headerString(with: type, prefix: model.type.string, content: model.message, color: model.type.color)
    }
    
    private func additionString(type: RecordORMAttributedType) -> NSAttributedString? {
        if model.type == .asl { return nil }

        let date = model.date ?? ""
        let thread = model.thread ?? ""
        let file = model.file ?? ""
        let line = model.line ?? -1
        let function = model.function ?? ""
        
        var content: String = "[\(file): \(line)](\(function)) \(date) -> \(thread)"
        let result = NSMutableAttributedString(attributedString: contentString(with: type, prefix: nil, content: content))
        return result
    }
}
