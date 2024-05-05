//
//  CommandRecordModel+ORM.swift
//  Pods
//
//  Created by zixun on 17/1/9.
//
//

import Foundation

protocol FilterTypeable: CaseIterable {
    func equal(filterType: RecordORMFilterType?) -> Bool
}

extension FilterTypeable {
    func isHighlight(filterType: RecordORMFilterType?, filterText: String?) -> Bool {
        let filterText = filterText ?? ""
        if filterType == nil || filterText.isEmpty {
            return false
        } else if filterType?.isAll == true {
            return true
        } else {
            return equal(filterType: filterType)
        }
    }

    func highlightText(filterType: RecordORMFilterType?, filterText: String?) -> String? {
        isHighlight(filterType: filterType, filterText: filterText) ? filterText : nil
    }
}
