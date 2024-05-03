//
//  UITableView+.swift
//  Pods
//
//  Created by zixun on 17/1/4.
//
//

import Foundation

extension UITableView {
    func dequeueReusableCell<E: UITableViewCell>(style: UITableViewCell.CellStyle = .default,
                             identifier: String = E.identifier,
                             _ bind: (E) -> Void) -> E {
        var cell = dequeueReusableCell(withIdentifier: identifier) as? E
        if cell == nil {
            cell = E(style: style, reuseIdentifier: identifier)
            bind(cell!)
        }
        return cell!
    }
}
