//
//  GlobalColor+ColorExtension.swift
//
//
//  Created by tianpli on 2023/9/25.
//

import Foundation
import SwiftUI

internal extension GlobalColor {
    var hex: String {
        return rawValue
    }
    
    fileprivate typealias RGBA = (red: CGFloat, green: CGFloat, blue: CGFloat, alpha: CGFloat)

    private var rgba: RGBA {
        guard let rgba = hex.parseAsRGBAColor else {
            fatalError("Native color should always parse to hex color")
        }
        return rgba
    }
    
    var color: Color {
        return Color(rgba: rgba)
    }
}

extension String {
    fileprivate var parseAsRGBAColor: GlobalColor.RGBA? {
        let hex = self.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a: UInt64?
        let r: UInt64
        let g: UInt64
        let b: UInt64
        switch hex.count {
        case 3:  // RGB (12-bit)
            (r, g, b, a) = ((int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17, nil)
        case 6:  // RGB (24-bit)
            (r, g, b, a) = (int >> 16, int >> 8 & 0xFF, int & 0xFF, nil)
        case 8:  // ARGB (32-bit)
            (r, g, b, a) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            return nil
        }
        return (CGFloat(r) / 255.0, CGFloat(g) / 255.0, CGFloat(b) / 255.0, CGFloat(a ?? 255) / 255.0)
    }
}
#if canImport(UIKit)
import UIKit

extension GlobalColor {
    var uiColor: UIColor {
        return UIColor(rgba: rgba)
    }
}

extension UIColor {
    fileprivate convenience init(rgba: GlobalColor.RGBA) {
        self.init(red: rgba.red, green: rgba.green, blue: rgba.blue, alpha: rgba.alpha)
    }
}
#endif
extension Color {
    fileprivate init(rgba: GlobalColor.RGBA) {
        self.init(red: rgba.red, green: rgba.green, blue: rgba.blue, opacity: rgba.alpha)
    }
}
