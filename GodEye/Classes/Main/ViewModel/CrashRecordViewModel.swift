//
//  CrashRecordViewModel.swift
//  Pods
//
//  Created by zixun on 16/12/28.
//
//

import Foundation

class CrashRecordViewModel: BaseRecordViewModel<CrashRecordModel> {
    init(_ model: CrashRecordModel) {
        super.init(model: model)
    }
    
    override func attributeString(type: RecordORMAttributedType, filterType: RecordORMFilterType?, filterText: String?) -> NSAttributedString {
        let result = NSMutableAttributedString()
        result.append(headerString(type: type))
        result.append(nameString(type: type, filterType: filterType, filterText: filterText))
        result.append(reasonString(type: type, filterType: filterType, filterText: filterText))
        result.append(appinfoString(type: type, filterType: filterType, filterText: filterText))
        result.append(callStackString(type: type, filterType: filterType, filterText: filterText))
        return result
    }
    
    private func headerString(type: RecordORMAttributedType) -> NSAttributedString {
        let contentType = model.type == .exception ? "Exception" : "SIGNAL"
        return headerString(with: type, prefix: "CRASH", content: contentType, color: UIColor(hex: 0xDF1921))
    }
    
    private func nameString(type: RecordORMAttributedType, filterType: RecordORMFilterType?, filterText: String?) -> NSAttributedString {
        let highlightText = CrashRecordModel.FilterType.name.highlightText(filterType: filterType, filterText: filterText)
        return contentString(with: type, prefix: "NAME", content: model.name, highlightText: highlightText)
    }
    
    private func reasonString(type: RecordORMAttributedType, filterType: RecordORMFilterType?, filterText: String?) -> NSAttributedString {
        let highlightText =  CrashRecordModel.FilterType.reason.highlightText(filterType: filterType, filterText: filterText)
        return contentString(with: type, prefix: "REASON", content: model.reason, highlightText: highlightText)
    }
    
    private func appinfoString(type: RecordORMAttributedType, filterType: RecordORMFilterType?, filterText: String?) -> NSAttributedString {
        let highlightText = CrashRecordModel.FilterType.appinfo.highlightText(filterType: filterType, filterText: filterText)
        return contentString(with: type, prefix: "APPINFO", content: model.appinfo, highlightText: highlightText)
    }
    
    private func callStackString(type: RecordORMAttributedType, filterType: RecordORMFilterType?, filterText: String?) -> NSAttributedString {
        let highlightText = CrashRecordModel.FilterType.callStack.highlightText(filterType: filterType, filterText: filterText)
        let result = NSMutableAttributedString(attributedString: contentString(with: type, prefix: "CALL STACK", content: model.callStack, highlightText: highlightText))
        let  range = result.string.NS.range(of: model.callStack)
        if range.location != NSNotFound {
            result.setAttributes(attributes(with: type, fontSize: type.contentDetailFontSize, link: .tap), range: range)
        }
        return result
    }
}
