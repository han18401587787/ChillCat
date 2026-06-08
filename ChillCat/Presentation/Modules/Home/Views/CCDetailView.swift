//
//  CCDetailView.swift
//  ChillCat
//
//  Created by doudou.han on 2026/6/8.
//
//

import SwiftUI

struct CCDetailView: View {
    let itemId: String
    @Environment(CCAppCoordinator.self) private var coordinator

    init(itemId: String) {
        self.itemId = itemId
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                Image(systemName: "photo.fill")
                    .font(.system(size: 80))
                    .foregroundColor(.secondary)
                    .frame(height: 200)
                    .frame(maxWidth: .infinity)
                    .background(Color(.secondarySystemBackground))
                    .cornerRadius(12)

                VStack(spacing: 8) {
                    Text("详情页面")
                        .font(.title)
                        .fontWeight(.bold)

                    Text("项目ID: \(itemId)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }

                Text("这是一个详情页面的示例，展示内容的详细信息。实际使用时会从服务器加载数据。")
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            }
            .padding()
        }
        .navigationTitle("详情")
        .navigationBarTitleDisplayMode(.inline)
    }
}
