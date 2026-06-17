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
        VStack(spacing: AppSpacing.md) {
            Image(systemName: imageName)
                .font(.system(size: 48))
                .foregroundColor(AppTheme.textMuted)

            Text(title)
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(AppTheme.textPrimary)

            Text(message)
                .font(.system(size: 15))
                .foregroundColor(AppTheme.textSecondary)
                .multilineTextAlignment(.center)

            if let actionTitle = actionTitle, let action = action {
                Button(actionTitle) {
                    Task { await action() }
                }
                .buttonStyle(.bordered)
                .tint(AppTheme.primary)
                .padding(.top, AppSpacing.sm)
            }
        }
        .padding(AppSpacing.lg)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(AppTheme.background)
    }
}
