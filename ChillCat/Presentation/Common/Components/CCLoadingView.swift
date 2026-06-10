//
//  CCLoadingView.swift
//  ChillCat
//
//  Created by doudou.han on 2026/6/8.
//
//

import SwiftUI

struct CCLoadingView: View {
    let message: String?
    @Environment(\.ccAppTheme) private var theme

    init(message: String? = nil) {
        self.message = message
    }

    var body: some View {
        VStack(spacing: theme.spacingMD) {
            ProgressView()
                .scaleEffect(1.5)
                .tint(theme.primary)

            if let message = message {
                Text(message)
                    .font(.system(size: 15))
                    .foregroundColor(theme.textSecondary)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(theme.background)
    }
}
