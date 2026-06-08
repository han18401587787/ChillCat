//
//  CCMemberPurchaseView.swift
//  ChillCat
//
//  Created by doudou.han on 2026/6/8.
//
//

import SwiftUI

struct CCMemberPurchaseView: View {
    @Environment(CCAppCoordinator.self) private var coordinator

    var body: some View {
        VStack(spacing: 24) {
            Text("确认购买")
                .font(.title2)
                .fontWeight(.bold)

            Text("购买流程即将完成")
                .foregroundColor(.secondary)

            Button("返回会员中心") {
                coordinator.pop()
            }
            .buttonStyle(.bordered)
        }
        .navigationTitle("购买确认")
    }
}
