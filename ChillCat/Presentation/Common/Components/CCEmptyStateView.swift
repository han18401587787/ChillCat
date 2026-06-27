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
        VStack(spacing: XuanSpacing.md) {
            Image(systemName: imageName)
                .font(.system(size: 48))
                .foregroundColor(Color.xuanTextTertiary)

            Text(title)
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(Color.xuanTextPrimary)

            Text(message)
                .font(.system(size: 15))
                .foregroundColor(Color.xuanTextSecondary)
                .multilineTextAlignment(.center)

            if let actionTitle = actionTitle, let action = action {
                Button(actionTitle) {
                    Task { await action() }
                }
                .buttonStyle(.bordered)
                .tint(Color.xuanApricot)
                .padding(.top, XuanSpacing.sm)
            }
        }
        .padding(XuanSpacing.lg)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.xuanApricotBg)
    }
}
