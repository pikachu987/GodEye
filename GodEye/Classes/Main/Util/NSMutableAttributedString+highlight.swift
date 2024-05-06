//
//  Double+.swift
//  Pods
//
//  Created by zixun on 17/1/14.
//
//

import Foundation

extension NSMutableAttributedString {
    func highlight(highlightText: String?, highlightBGColor: UIColor = .highlightBG, highlightFGColor: UIColor = .highlightFG) {
        highlightText.map {
            let highlightText = $0.lowercased()
            let text = (string.lowercased() as NSString)
            let textLength = text.length
            let highlightLength = highlightText.count
            var range = NSRange(location: 0, length: textLength)
            while (range.location != NSNotFound) {
                range = text.range(of: highlightText, options: [], range: range)
                if (range.location != NSNotFound) {
                    addAttribute(.backgroundColor, value: highlightBGColor, range: NSRange(location: range.location, length: highlightLength))
                    addAttribute(.foregroundColor, value: highlightFGColor, range: NSRange(location: range.location, length: highlightLength))
                    range = NSRange(location: range.location + range.length, length: textLength - (range.location + range.length))
                }
            }
        }
    }
}
