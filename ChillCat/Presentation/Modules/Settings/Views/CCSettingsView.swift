//
//  CCSettingsView.swift
//  ChillCat
//
//  Created by doudou.han on 2026/6/8.
//
//

import SwiftUI

struct CCSettingsView: View {
    @Environment(CCAppCoordinator.self) private var coordinator
    @Environment(CCThemeManager.self) private var themeManager

    var body: some View {
        List {
            Section("外观") {
                Toggle(isOn: $themeManager.isDarkMode) {
                    HStack {
                        Image(systemName: "moon.fill")
                            .foregroundColor(.indigo)
                        Text("暗色模式")
                    }
                }
            }

            Section("通用") {
                HStack {
                    Image(systemName: "globe")
                        .foregroundColor(.blue)
                    Text("语言")
                    Spacer()
                    Text("简体中文")
                        .foregroundColor(.secondary)
                }

                HStack {
                    Image(systemName: "textformat.size")
                        .foregroundColor(.green)
                    Text("字体大小")
                    Spacer()
                    Text("标准")
                        .foregroundColor(.secondary)
                }
            }

            Section("关于") {
                HStack {
                    Image(systemName: "info.circle.fill")
                        .foregroundColor(.blue)
                    Text("版本")
                    Spacer()
                    Text("1.0.0")
                        .foregroundColor(.secondary)
                }

                HStack {
                    Image(systemName: "doc.text.fill")
                        .foregroundColor(.gray)
                    Text("用户协议")
                    Spacer()
                    Image(systemName: "chevron.right")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }

                HStack {
                    Image(systemName: "lock.fill")
                        .foregroundColor(.gray)
                    Text("隐私政策")
                    Spacer()
                    Image(systemName: "chevron.right")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
        }
        .navigationTitle("设置")
    }
}
