//
//  CCMemberPrivilege.swift
//  ChillCat
//
//  Created by doudou.han on 2026/6/8.
//
//

import Foundation

struct CCMemberPrivilege: Identifiable, Codable {
    let id: String
    let title: String
    let description: String
    let iconName: String
    let isHighlight: Bool
    let availableTypes: [CCMemberType]
}
