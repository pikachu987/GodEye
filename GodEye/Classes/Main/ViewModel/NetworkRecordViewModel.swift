//
//  NetworkRecordViewModel.swift
//  Pods
//
//  Created by zixun on 16/12/29.
//
//

import Foundation

class NetworkRecordViewModel: BaseRecordViewModel<NetworkRecordModel> {
    init(_ model: NetworkRecordModel) {
        super.init(model: model)
    }

    override func attributeString(type: RecordORMAttributedType, filterType: RecordORMFilterType?, filterText: String?) -> NSAttributedString {
        let result = NSMutableAttributedString()
        result.append(headerString(type: type))
        if type == .preview {
            result.append(moreLinkString(with: model.isAllShow ? "Click cell to preview" : "Click cell to show all"))
        }
        result.append(requestURLString(type: type, filterType: filterType, filterText: filterText))

        if (type == .preview && model.isAllShow) || type == .detail {
            result.append(requestCachePolicyString(type: type))
            result.append(requestTimeoutIntervalString(type: type))
            result.append(requestHTTPMethodString(type: type, filterType: filterType, filterText: filterText))
            result.append(requestAllHTTPHeaderFieldsString(type: type))
            result.append(requestHTTPBodyString(type: type, filterType: filterType, filterText: filterText))
            result.append(responseMIMETypeString(type: type))
            result.append(responseExpectedContentLengthString(type: type))
            result.append(responseTextEncodingNameString(type: type))
            result.append(responseSuggestedFilenameString(type: type))
            result.append(responseStatusCodeString(type: type))
            result.append(responseAllHeaderFieldsString(type: type))
            result.append(receiveJSONDataString(type: type, filterType: filterType, filterText: filterText))
        }
        return result
    }
    
    private func headerString(type: RecordORMAttributedType) -> NSAttributedString {
        headerString(with: type, prefix: "NETWORK", color: UIColor(hex: 0xDF1921))
    }
    
    private func requestURLString(type: RecordORMAttributedType, filterType: RecordORMFilterType?, filterText: String?) -> NSAttributedString {
        let highlightText = NetworkRecordModel.FilterType.url.highlightText(filterType: filterType, filterText: filterText)
        return contentString(with: type, prefix: "requestURL", content: model.requestURLString, highlightText: highlightText)
    }
    
    private func requestCachePolicyString(type: RecordORMAttributedType) -> NSAttributedString {
        contentString(with: type, prefix: "requestCachePolicy", content: model.requestCachePolicy)
    }
    
    private func requestTimeoutIntervalString(type: RecordORMAttributedType) -> NSAttributedString {
        contentString(with: type, prefix: "requestTimeoutInterval", content: model.requestTimeoutInterval)
    }
    
    private func requestHTTPMethodString(type: RecordORMAttributedType, filterType: RecordORMFilterType?, filterText: String?) -> NSAttributedString {
        let highlightText = NetworkRecordModel.FilterType.method.highlightText(filterType: filterType, filterText: filterText)
        return contentString(with: type, prefix: "requestHTTPMethod", content: model.requestHTTPMethod, highlightText: highlightText)
    }
    
    private func requestAllHTTPHeaderFieldsString(type: RecordORMAttributedType) -> NSAttributedString {
        contentString(with: type, prefix: "requestAllHTTPHeaderFields", content: model.requestAllHTTPHeaderFields)
    }
    
    private func requestHTTPBodyString(type: RecordORMAttributedType, filterType: RecordORMFilterType?, filterText: String?) -> NSAttributedString {
        let highlightText = NetworkRecordModel.FilterType.reqBody.highlightText(filterType: filterType, filterText: filterText)
        return contentString(with: type, prefix: "requestHTTPBody", content: model.requestHTTPBody, highlightText: highlightText)
    }
    
    private func responseMIMETypeString(type: RecordORMAttributedType) -> NSAttributedString {
        contentString(with: type, prefix: "responseMIMEType", content: model.responseMIMEType)
    }
    
