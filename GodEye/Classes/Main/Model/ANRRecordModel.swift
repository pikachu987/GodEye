//
//  ANRModel.swift
//  Pods
//
//  Created by zixun on 16/12/30.
//
//

import Foundation

final class ANRRecordModel: NSObject {
    let threshold: Double
    let mainThreadBacktrace: String?
    let allThreadBacktrace: String?

    init(threshold: Double, mainThreadBacktrace: String?, allThreadBacktrace: String?) {
        self.threshold = threshold
        self.mainThreadBacktrace = mainThreadBacktrace
        self.allThreadBacktrace = allThreadBacktrace
        super.init()
        self.isAllShow = false
    }
}
