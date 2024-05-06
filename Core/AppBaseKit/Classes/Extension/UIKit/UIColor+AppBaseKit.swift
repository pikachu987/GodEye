//
//  UIColor+AppBaseKit.swift
//  Pods
//
//  Created by zixun on 16/9/25.
//
//

import Foundation
import UIKit

extension UIColor {
    public class var niceBlack: UIColor {
        UIColor(red: 30.0/255.0, green: 32.0/255.0, blue: 40.0/255.0, alpha: 1)
    }
    
    public class var niceDuckBlack: UIColor {
        UIColor(red: 20.0/255.0, green: 21.0/255.0, blue: 27.0/255.0, alpha: 1)
    }
    
    public class var niceRed: UIColor {
        UIColor(red: 237.0/255.0, green: 66.0/255.0, blue: 82.0/255.0, alpha: 1)
    }
    
    public class var niceJHSRed: UIColor {
        UIColor(red: 235.0/255.0, green: 0.0/255.0, blue: 18.0/255.0, alpha: 1)
    }

    public class var fileBrowserBackground: UIColor {
        if #available(iOS 13, *) {
            return .systemBackground
        } else {
            return .white
        }
    }

    public class var highlightBG: UIColor {
        UIColor(red: 129.0/255.0, green: 140.0/255.0, blue: 171.0/255.0, alpha: 1)
    }

    public class var highlightFG: UIColor {
        UIColor.white
    }
}

// MARK: - RGB
extension UIColor {
    public convenience init(hex: Int, alpha: CGFloat = 1.0) {
        let red: CGFloat = CGFloat((hex & 0xFF0000) >> 16) / 255.0
        let green: CGFloat = CGFloat((hex & 0x00FF00) >> 8) / 255.0
        let blue: CGFloat = CGFloat((hex & 0x0000FF)) / 255.0
        self.init(red: red, green: green, blue: blue, alpha: alpha)
    }
    
    public convenience init?(hexString: String, alpha: CGFloat = 1.0) {
        let formatted = hexString.replacingOccurrences(of: "0x", with: "")
                                 .replacingOccurrences(of:"#", with: "")
        if let hex = Int(formatted, radix: 16) {
            self.init(hex: hex, alpha: alpha)
        }
        return nil
    }
    
    public func hexString(prefix: String = "") -> String {
        let rgbFloat = rgba()
        
        let result = string(of: rgbFloat.r) + string(of: rgbFloat.g) + string(of: rgbFloat.b)
        return prefix + result.uppercased()
    }
    
    private func string(of component: Int) -> String {
        var result = String(format: "%x",  component)
        let count = result.count
        if count == 0 {
            return "00"
        } else if count == 1 {
            return "0" + result
        } else {
            return result
        }
    }
    
    
    public func hex() -> Int? {
        Int(hexString(), radix: 16)
    }
    
    public func rgba() -> (r: Int, g: Int, b: Int, a: CGFloat) {
        var r: CGFloat = 0
        var g: CGFloat = 0
        var b: CGFloat = 0
        var a: CGFloat = 0
        getRed(&r, green: &g, blue: &b, alpha: &a)
        r = r * 255
        g = g * 255
        b = b * 255
        
        return (Int(r),Int(g),Int(b),a)
    }
}

// MARK: - Gradient
extension UIColor {
    
    public class func gradient(startColor: UIColor, endColor: UIColor, fraction: CGFloat) -> UIColor {
        var startR: CGFloat = 0, startG: CGFloat = 0, startB: CGFloat = 0, startA: CGFloat = 0
        startColor.getRed(&startR, green: &startG, blue: &startB, alpha: &startA)
        
        var endR: CGFloat = 0, endG: CGFloat = 0, endB: CGFloat = 0, endA: CGFloat = 0
        endColor.getRed(&endR, green: &endG, blue: &endB, alpha: &endA)
        
        let resultA = startA + (endA - startA) * fraction
        let resultR = startR + (endR - startR) * fraction
        let resultG = startG + (endG - startG) * fraction
        let resultB = startB + (endB - startB) * fraction
        
        return UIColor(red: resultR, green: resultG, blue: resultB, alpha: resultA)
    }
}

