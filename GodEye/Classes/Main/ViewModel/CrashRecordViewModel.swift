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
    
    override func attributeString(type: RecordORMAttributedType) -> NSAttributedString {
        let result = NSMutableAttributedString()
        result.append(headerString(type: type))
        result.append(nameString(type: type))
        result.append(reasonString(type: type))
        result.append(appinfoString(type: type))
        result.append(callStackString(type: type))
        return result
    }
    
    private func headerString(type: RecordORMAttributedType) -> NSAttributedString {
        let contentType = model.type == .exception ? "Exception" : "SIGNAL"
        return headerString(with: type, prefix: "CRASH", content: contentType, color: UIColor(hex: 0xDF1921))
    }
    
    private func nameString(type: RecordORMAttributedType) -> NSAttributedString {
        contentString(with: type, prefix: "NAME", content: model.name)
    }
    
    private func reasonString(type: RecordORMAttributedType) -> NSAttributedString {
        contentString(with: type, prefix: "REASON", content: model.reason)
    }
    
    private func appinfoString(type: RecordORMAttributedType) -> NSAttributedString {
        contentString(with: type, prefix: "APPINFO", content: model.appinfo)
    }
    
    private func callStackString(type: RecordORMAttributedType) -> NSAttributedString {
        let result = NSMutableAttributedString(attributedString: contentString(with: type, prefix: "CALL STACK", content: model.callStack))
        let  range = result.string.NS.range(of: model.callStack)
        if range.location != NSNotFound {
            result.setAttributes(attributes(with: type, fontSize: type.contentDetailFontSize, link: .tap), range: range)
        }
        return result
    }
}
