//
//  CCErrorView.swift
//  ChillCat
//
//  Created by doudou.han on 2026/6/8.
//
//

import SwiftUI

struct CCErrorView: View {
    let error: Error
    let retryAction: (() async -> Void)?
    @Environment(\.ccAppTheme) private var theme

    var body: some View {
        VStack(spacing: theme.spacingMD) {
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 48))
                .foregroundColor(theme.error)

            Text(error.localizedDescription)
                .font(.system(size: 15))
                .foregroundColor(theme.textSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, theme.spacingXL)

            if let retryAction = retryAction {
                Button("重试") {
                    Task { await retryAction() }
                }
                .buttonStyle(.bordered)
                .tint(theme.primary)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(theme.background)
    }
}
