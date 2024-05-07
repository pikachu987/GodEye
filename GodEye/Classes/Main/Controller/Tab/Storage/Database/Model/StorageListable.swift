//
//  StorageListable.swift
//  GodEye
//
//  Created by USER on 5/7/24.
//

import Foundation

protocol StorageListable {
    var count: Int { get }
    var indices: Range<Int> { get }
    var headerName: String? { get }
    func displayText(index: Int) -> String
    func viewer(index: Int) -> StorageViewable
}
