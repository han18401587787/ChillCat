//
//  CCEmptyStateView.swift
//  ChillCat
//
//  Created by doudou.han on 2026/6/8.
//
//

import SwiftUI

struct CCEmptyStateView: View {
    let title: String
    let message: String
    let imageName: String
    let actionTitle: String?
    let action: (() async -> Void)?

    init(
        title: String,
        message: String,
        imageName: String = "tray",
        actionTitle: String? = nil,
        action: (() async -> Void)? = nil
    ) {
        self.title = title
        self.message = message
        self.imageName = imageName
        self.actionTitle = actionTitle
        self.action = action
    }

    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: imageName)
                .font(.system(size: 48))
                .foregroundColor(.secondary)

            Text(title)
                .font(.title3)
                .fontWeight(.semibold)

            Text(message)
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)

            if let actionTitle = actionTitle, let action = action {
                Button(actionTitle) {
                    Task { await action() }
                }
                .buttonStyle(.bordered)
                .padding(.top, 8)
            }
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.systemBackground))
    }
}
