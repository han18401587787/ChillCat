//
//  CCMessageViewModel.swift
//  ChillCat
//

import Foundation
import SwiftUI

@MainActor
@Observable
final class CCMessageViewModel {
    var messages: [CCMessage] = []
    var unreadCount: Int64 = 0
    var isLoading = false
    var errorMessage: String?

    private let useCase: CCFetchMessagesUseCase

    init(useCase: CCFetchMessagesUseCase) { self.useCase = useCase }

    func load() async {
        isLoading = true; errorMessage = nil
        do {
            let r = try await useCase.fetchMessages(page: 1, pageSize: 20)
            messages = r.items
            unreadCount = try await useCase.fetchUnreadCount()
        } catch { errorMessage = error.localizedDescription }
        isLoading = false
    }

    func markRead(_ message: CCMessage) async {
        guard !message.isRead else { return }
        try? await useCase.markRead(id: message.id)
        if let idx = messages.firstIndex(where: { $0.id == message.id }) {
            messages[idx] = CCMessage(id: message.id, title: message.title, content: message.content, msgType: message.msgType, isRead: true, createdAt: message.createdAt)
        }
        unreadCount = max(0, unreadCount - 1)
    }
}
