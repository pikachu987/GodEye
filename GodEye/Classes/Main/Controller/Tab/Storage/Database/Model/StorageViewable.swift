//
//  StorageViewable.swift
//  GodEye
//
//  Created by USER on 5/7/24.
//

import Foundation

private enum ViewerConstant {
    static let font = UIFont.courier(with: 13)
    static let horizontalMargin: CGFloat = 4
}

protocol StorageViewable {
    var title: String { get }
    var columnList: [String] { get }
    var standardRowList: [String] { get }
    var rowList: [[String]] { get }
}

extension StorageViewable {
    var columnModel: StorageRowModel {
        get {
            guard let result = objc_getAssociatedObject(self, &columnModelKey) as? StorageRowModel else {
                let result = StorageRowModel(values: columnList,
                                widths: columnWidths,
                                font: ViewerConstant.font,
                                horizontalMargin: ViewerConstant.horizontalMargin,
                                isColumn: true)
                objc_setAssociatedObject(self, &columnModelKey, result, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
                return result
            }
            return result
        }
        set {
            objc_setAssociatedObject(self, &columnModelKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }

    var rowModels: [StorageRowModel] {
        get {
            guard let result = objc_getAssociatedObject(self, &rowModelsKey) as? [StorageRowModel] else {
                let result = rowList.map {
                    StorageRowModel(values: $0,
                                    widths: columnWidths,
                                    font: ViewerConstant.font,
                                    horizontalMargin: ViewerConstant.horizontalMargin,
                                    isColumn: false)
                }
                objc_setAssociatedObject(self, &rowModelsKey, result, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
                return result
            }
            return result
        }
        set {
            objc_setAssociatedObject(self, &rowModelsKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }

    var rowCount: Int {
        rowModels.count
    }

    var fullWidth: CGFloat {
        columnWidths.reduce(0, +) + (CGFloat(columnWidths.count) * (ViewerConstant.horizontalMargin * 2))
    }

    mutating func toggleTap(index: Int) {
        rowModels[index].isFull = !rowModels[index].isFull
    }
}

extension StorageViewable {
    private var columnWidths: [CGFloat] {
        var key = "\(#file)+\(#line)"
        guard let result = objc_getAssociatedObject(self, &key) as? [CGFloat] else {
            var widths = [CGFloat]()
            for (index, column) in columnList.enumerated() {
                let rowField: String
                if standardRowList.indices ~= index {
                    rowField = standardRowList[index]
                } else {
                    rowField = ""
                }
                let columnWidth = column.width(ViewerConstant.font)
                let rowWidth = rowField.width(ViewerConstant.font)
                let max = max(columnWidth, rowWidth) + 16
                widths.append(min(max, 300))
            }
            return widths
        }
        return result
    }
}

private var rowModelsKey: UInt8 = 0
private var columnModelKey: UInt8 = 0
