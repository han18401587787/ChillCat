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

    var body: some View {
        VStack(spacing: XuanSpacing.md) {
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 48))
                .foregroundColor(Color.xuanDanger)

            Text(error.localizedDescription)
                .font(.system(size: 15))
                .foregroundColor(Color.xuanTextSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, XuanSpacing.xl)

            if let retryAction = retryAction {
                Button("重试") {
                    Task { await retryAction() }
                }
                .buttonStyle(.bordered)
                .tint(Color.xuanApricot)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.xuanApricotBg)
    }
}
