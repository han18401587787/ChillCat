//
//  CCResonanceView.swift
//  绪安 - 共鸣墙 (严格对照设计稿 page_20 像素级还原)
//
//  设计稿来源: /workspace/design_pages/page_20.png
//  布局：标题"共鸣墙" + 在线人数 → 你并不孤单提示 → 共鸣卡片列表 → 写下心情FAB

import SwiftUI

struct CCResonanceView: View {
    var viewModel: CCResonanceViewModel
    @Environment(CCAppCoordinator.self) private var coordinator

    @State private var showComposer = false
    @State private var composerText = ""
    @State private var heartScale: [String: CGFloat] = [:]
    @State private var heartTrigger: [String: Bool] = [:]
    @FocusState private var composerFocused: Bool

    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            Color.xuanApricotBg.ignoresSafeArea()

            if viewModel.isLoading && viewModel.resonanceItems.isEmpty {
                CCLoadingView(message: "正在连接共鸣…")
            } else if let error = viewModel.error, viewModel.resonanceItems.isEmpty {
                CCErrorView(error: error) { await viewModel.loadResonance() }
            } else {
                resonanceList
            }

            // 悬浮发布按钮
            if !viewModel.resonanceItems.isEmpty {
                composeFAB
            }
        }
        .navigationTitle("共鸣墙")
        .navigationBarTitleDisplayMode(.large)
        .toolbar { toolbarContent }
        .task { await viewModel.loadResonance() }
        .sheet(isPresented: $showComposer) { composeSheet }
        .animation(.easeInOut(duration: 0.25), value: showComposer)
    }

    // MARK: - Toolbar
    @ToolbarContentBuilder
    private var toolbarContent: some ToolbarContent {
        ToolbarItem(placement: .topBarTrailing) {
            HStack(spacing: XuanSpacing.sm) {
                // 在线人数
                HStack(spacing: 4) {
                    Circle()
                        .fill(Color.xuanMint)
                        .frame(width: 6, height: 6)
                    Text("\(viewModel.onlineCount) 人此刻")
                        .font(XuanFont.bodyS)
                        .foregroundColor(Color.xuanTextSecondary)
                }
                .padding(.horizontal, XuanSpacing.md)
                .padding(.vertical, 4)
                .background(Color.xuanMint.opacity(0.1))
                .cornerRadius(XuanRadius.full)

                // 鼓励链入口
                Button(action: {
                    coordinator.navigate(to: .encourageChain)
                }) {
                    HStack(spacing: 2) {
                        Text("🔥").font(.system(size: 12))
                        Text("鼓励链").font(XuanFont.bodyS)
                    }
                    .foregroundColor(Color.xuanApricotDark)
                }
            }
        }
    }

    // MARK: - List
    private var resonanceList: some View {
        ScrollView {
            VStack(spacing: XuanSpacing.md) {
                // "你并不孤单" 提示卡片 (设计稿特有)
                notAloneBanner

                LazyVStack(spacing: XuanSpacing.md) {
                    ForEach(viewModel.resonanceItems) { item in
                        resonanceCard(item)
                            .onAppear {
                                if item.id == viewModel.resonanceItems.last?.id {
                                    Task { await viewModel.loadMore() }
                                }
                            }
                    }
                }

                if viewModel.isLoadingMore {
                    HStack { Spacer(); ProgressView(); Spacer() }.padding()
                }

                if !viewModel.hasMore && !viewModel.resonanceItems.isEmpty {
                    Text("— 已经到底了 —")
                        .font(XuanFont.bodyS)
                        .foregroundColor(Color.xuanTextTertiary)
                        .padding(.vertical, XuanSpacing.lg)
                }
            }
            .padding(XuanSpacing.lg)
            .padding(.bottom, 80)
        }
        .refreshable { await viewModel.refresh() }
    }

    // MARK: - 你并不孤单横幅
    private var notAloneBanner: some View {
        HStack(spacing: XuanSpacing.md) {
            ZStack {
                Circle()
                    .fill(Color.white.opacity(0.5))
                    .frame(width: 44, height: 44)
                Image(systemName: "hand.raised.fill")
                    .font(.system(size: 20))
                    .foregroundColor(Color.xuanPinkDark)
            }

            VStack(alignment: .leading, spacing: 2) {
                Text("你并不孤单")
                    .font(XuanFont.bodyLBold)
                    .foregroundColor(Color.xuanTextPrimary)
                Text("这里有很多人和你一样，在经历着相似的感受")
                    .font(XuanFont.bodyS)
                    .foregroundColor(Color.xuanTextSecondary)
            }
            Spacer()
        }
        .padding(XuanSpacing.lg)
        .background(Color.xuanPinkLight)
        .cornerRadius(XuanRadius.md)
    }

    // MARK: - Card (设计稿风格)
    private func resonanceCard(_ item: CCResonanceDisplayItem) -> some View {
        VStack(alignment: .leading, spacing: XuanSpacing.md) {
            // 可点击区域：顶栏 + 内容 → 导航到详情
            Button(action: {
                coordinator.navigate(to: .resonanceDetail(item))
            }) {
                VStack(alignment: .leading, spacing: XuanSpacing.md) {
                    // 顶栏：情绪标签 + 时间
                    HStack(spacing: XuanSpacing.sm) {
                        HStack(spacing: 4) {
                            Circle()
                                .fill(item.emotionColorValue)
                                .frame(width: 8, height: 8)
                            Text(item.emotion)
                                .font(XuanFont.bodyS)
                                .foregroundColor(item.emotionColorValue)
                        }
                        Spacer()
                        Text(item.timeAgo)
                            .font(XuanFont.caption)
                            .foregroundColor(Color.xuanTextTertiary)
                    }

                    // 内容
                    Text(item.content)
                        .font(.system(size: 15))
                        .foregroundColor(Color.xuanTextPrimary)
                        .lineSpacing(6)
                        .lineLimit(5)
                        .multilineTextAlignment(.leading)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
            .buttonStyle(.plain)

            // 底栏操作（独立按钮，不触发卡片导航）
            HStack(spacing: XuanSpacing.lg) {
                Button(action: {
                    CCHaptic.light()
                    viewModel.hugResonance(item, message: nil)
                    // 放大动画
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.4)) {
                        heartScale[item.id] = 1.4
                    }
                    // 0.3s 后复原
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                            heartScale[item.id] = 1.0
                        }
                    }
                    // Lottie 动画：触发显示 → 0.8s 后隐藏
                    heartTrigger[item.id] = true
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                        withAnimation(.easeOut(duration: 0.2)) {
                            heartTrigger[item.id] = false
                        }
                    }
                }) {
                    HStack(spacing: 4) {
                        ZStack {
                            // Lottie 动画层（播完自动隐藏）
                            if heartTrigger[item.id] == true {
                                CCHeartBeatAnimation(
                                    trigger: Binding(
                                        get: { heartTrigger[item.id] ?? false },
                                        set: { heartTrigger[item.id] = $0 }
                                    ),
                                    size: 28
                                )
                                .allowsHitTesting(false)
                                .transition(.opacity)
                            }
                            // 心形图标（Lottie 播放时隐藏，播完恢复）
                            Image(systemName: "heart.fill")
                                .font(.system(size: 14))
                                .foregroundColor(Color.xuanPink)
                                .scaleEffect(heartScale[item.id] ?? 1.0)
                                .opacity(heartTrigger[item.id] == true ? 0 : 1)
                        }
                        Text("\(item.resonanceCount) 人共鸣")
                            .font(XuanFont.bodyS)
                            .foregroundColor(Color.xuanTextSecondary)
                    }
                }
                .buttonStyle(.plain)
                .contentShape(Rectangle())
                .accessibilityIdentifier("resonance_card_hug")

                Spacer()

                Button(action: { showComposer = true }) {
                    HStack(spacing: 4) {
                        Image(systemName: "bubble.left")
                            .font(.system(size: 12))
                        Text("我也想说")
                            .font(XuanFont.caption)
                    }
                    .foregroundColor(Color.xuanApricot)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(Color.xuanApricotLight)
                    .cornerRadius(XuanRadius.sm)
                }
                .buttonStyle(.plain)

                Button(action: {
                    CCHaptic.light()
                    viewModel.hugResonance(item, message: "💚")
                }) {
                    HStack(spacing: 4) {
                        Image(systemName: "arrowshape.turn.up.forward.fill")
                            .font(.system(size: 12))
                        Text("传递")
                            .font(XuanFont.caption)
                    }
                    .foregroundColor(Color.xuanTextSecondary)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                }
                .buttonStyle(.plain)
                .contentShape(Rectangle())
                .accessibilityIdentifier("resonance_card_pass_\(item.id)")
            }
        }
        .padding(XuanSpacing.lg)
        .background(Color.xuanWhite)
        .cornerRadius(XuanRadius.lg)
        .xuanCardShadow()
    }

    // MARK: - Floating Compose Button
    private var composeFAB: some View {
        Button(action: { showComposer = true }) {
            HStack(spacing: 6) {
                Image(systemName: "pencil.line")
                    .font(.system(size: 16))
                Text("写下心情")
                    .font(XuanFont.bodyLBold)
            }
            .foregroundColor(.white)
            .padding(.horizontal, XuanSpacing.xl)
            .padding(.vertical, 12)
            .background(Color.xuanApricot)
            .cornerRadius(XuanRadius.full)
            .shadow(color: Color(hex: "2C2416").opacity(0.15), radius: 16, x: 0, y: 4)
        }
        .accessibilityIdentifier("resonance_compose_fab")
        .padding(.trailing, XuanSpacing.lg)
        .padding(.bottom, XuanSpacing.lg)
    }

    // MARK: - Compose Sheet
    private var composeSheet: some View {
        NavigationStack {
            VStack(spacing: XuanSpacing.lg) {
                TextField("分享你的心情，与千万人共鸣…", text: $composerText, axis: .vertical)
                    .focused($composerFocused)
                    .font(XuanFont.bodyL)
                    .lineLimit(4...10)
                    .padding(XuanSpacing.lg)
                    .background(Color.xuanWhite)
                    .cornerRadius(XuanRadius.md)
                    .xuanCardShadow()

                Button(action: {
                    guard !composerText.trimmingCharacters(in: .whitespaces).isEmpty else { return }
                    viewModel.newPostText = composerText
                    viewModel.publishPost()
                    composerText = ""
                    showComposer = false
                    CCHaptic.medium()
                }) {
                    HStack {
                        Spacer()
                        Image(systemName: "paperplane.fill")
                            .font(.system(size: 14))
                        Text("发送倾诉")
                            .font(XuanFont.bodyLMedium)
                        Spacer()
                    }
                    .foregroundColor(.white)
                    .padding(.vertical, 14)
                    .background(
                        composerText.trimmingCharacters(in: .whitespaces).count >= 3
                            ? Color.xuanApricot
                            : Color.xuanApricot.opacity(0.4)
                    )
                    .cornerRadius(XuanRadius.md)
                }
                .disabled(composerText.trimmingCharacters(in: .whitespaces).count < 3)

                Spacer()
            }
            .padding(XuanSpacing.lg)
            .background(Color.xuanApricotBg)
            .navigationTitle("写下心情")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("取消") {
                        composerText = ""
                        showComposer = false
                    }
                }
            }
        }
    }
}
