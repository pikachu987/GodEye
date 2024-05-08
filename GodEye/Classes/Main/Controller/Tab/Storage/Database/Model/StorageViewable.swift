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
    var columnList: [(String, Bool?)] { set get }
    var standardRowList: [String] { get }
    var rowModels: [StorageRowModel] { set get }
    var filterList: [String] { get }
    func refresh(_ completion: @escaping (() -> Void))
    func loadMore(_ completion: @escaping (() -> Void))
}

extension StorageViewable {
    var filterType: String {
        get {
            guard let value = objc_getAssociatedObject(self, &filterTypeKey) as? String else {
                let value = ""
                objc_setAssociatedObject(self, &filterTypeKey, value, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
                return value
            }
            return value
        }
        set {
            objc_setAssociatedObject(self, &filterTypeKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }

    var filterText: String {
        get {
            guard let value = objc_getAssociatedObject(self, &filterTextKey) as? String else {
                let value = ""
                objc_setAssociatedObject(self, &filterTextKey, value, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
                return value
            }
            return value
        }
        set {
            objc_setAssociatedObject(self, &filterTextKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }

    var columnModel: StorageRowModel {
        StorageRowModel(values: columnAndArrowList,
                        widths: columnWidths,
                        font: ViewerConstant.font,
                        horizontalMargin: ViewerConstant.horizontalMargin,
                        isColumn: true,
                        filterIndex: columnList.map { $0.0 }.firstIndex(where: { $0 == filterType }) ?? 0,
                        filterText: filterText)
    }

    var rowCount: Int {
        rowModels.count
    }

    var fullWidth: CGFloat {
        columnWidths.reduce(0, +) + (CGFloat(columnWidths.count) * (ViewerConstant.horizontalMargin * 2))
    }

    var filterList: [String] {
        columnList.map { $0.0 }
    }

    mutating func toggleTap(index: Int) {
        rowModels[index].isFull = !rowModels[index].isFull
    }

    mutating func columnTap(index: Int, completion: @escaping (() -> Void)) {
        for i in 0..<columnList.count where i != index {
            columnList[i].1 = nil
        }
        if let value = columnList[index].1 {
            if !value {
                columnList[index].1 = !value
            } else {
                columnList[index].1 = nil
            }
        } else {
            columnList[index].1 = false
        }
        refresh {
            completion()
        }
    }

    mutating func changeFilterType(_ filterType: String, completion: (() -> Void)?) {
        self.filterType = filterType
        refresh {
            completion?()
        }
    }

    mutating func changeFilterText(_ filterText: String, completion: @escaping (() -> Void)) {
        self.filterText = filterText
        refresh {
            completion()
        }
    }

    func makeRowModels(valuesList: [[String]]) -> [StorageRowModel] {
        valuesList.map {
            StorageRowModel(values: $0,
                            widths: columnWidths,
                            font: ViewerConstant.font,
                            horizontalMargin: ViewerConstant.horizontalMargin,
                            isColumn: false,
                            filterIndex: columnList.map { $0.0 }.firstIndex(where: { $0 == filterType }) ?? 0,
                            filterText: filterText)
        }
    }
}

extension StorageViewable {
    var columnAndArrowList: [String] {
        columnList.map { $0.0.appending(" \($0.1 ?? true ? "▼" : "▲")") }
    }
    var columnWidths: [CGFloat] {
        var key = "\(#file)+\(#line)"
        guard let result = objc_getAssociatedObject(self, &key) as? [CGFloat] else {
            var widths = [CGFloat]()
            for (index, column) in columnAndArrowList.enumerated() {
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

private var filterTypeKey: UInt8 = 0
private var filterTextKey: UInt8 = 0
