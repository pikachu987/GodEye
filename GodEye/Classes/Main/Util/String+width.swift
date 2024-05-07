//
//  String+width.swift
//  GodEye
//
//  Created by USER on 5/7/24.
//

import UIKit

extension String {
    func width(_ font: UIFont) -> CGFloat {
        let attributes = [NSAttributedString.Key.font: font]
        return ceil((self as NSString).size(withAttributes: attributes).width)
    }
}
