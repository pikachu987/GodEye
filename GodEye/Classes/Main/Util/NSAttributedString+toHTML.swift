//
//  Double+.swift
//  Pods
//
//  Created by zixun on 17/1/14.
//
//

import Foundation

extension NSAttributedString {
    var toHTML: String? {
        guard let htmlData = try? data(from: NSRange(location: 0, length: length), documentAttributes: [.documentType: NSAttributedString.DocumentType.html]),
              let htmlString = String(data: htmlData, encoding: .utf8) else { return nil }
        return htmlString
    }
}
