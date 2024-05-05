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
    
    override func attributeString(type: RecordORMAttributedType, filterType: RecordORMFilterType?, filterText: String?) -> NSAttributedString {
        let result = NSMutableAttributedString()
        result.append(headerString(type: type, filterType: filterType, filterText: filterText))
        return result
    }
    
    private func headerString(type: RecordORMAttributedType, filterType: RecordORMFilterType?, filterText: String?) -> NSAttributedString {
        let clazzHighlightText = LeakRecordModel.FilterType.clazz.highlightText(filterType: filterType, filterText: filterText)
        let addressHighlightText = LeakRecordModel.FilterType.address.highlightText(filterType: filterType, filterText: filterText)
        let attr = NSMutableAttributedString()
        attr.append(headerString(with: type, prefix: "Leak", content: "[\(model.clazz): ", color: UIColor(hex: 0xB754C4), highlightText: clazzHighlightText))
        attr.append(headerString(with: type, content: "\(model.address)]", color: UIColor(hex: 0xB754C4), highlightText: addressHighlightText))
        return attr
    }
}
