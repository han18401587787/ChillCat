//
//  CCTypeSafety.swift
//  ChillCat
//
//  Created by doudou.han on 2026/6/8.
//
//

import Foundation

func cc_safe_cast<T>(_ object: Any?, _ type: T.Type) -> T? {
    guard let object = object else { return nil }
    return object as? T
}

func cc_safe_castDict(_ object: Any?) -> [String: Any]? {
    return cc_safe_cast(object, [String: Any].self)
}

func cc_string_not_nil(_ string: String?) -> String {
    return string ?? ""
}

func cc_safe_check(_ object: Any?, _ type: AnyClass) -> Bool {
    guard let object = object else { return false }
    return (object as AnyObject).isKind(of: type)
}

func cc_safe_checkSel(_ object: AnyObject?, _ sel: Selector) -> Bool {
    guard let object = object else { return false }
    return object.responds(to: sel)
}

func cc_main_async_safe(_ block: @escaping () -> Void) {
    if Thread.isMainThread {
        block()
    } else {
        DispatchQueue.main.async(execute: block)
    }
}

func STRINGHASVALUE(_ str: String?) -> Bool {
    guard let str = str, !str.isEmpty else { return false }
    return true
}

func DICTIONARYHASVALUE(_ dict: [String: Any]?) -> Bool {
    guard let dict = dict, !dict.isEmpty else { return false }
    return true
}

func ARRAYHASVALUE(_ array: [Any]?) -> Bool {
    guard let array = array, !array.isEmpty else { return false }
    return true
}
