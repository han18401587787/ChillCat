//
//  UIColor+CCExtension.swift
//  ChillCat
//
//  Created by doudou.han on 2026/6/8.
//
//

import UIKit

extension UIColor {
    convenience init(cc_hex: UInt64, alpha: CGFloat = 1.0) {
        let r = CGFloat((cc_hex >> 16) & 0xFF) / 255.0
        let g = CGFloat((cc_hex >> 8) & 0xFF) / 255.0
        let b = CGFloat(cc_hex & 0xFF) / 255.0
        self.init(red: r, green: g, blue: b, alpha: alpha)
    }
}

func cc_is_sameColor(_ color1: UIColor, _ color2: UIColor) -> Bool {
    var r1: CGFloat = 0, g1: CGFloat = 0, b1: CGFloat = 0, a1: CGFloat = 0
    var r2: CGFloat = 0, g2: CGFloat = 0, b2: CGFloat = 0, a2: CGFloat = 0
    color1.getRed(&r1, green: &g1, blue: &b1, alpha: &a1)
    color2.getRed(&r2, green: &g2, blue: &b2, alpha: &a2)
    return cc_float_equal(Float(r1), Float(r2)) &&
           cc_float_equal(Float(g1), Float(g2)) &&
           cc_float_equal(Float(b1), Float(b2))
}
