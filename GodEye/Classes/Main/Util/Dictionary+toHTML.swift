//
//  Double+.swift
//  Pods
//
//  Created by zixun on 17/1/14.
//
//

import Foundation

extension [String: Any] {
    var toHTML: String {
        "<pre>\(anyToString.data?.replacePretty ?? "")</pre>"
    }

    fileprivate var data: Data? {
        try? JSONSerialization.data(withJSONObject: self)
    }

    fileprivate var anyToString: [String: Any] {
        var dict = [String: Any]()
        forEach { key, value in
            if let value = value as? [String: Any] {
                dict.updateValue(value.anyToString, forKey: key)
            } else if let value = value as? [Any] {
                dict.updateValue(value.anyToString, forKey: key)
            } else if let value = value as? Bool {
                dict.updateValue(value.toString, forKey: key)
            } else {
                dict.updateValue("\(value)", forKey: key)
            }
        }
        return dict
    }
}

extension [Any] {
    fileprivate var anyToString: [Any] {
        var array = [Any]()
        forEach { value in
            if let value = value as? [String: Any] {
                array.append(value.anyToString)
            } else if let value = value as? [Any] {
                array.append(value.anyToString)
            } else if let value = value as? Bool {
                array.append(value.toString)
            } else {
                array.append("\(value)")
            }
        }
        return array
    }
}

extension Bool {
    fileprivate var toString: String {
        self ? "true" : "false"
    }
}
