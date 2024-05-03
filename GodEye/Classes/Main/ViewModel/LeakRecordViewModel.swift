//
//  LeakRecordViewModel.swift
//  Pods
//
//  Created by zixun on 17/1/12.
//
//

import Foundation

class LeakRecordViewModel: BaseRecordViewModel<LeakRecordModel> {
    init(_ model: LeakRecordModel) {
        super.init(model: model)
    }
    
    override func attributeString(type: RecordORMAttributedType) -> NSAttributedString {
        let result = NSMutableAttributedString()
        result.append(headerString(type: type))
        return result
    }
    
    private func headerString(type: RecordORMAttributedType) -> NSAttributedString {
        headerString(with: type, prefix: "Leak", content: "[\(model.clazz): \(model.address)]", color: UIColor(hex: 0xB754C4))
    }
}
