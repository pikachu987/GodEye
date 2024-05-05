//
//  NetworkRecordModel+ORM.swift
//  Pods
//
//  Created by zixun on 17/1/9.
//
//

import Foundation
import SQLite

extension NetworkRecordModel: RecordORMProtocol {
    static var type: RecordType { .network }
    
    static var filterTypes: [RecordORMFilterType] {
        [.init(title: "all", value: nil)] +
        FilterType.allCases
            .map { .init(title: $0.title, value: "\($0.value)") }
    }

    static func mappingToObject(with row: Row) -> NetworkRecordModel {
        NetworkRecordModel(requestURLString: row[Col.requestURLString],
                          requestCachePolicy: row[Col.requestCachePolicy],
                          requestTimeoutInterval: row[Col.requestTimeoutInterval],
                          requestHTTPMethod: row[Col.requestHTTPMethod],
                          requestAllHTTPHeaderFields: row[Col.requestAllHTTPHeaderFields],
                          requestHTTPBody: row[Col.requestHTTPBody],
                          responseMIMEType: row[Col.responseMIMEType],
                          responseExpectedContentLength: row[Col.responseExpectedContentLength],
                          responseTextEncodingName: row[Col.responseTextEncodingName],
                          responseSuggestedFilename: row[Col.responseSuggestedFilename],
                          responseStatusCode: row[Col.responseStatusCode],
                          responseAllHeaderFields: row[Col.responseAllHeaderFields],
                          receiveJSONData: row[Col.receiveJSONData])
    }

    static func configure(tableBuilder: TableBuilder) {
        tableBuilder.column(Col.requestURLString)
        tableBuilder.column(Col.requestCachePolicy)
        tableBuilder.column(Col.requestTimeoutInterval)
        tableBuilder.column(Col.requestHTTPMethod)
        tableBuilder.column(Col.requestAllHTTPHeaderFields)
        tableBuilder.column(Col.requestHTTPBody)

        tableBuilder.column(Col.responseMIMEType)
        tableBuilder.column(Col.responseExpectedContentLength)
        tableBuilder.column(Col.responseTextEncodingName)
        tableBuilder.column(Col.responseSuggestedFilename)
        tableBuilder.column(Col.responseStatusCode)
        tableBuilder.column(Col.responseAllHeaderFields)
        tableBuilder.column(Col.receiveJSONData)
    }
    
    static func configure(select table: Table, filterType: RecordORMFilterType, filterText: String) -> Table {
        let table = table.select(Col.requestURLString,
                                 Col.requestCachePolicy,
                                 Col.requestTimeoutInterval,
                                 Col.requestHTTPMethod,
                                 Col.requestAllHTTPHeaderFields,
                                 Col.requestHTTPBody,
                                 Col.responseMIMEType,
                                 Col.responseExpectedContentLength,
                                 Col.responseTextEncodingName,
                                 Col.responseSuggestedFilename,
                                 Col.responseStatusCode,
                                 Col.responseAllHeaderFields,
                                 Col.receiveJSONData)
        guard !filterText.isEmpty else { return table }
        if let value = filterType.value {
            return table.filter(Expression<String>(value).like("%\(filterText)%"))
        } else {
            return table.filter(Col.requestURLString.like("%\(filterText)%") ||
                                Col.requestHTTPMethod.like("%\(filterText)%") ||
                                Col.requestHTTPBody.like("%\(filterText)%") ||
                                Col.receiveJSONData.like("%\(filterText)%"))
        }
    }

    func mappingToRelation() -> [Setter] {
        [Col.requestURLString <- requestURLString,
         Col.requestCachePolicy <- requestCachePolicy,
         Col.requestTimeoutInterval <- requestTimeoutInterval,
         Col.requestHTTPMethod <- requestHTTPMethod,
         Col.requestAllHTTPHeaderFields <- requestAllHTTPHeaderFields,

         Col.requestHTTPBody <- requestHTTPBody,
         Col.responseMIMEType <- responseMIMEType,
         Col.responseExpectedContentLength <- responseExpectedContentLength,
         Col.responseTextEncodingName <- responseTextEncodingName,
         Col.responseSuggestedFilename <- responseSuggestedFilename,
         Col.responseStatusCode <- responseStatusCode,
         Col.responseAllHeaderFields <- responseAllHeaderFields,
         Col.receiveJSONData <- receiveJSONData]
    }

    func attributeString(type: RecordORMAttributedType, filterType: RecordORMFilterType?, filterText: String?) -> NSAttributedString {
        NetworkRecordViewModel(self).attributeString(type: type, filterType: filterType, filterText: filterText)
    }

    class Col: NSObject {
        /// request col
        static let requestURLString = Expression<String?>("requestURLString")
        static let requestCachePolicy = Expression<String?>("requestCachePolicy")
        static let requestTimeoutInterval = Expression<String?>("requestTimeoutInterval")
        static let requestHTTPMethod = Expression<String?>("requestHTTPMethod")
        static let requestAllHTTPHeaderFields = Expression<String?>("requestAllHTTPHeaderFields")
        static let requestHTTPBody = Expression<String?>("requestHTTPBody")
        
        /// response col
        static let responseMIMEType = Expression<String?>("responseMIMEType")
        static let responseExpectedContentLength = Expression<Int64>("responseExpectedContentLength")
        static let responseTextEncodingName = Expression<String?>("responseTextEncodingName")
        static let responseSuggestedFilename = Expression<String?>("responseSuggestedFilename")
        static let responseStatusCode = Expression<Int>("responseStatusCode")
        static let responseAllHeaderFields = Expression<String?>("responseAllHeaderFields")
        static let receiveJSONData = Expression<String?>("receiveJSONData")
    }

    enum FilterType: FilterTypeable {
        case url
        case method
        case reqBody
        case result

        var title: String {
            switch self {
            case .url: return "url"
            case .method: return "method"
            case .reqBody: return "reqBody"
            case .result: return "result"
            }
        }

        var value: String {
            switch self {
            case .url: return "requestURLString"
            case .method: return "requestHTTPMethod"
            case .reqBody: return "requestHTTPBody"
            case .result: return "receiveJSONData"
            }
        }

        func equal(filterType: RecordORMFilterType?) -> Bool {
            filterType?.title == title && filterType?.value == value
        }
    }
}
