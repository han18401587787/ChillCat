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

    init(message: String? = nil) {
        self.message = message
    }

    var body: some View {
        VStack(spacing: XuanSpacing.md) {
            ProgressView()
                .scaleEffect(1.5)
                .tint(Color.xuanApricot)

            if let message = message {
                Text(message)
                    .font(.system(size: 15))
                    .foregroundColor(Color.xuanTextSecondary)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.xuanApricotBg)
    }
}
