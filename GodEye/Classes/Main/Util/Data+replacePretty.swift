//
//  Double+.swift
//  Pods
//
//  Created by zixun on 17/1/14.
//
//

import Foundation

extension Data {
    var replacePretty: String? {
        guard let jsonObject = try? JSONSerialization.jsonObject(with: self),
            let prettyJsonData = try? JSONSerialization.data(withJSONObject: jsonObject, options: .prettyPrinted),
           let prettyText = String(data: prettyJsonData, encoding: .utf8) else {
            return nil
        }
        return prettyText
    }
}
