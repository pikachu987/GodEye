//
//  ANRRecordViewModel.swift
//  Pods
//
//  Created by zixun on 16/12/30.
//
//

import Foundation

class ANRRecordViewModel: BaseRecordViewModel<ANRRecordModel> {
    init(_ model: ANRRecordModel) {
        super.init(model: model)
    }

    override func attributeString(type: RecordORMAttributedType, filterType: RecordORMFilterType?, filterText: String?) -> NSAttributedString {
        let result = NSMutableAttributedString()
        result.append(headerString(type: type))

        if type == .preview {
            result.append(moreLinkString(with: model.isAllShow ? "Click cell to preview" : "Click cell to show all"))
        }
        result.append(mainThreadBacktraceString(type: type, filterType: filterType, filterText: filterText))

        if (type == .preview && model.isAllShow) || type == .detail {
            result.append(allThreadBacktraceString(type: type, filterType: filterType, filterText: filterText))
        }
        return result
    }
    
    private func headerString(type: RecordORMAttributedType) -> NSAttributedString {
        let content = "main thread not response with threshold:\(model.threshold)"
        return headerString(with: type, prefix: "ANR", content: content, color: UIColor(hex: 0xFF0000))
    }

    private func mainThreadBacktraceString(type: RecordORMAttributedType, filterType: RecordORMFilterType?, filterText: String?) -> NSAttributedString {
        guard let mainThreadBacktrace = model.mainThreadBacktrace else { return .init() }
        let highlightText = ANRRecordModel.FilterType.mainThreadBacktrace.highlightText(filterType: filterType, filterText: filterText)
        let result = NSMutableAttributedString(attributedString: contentString(with: type, prefix: "MainThread Backtrace", content: model.mainThreadBacktrace, newline: true, highlightText: highlightText))
        let range = result.string.NS.range(of: mainThreadBacktrace)
        if range.location != NSNotFound {
            result.setAttributes(attributes(with: type, fontSize: type.contentDetailFontSize, link: .tap), range: range)
        }
        return result
    }
    
    private func allThreadBacktraceString(type: RecordORMAttributedType, filterType: RecordORMFilterType?, filterText: String?) -> NSAttributedString {
        guard let allThreadBacktrace = model.allThreadBacktrace else { return .init() }
        let highlightText = ANRRecordModel.FilterType.allThreadBacktrace .highlightText(filterType: filterType, filterText: filterText)
        let result = NSMutableAttributedString(attributedString: contentString(with: type, prefix: "AllThread Backtrace", content: model.allThreadBacktrace, newline: true, highlightText: highlightText))
        let  range = result.string.NS.range(of: allThreadBacktrace)
        if range.location != NSNotFound {
            result.setAttributes(attributes(with: type, fontSize: type.contentDetailFontSize, link: .tap), range: range)
        }
        return result
    }
}
