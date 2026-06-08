//
//  CCUserRepositoryProtocol.swift
//  ChillCat
//
//  Created by doudou.han on 2026/6/8.
//
//

import Foundation

protocol CCUserRepositoryProtocol {
    func login(username: String, password: String) async throws -> CCUser
    func register(username: String, password: String, email: String) async throws -> CCUser
    func fetchProfile() async throws -> CCUser
    func updateProfile(_ user: CCUser) async throws -> CCUser
    func logout() async
}
