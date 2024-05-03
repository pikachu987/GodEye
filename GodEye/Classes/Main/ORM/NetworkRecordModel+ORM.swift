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

    func mappingToRelation() -> [Setter] {
        [NetworkRecordModel.col.requestURLString <- requestURLString,
        NetworkRecordModel.col.requestCachePolicy <- requestCachePolicy,
        NetworkRecordModel.col.requestTimeoutInterval <- requestTimeoutInterval,
        NetworkRecordModel.col.requestHTTPMethod <- requestHTTPMethod,
        NetworkRecordModel.col.requestAllHTTPHeaderFields <- requestAllHTTPHeaderFields,

        NetworkRecordModel.col.requestHTTPBody <- requestHTTPBody,
        NetworkRecordModel.col.responseMIMEType <- responseMIMEType,
        NetworkRecordModel.col.responseExpectedContentLength <- responseExpectedContentLength,
        NetworkRecordModel.col.responseTextEncodingName <- responseTextEncodingName,
        NetworkRecordModel.col.responseSuggestedFilename <- responseSuggestedFilename,
        NetworkRecordModel.col.responseStatusCode <- responseStatusCode,
        NetworkRecordModel.col.responseAllHeaderFields <- responseAllHeaderFields,
        NetworkRecordModel.col.receiveJSONData <- receiveJSONData]
    }
    
    static func mappingToObject(with row: Row) -> NetworkRecordModel {
        NetworkRecordModel(requestURLString: row[NetworkRecordModel.col.requestURLString],
                          requestCachePolicy: row[NetworkRecordModel.col.requestCachePolicy],
                          requestTimeoutInterval: row[NetworkRecordModel.col.requestTimeoutInterval],
                          requestHTTPMethod: row[NetworkRecordModel.col.requestHTTPMethod],
                          requestAllHTTPHeaderFields: row[NetworkRecordModel.col.requestAllHTTPHeaderFields],
                          requestHTTPBody: row[NetworkRecordModel.col.requestHTTPBody],
                          responseMIMEType: row[NetworkRecordModel.col.responseMIMEType],
                          responseExpectedContentLength: row[NetworkRecordModel.col.responseExpectedContentLength],
                          responseTextEncodingName: row[NetworkRecordModel.col.responseTextEncodingName],
                          responseSuggestedFilename: row[NetworkRecordModel.col.responseSuggestedFilename],
                          responseStatusCode: row[NetworkRecordModel.col.responseStatusCode],
                          responseAllHeaderFields: row[NetworkRecordModel.col.responseAllHeaderFields],
                          receiveJSONData: row[NetworkRecordModel.col.receiveJSONData])
    }

    static func configure(tableBuilder: TableBuilder) {
        tableBuilder.column(NetworkRecordModel.col.requestURLString)
        tableBuilder.column(NetworkRecordModel.col.requestCachePolicy)
        tableBuilder.column(NetworkRecordModel.col.requestTimeoutInterval)
        tableBuilder.column(NetworkRecordModel.col.requestHTTPMethod)
        tableBuilder.column(NetworkRecordModel.col.requestAllHTTPHeaderFields)
        tableBuilder.column(NetworkRecordModel.col.requestHTTPBody)
        
        tableBuilder.column(NetworkRecordModel.col.responseMIMEType)
        tableBuilder.column(NetworkRecordModel.col.responseExpectedContentLength)
        tableBuilder.column(NetworkRecordModel.col.responseTextEncodingName)
        tableBuilder.column(NetworkRecordModel.col.responseSuggestedFilename)
        tableBuilder.column(NetworkRecordModel.col.responseStatusCode)
        tableBuilder.column(NetworkRecordModel.col.responseAllHeaderFields)
        tableBuilder.column(NetworkRecordModel.col.receiveJSONData)
    }
    
    static func configure(select table: Table) -> Table {
        table.select(NetworkRecordModel.col.requestURLString,
                    NetworkRecordModel.col.requestCachePolicy,
                    NetworkRecordModel.col.requestTimeoutInterval,
                    NetworkRecordModel.col.requestHTTPMethod,
                    NetworkRecordModel.col.requestAllHTTPHeaderFields,
                    NetworkRecordModel.col.requestHTTPBody,
                    NetworkRecordModel.col.responseMIMEType,
                    NetworkRecordModel.col.responseExpectedContentLength,
                    NetworkRecordModel.col.responseTextEncodingName,
                    NetworkRecordModel.col.responseSuggestedFilename,
                    NetworkRecordModel.col.responseStatusCode,
                    NetworkRecordModel.col.responseAllHeaderFields,
                    NetworkRecordModel.col.receiveJSONData)
    }
    
    func attributeString(type: RecordORMAttributedType) -> NSAttributedString {
        NetworkRecordViewModel(self).attributeString(type: type)
    }
    
    class col: NSObject {
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
}