    private func responseExpectedContentLengthString(type: RecordORMAttributedType) -> NSAttributedString {
        contentString(with: type, prefix: "responseExpectedContentLength", content: "\((model.responseExpectedContentLength ?? 0) / 1024)KB")
    }
    
    private func responseTextEncodingNameString(type: RecordORMAttributedType) -> NSAttributedString {
        contentString(with: type, prefix: "responseTextEncodingName", content: model.responseTextEncodingName)
    }
    
    private func responseSuggestedFilenameString(type: RecordORMAttributedType) -> NSAttributedString {
        contentString(with: type, prefix: "responseSuggestedFilename", content: model.responseSuggestedFilename)
    }
    
    private func responseStatusCodeString(type: RecordORMAttributedType) -> NSAttributedString {
        let status = "\(model.responseStatusCode ?? 200)"
        let str = contentString(with: type, prefix: "responseStatusCode", content: status)
        let result = NSMutableAttributedString(attributedString: str)
        let  range = result.string.NS.range(of: status)
        if range.location != NSNotFound {
            let color = status == "200" ? UIColor(hex: 0x1CC221) : UIColor(hex: 0xF5261C)
            result.addAttribute(.foregroundColor, value: color, range: range)
        }
        return result
    }
    
    private func responseAllHeaderFieldsString(type: RecordORMAttributedType) -> NSAttributedString {
        let str = contentString(with: type, prefix: "responseAllHeaderFields", content: model.responseAllHeaderFields, newline: true)
        let result = NSMutableAttributedString(attributedString: str)
        
        guard let responseAllHeaderFields = model.responseAllHeaderFields else { return result }

        let range = result.string.NS.range(of: responseAllHeaderFields)
        if range.location != NSNotFound {
            result.addAttribute(.font, value: UIFont.courier(with: type.contentDetailFontSize), range: range)
        }
        return result
    }
    
    private func receiveJSONDataString(type: RecordORMAttributedType, filterType: RecordORMFilterType?, filterText: String?) -> NSAttributedString {
        guard let transString: String = {
            if type == .detail, let pretty = replacePretty(string: $0) { return pretty }
            return $0
        }(replaceUnicode(string: model.receiveJSONData)) else { return .init() }
        guard let responseMIMEType = model.responseMIMEType else { return .init() }

        let highlightText = NetworkRecordModel.FilterType.result.highlightText(filterType: filterType, filterText: filterText)
        var header = "responseJSON"
        if responseMIMEType == "application/xml"
            || responseMIMEType == "text/xml"
            || responseMIMEType == "text/plain"  {
            header = "responseXML"
        }
        var result = NSMutableAttributedString(attributedString: contentString(with: type, prefix: header, content: transString, newline: true, highlightText: highlightText))
        let range = result.string.NS.range(of: transString)
        if range.location != NSNotFound {
            result.addAttribute(.font, value: UIFont.courier(with: type.contentDetailFontSize), range: range)
        }
        return result
    }
    
    private func replaceUnicode(string: String?) -> String? {
        guard let string = string else { return nil }

        var result = string.replacingOccurrences(of: "\\u", with: "\\U").replacingOccurrences(of: "\"", with: "\\\"")
        result = "\"" + result + "\""

        if let data = result.data(using: String.Encoding.utf8) {
            do {
                result = (try PropertyListSerialization.propertyList(from: data, options: PropertyListSerialization.ReadOptions.mutableContainers, format: nil)) as? String ?? ""
                result = result.replacingOccurrences(of: "\\r\\n", with: "\n")
                return result
            } catch  {
                return nil
            }
        }
        return nil
    }

    private func replacePretty(string: String?) -> String? {
        guard let jsonData = string?.data(using: .utf8),
            let jsonObject = try? JSONSerialization.jsonObject(with: jsonData),
            let prettyJsonData = try? JSONSerialization.data(withJSONObject: jsonObject, options: .prettyPrinted),
           let prettyText = String(data: prettyJsonData, encoding: .utf8) else {
            return nil
        }
        return prettyText
    }
}
