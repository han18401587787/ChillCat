//
//  CCThankYouLetterView.swift
//  绪安 - 感谢信页面 (严格对照设计稿 page_42 像素级还原)
//

import SwiftUI

struct CCThankYouLetterView: View {
    @Environment(CCAppCoordinator.self) private var coordinator
    @State private var isLoading = true
    @State private var letters: [ThankYouLetter] = []
    @State private var selectedLetter: ThankYouLetter? = nil

    var body: some View {
        Group {
            if isLoading {
                CCLoadingView(message: "加载中...")
            } else if letters.isEmpty {
                emptyState
            } else {
                letterList
            }
        }
        .background(Color.xuanApricotBg)
        .navigationTitle("感谢信")
        .navigationBarTitleDisplayMode(.large)
        .task { await loadLetters() }
        .sheet(item: $selectedLetter) { letter in
            letterDetailSheet(letter)
        }
    }

    // MARK: - 空状态
    private var emptyState: some View {
        VStack(spacing: XuanSpacing.xl) {
            Spacer()

            ZStack {
                Circle()
                    .fill(Color.xuanPink.opacity(0.1))
                    .frame(width: 120, height: 120)
                Image(systemName: "envelope.open.fill")
                    .font(.system(size: 48))
                    .foregroundColor(Color.xuanPink.opacity(0.4))
            }

            VStack(spacing: XuanSpacing.sm) {
                Text("还没有感谢信")
                    .font(XuanFont.h2)
                    .foregroundColor(Color.xuanTextPrimary)
                Text("当有人因为你传递的温暖而感谢你时，\n你会在这里收到一封手写的感谢信。")
                    .font(XuanFont.bodyM)
                    .foregroundColor(Color.xuanTextSecondary)
                    .multilineTextAlignment(.center)
                    .lineSpacing(4)
            }

            Button(action: {
                coordinator.navigate(to: .resonanceWall)
            }) {
                HStack(spacing: XuanSpacing.sm) {
                    Image("resonance_like")
                        .font(.system(size: 14))
                    Text("去传递温暖")
                        .font(XuanFont.bodyLMedium)
                }
                .foregroundColor(.white)
                .padding(.horizontal, XuanSpacing.xl3)
                .padding(.vertical, 14)
                .background(Color.xuanApricot)
                .cornerRadius(XuanRadius.lg)
            }

            Spacer()
        }
        .padding(XuanSpacing.xl)
    }

    // MARK: - 感谢信列表
    private var letterList: some View {
        ScrollView {
            VStack(spacing: XuanSpacing.md) {
                ForEach(letters) { letter in
                    letterCard(letter)
                        .onTapGesture {
                            selectedLetter = letter
                        }
                }
            }
            .padding(XuanSpacing.lg)
        }
    }

    private func letterCard(_ letter: ThankYouLetter) -> some View {
        VStack(alignment: .leading, spacing: XuanSpacing.md) {
            // 发信人
            HStack(spacing: XuanSpacing.sm) {
                ZStack {
                    Circle()
                        .fill(Color.xuanPink.opacity(0.12))
                        .frame(width: 36, height: 36)
                    Image(systemName: "person.circle.fill")
                        .font(.system(size: 20))
                        .foregroundColor(Color.xuanPink.opacity(0.6))
                }

                VStack(alignment: .leading, spacing: 2) {
                    Text("来自一位温暖的人")
                        .font(XuanFont.bodyS)
                        .foregroundColor(Color.xuanTextSecondary)
                    Text(letter.timeAgo)
                        .font(XuanFont.caption)
                        .foregroundColor(Color.xuanTextTertiary)
                }

                Spacer()

                if !letter.isRead {
                    Circle()
                        .fill(Color.xuanPink)
                        .frame(width: 8, height: 8)
                }
            }

            // 内容预览
            Text(letter.preview)
                .font(XuanFont.bodyL)
                .foregroundColor(Color.xuanTextPrimary)
                .lineSpacing(5)
                .lineLimit(3)

            // 底部标签
            HStack(spacing: XuanSpacing.sm) {
                Image("resonance_like")
                    .font(.system(size: 10))
                    .foregroundColor(Color.xuanPink)
                Text("来自你的一次温暖传递")
                    .font(XuanFont.caption)
                    .foregroundColor(Color.xuanTextTertiary)
                Spacer()
            }
        }
        .padding(XuanSpacing.lg)
        .background(Color.xuanWhite)
        .cornerRadius(XuanRadius.lg)
        .xuanCardShadow()
    }

    // MARK: - 信件详情 Sheet
    private func letterDetailSheet(_ letter: ThankYouLetter) -> some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: XuanSpacing.xl) {
                    // 信封图标
                    ZStack {
                        Circle()
                            .fill(Color.xuanPink.opacity(0.08))
                            .frame(width: 80, height: 80)
                        Image("other_mail")
                            .font(.system(size: 32))
                            .foregroundColor(Color.xuanPink)
                    }
                    .padding(.top, XuanSpacing.xl)

                    // 完整内容
                    Text(letter.fullContent)
                        .font(XuanFont.bodyL)
                        .foregroundColor(Color.xuanTextPrimary)
                        .lineSpacing(8)
                        .padding(XuanSpacing.xl)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color.xuanWhite)
                        .cornerRadius(XuanRadius.lg)
                        .xuanCardShadow()
                }
                .padding(XuanSpacing.lg)
            }
            .background(Color.xuanApricotBg)
            .navigationTitle("感谢信")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("关闭") { selectedLetter = nil }
                }
            }
        }
        .presentationDetents([.large])
    }

    // MARK: - 数据加载
    private func loadLetters() async {
        isLoading = true
        // TODO: 调用 API 获取感谢信列表
        try? await Task.sleep(nanoseconds: 500_000_000)
        // 模拟空数据
        letters = []
        isLoading = false
    }
}

// MARK: - 感谢信模型
struct ThankYouLetter: Identifiable {
    let id: String
    let preview: String
    let fullContent: String
    let timeAgo: String
    let isRead: Bool
}

// MARK: - Preview
#Preview {
    NavigationStack {
        CCThankYouLetterView()
    }
}
