//
//  CCOrderTrackingViewModel.swift
//  ChillCat
//
//  Created by doudou.han on 2026/6/8.
//

import Foundation
import Observation
import SwiftUI

@MainActor
@Observable
final class CCOrderTrackingViewModel {
    var transactions: [CCTransaction] = []

    private let storageKey = "cc_transaction_history"

    init() {
        load()
    }

    func addTransaction(_ transaction: CCTransaction) {
        transactions.insert(transaction, at: 0)
        save()
    }

    func updateTransaction(id: String, status: CCTransactionStatus) {
        guard let index = transactions.firstIndex(where: { $0.id == id }) else { return }
        var updated = transactions[index]
        updated = CCTransaction(
            id: updated.id,
            productType: updated.productType,
            amount: updated.amount,
            purchaseDate: updated.purchaseDate,
            status: status,
            receiptURL: updated.receiptURL
        )
        transactions[index] = updated
        save()
    }

    func load() {
        guard let data = UserDefaults.standard.data(forKey: storageKey),
              let decoded = try? JSONDecoder().decode([CCTransaction].self, from: data)
        else {
            transactions = []
            return
        }
        transactions = decoded
    }

    private func save() {
        guard let data = try? JSONEncoder().encode(transactions) else { return }
        UserDefaults.standard.set(data, forKey: storageKey)
    }
}
