//
//  CCMathSafety.swift
//  ChillCat
//
//  Created by doudou.han on 2026/6/8.
//
//

import Foundation

func cc_safe_div_int64(_ a: Int64, _ b: Int64) -> Int64 {
    guard b != 0 else { return 1 }
    return a / b
}

func cc_safe_div_int32(_ a: Int32, _ b: Int32) -> Int32 {
    guard b != 0 else { return 1 }
    return a / b
}

func cc_safe_div_double(_ a: Double, _ b: Double) -> Double {
    guard !cc_is_double_zero(b) else { return 0 }
    return a / b
}

func cc_safe_div_float(_ a: Float, _ b: Float) -> Float {
    guard !cc_is_float_zero(b) else { return 0 }
    return a / b
}

func cc_safe_divsor_1(_ value: Float) -> Float {
    return cc_is_float_zero(value) ? 1 : value
}

func cc_safe_modulus_0(_ value: Int) -> Int {
    return value == 0 ? 0 : value
}

func cc_safe_clamp<T: Comparable>(_ value: T, min: T, max: T) -> T {
    return Swift.min(Swift.max(value, min), max)
}

func cc_float_equal(_ a: Float, _ b: Float) -> Bool {
    return abs(a - b) < Float.ulpOfOne
}

func cc_is_double_zero(_ value: Double) -> Bool {
    return abs(value) < Double.ulpOfOne
}

func cc_is_float_zero(_ value: Float) -> Bool {
    return abs(value) < Float.ulpOfOne
}
