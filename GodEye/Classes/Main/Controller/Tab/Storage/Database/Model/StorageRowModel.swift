//
//  StorageRowModel.swift
//  GodEye
//
//  Created by USER on 5/7/24.
//

import Foundation

struct StorageRowModel {
    let values: [String]
    let widths: [CGFloat]
    let font: UIFont
    let horizontalMargin: CGFloat
    let isColumn: Bool
    let filterIndex: Int
    let filterText: String

    var isFull: Bool = false
}