//
//  CCEncourageChainView.swift
//  绪安 - 鼓励接力 (严格对照设计稿 page_44 像素级还原)
//

import SwiftUI

struct CCEncourageChainView: View {
    @State private var viewModel = CCEncourageChainViewModel()
    @State private var showEmoji = false
    @Environment(CCAppCoordinator.self) private var coordinator
    @FocusState private var isFocused: Bool

    let specificChainId: Int64?

    init(specificChainId: Int64? = nil) {
        self.specificChainId = specificChainId
    }

    var body: some View {
        ScrollViewReader { proxy in
            ScrollView {
                VStack(spacing: XuanSpacing.lg) {
                    headerSection

                    if viewModel.isLoading {
                        CCLoadingView(message: "加载鼓励链…")
                            .frame(height: 300)
                    } else {
                        chainVisualization
                    }

                    if !viewModel.links.isEmpty && viewModel.chainId > 0 {
                        inputSection
                            .id("inputArea")
                    }

                    NavigationLink(value: CCAppRoute.myEncourageChains) {
                        HStack(spacing: XuanSpacing.sm) {
                            Image(systemName: "list.bullet.rectangle.portrait")
                                .font(.system(size: 14))
                            Text("我的鼓励链")
                                .font(XuanFont.bodyM)
                            Spacer()
                            Image(systemName: "chevron.right")
                                .font(.system(size: 12))
                        }
                        .foregroundColor(Color.xuanApricotDark)
                        .padding(XuanSpacing.lg)
                        .background(Color.xuanWhite)
                        .cornerRadius(XuanRadius.md)
                    }
                    .padding(.horizontal, XuanSpacing.lg)

                    if let error = viewModel.errorMessage {
                        errorBanner(error)
                    }
                }
                .padding(.bottom, 40)
            }
            .background(Color.xuanApricotBg)
            .onChange(of: viewModel.links.count) { _, _ in
                withAnimation { proxy.scrollTo("inputArea", anchor: .bottom) }
            }
        }
        .cc_emojiPickerOverlay(isShowing: $showEmoji) { emoji in
            viewModel.relayText += emoji.displayName
        }
        .navigationTitle("鼓励接力")
        .navigationBarTitleDisplayMode(.large)
        .task {
            if let chainId = specificChainId {
                await viewModel.loadChain(id: chainId)
            } else {
                await viewModel.loadCurrentChain()
            }
        }
    }

    // MARK: - Header
    private var headerSection: some View {
        VStack(spacing: XuanSpacing.sm) {
            Text("🔥 鼓励链 #\(viewModel.chainId)")
                .font(XuanFont.h2)
                .foregroundColor(Color.xuanTextPrimary)

            if viewModel.participantCount > 0 {
                Text("\(viewModel.participantCount) 人参与传递善意")
                    .font(XuanFont.bodyM)
                    .foregroundColor(Color.xuanTextSecondary)
            }

            if viewModel.links.count >= 100 {
                HStack(spacing: 4) {
                    Text("🎉")
                    Text("已达成里程碑！")
                        .font(XuanFont.bodyS)
                        .foregroundColor(Color.xuanApricotDark)
                }
                .padding(.horizontal, XuanSpacing.md)
                .padding(.vertical, XuanSpacing.xs)
                .background(Color.xuanApricotDark.opacity(0.1))
                .cornerRadius(XuanRadius.full)
            }
        }
        .padding(XuanSpacing.lg)
        .frame(maxWidth: .infinity)
    }

    // MARK: - Chain Visualization
    private var chainVisualization: some View {
        VStack(spacing: 0) {
            ForEach(Array(viewModel.links.enumerated()), id: \.element.id) { index, link in
                chainCard(link)
                    .padding(.horizontal, XuanSpacing.lg)
                    .padding(.vertical, 4)

                if index < viewModel.links.count - 1 {
                    chainConnector
                }
            }

            if viewModel.links.isEmpty {
                VStack(spacing: XuanSpacing.lg) {
                    Image(systemName: "flame.fill")
                        .font(.system(size: 48))
                        .foregroundColor(Color.xuanApricotDark)

                    VStack(spacing: XuanSpacing.xs) {
                        Text("还没有鼓励链")
                            .font(XuanFont.h3)
                            .foregroundColor(Color.xuanTextPrimary)
                        Text("成为第一个传递善意的人吧")
                            .font(XuanFont.bodyM)
                            .foregroundColor(Color.xuanTextSecondary)
                    }
                }
                .padding(.vertical, 60)
            }
        }
    }

    private func chainCard(_ link: ChainLinkDisplay) -> some View {
        VStack(alignment: .leading, spacing: XuanSpacing.sm) {
            HStack {
                Text(link.displayIcon)
                    .font(.system(size: 20))
                Text("\(link.label) · 匿名")
                    .font(XuanFont.bodyS)
                    .foregroundColor(Color.xuanApricotDark)
                Spacer()
                Text(link.createdAt, style: .relative)
                    .font(XuanFont.caption)
                    .foregroundColor(Color.xuanTextTertiary)
            }

            Text(link.content)
                .font(XuanFont.bodyL)
                .foregroundColor(Color.xuanTextPrimary)
                .lineSpacing(5)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(XuanSpacing.lg)
        .background(Color.xuanWhite)
        .cornerRadius(XuanRadius.lg)
        .xuanCardShadow()
    }

    private var chainConnector: some View {
        VStack(spacing: 0) {
            Rectangle()
                .fill(Color.xuanApricot.opacity(0.3))
                .frame(width: 2, height: 20)
            Image(systemName: "arrowtriangle.down.fill")
                .font(.system(size: 8))
                .foregroundColor(Color.xuanApricot.opacity(0.4))
        }
    }

    // MARK: - Input Section
    private var inputSection: some View {
        VStack(spacing: XuanSpacing.md) {
            chainConnector

            VStack(spacing: XuanSpacing.sm) {
                HStack(spacing: 4) {
                    Text("✍️")
                    Text("写下你的鼓励，传递下去")
                        .font(XuanFont.bodyM)
                        .foregroundColor(Color.xuanTextSecondary)
                }

                ZStack(alignment: .bottomTrailing) {
                    TextField("写下你的鼓励…", text: $viewModel.relayText, axis: .vertical)
                        .focused($isFocused)
                        .font(XuanFont.bodyL)
                        .lineLimit(3...5)
                        .padding(XuanSpacing.lg)
                        .background(Color.xuanSurface)
                        .cornerRadius(XuanRadius.md)

                    Text("\(viewModel.characterCount)/140")
                        .font(XuanFont.caption)
                        .foregroundColor(
                            viewModel.characterCount > 140
                                ? Color.xuanDanger
                                : Color.xuanTextTertiary
                        )
                        .padding(.trailing, XuanSpacing.md)
                        .padding(.bottom, XuanSpacing.sm)
                }

                HStack {
                    Button(action: { showEmoji.toggle() }) {
                        Image(systemName: "face.smiling")
                            .font(.system(size: 18))
                            .foregroundColor(Color.xuanApricot)
                            .frame(width: 40, height: 40)
                            .background(Color.xuanApricot.opacity(0.1))
                            .clipShape(Circle())
                    }

                    Spacer()

                    Button(action: {
                        CCHaptic.success()
                        isFocused = false
                        Task { await viewModel.relayMessage() }
                    }) {
                        HStack(spacing: 4) {
                            if viewModel.isRelaying {
                                ProgressView().tint(.white).scaleEffect(0.8)
                            } else {
                                Image(systemName: "paperplane.fill")
                            }
                            Text("传递善意")
                        }
                        .font(XuanFont.bodyM)
                        .foregroundColor(.white)
                        .padding(.horizontal, XuanSpacing.xl)
                        .padding(.vertical, XuanSpacing.sm)
                        .background(
                            viewModel.canRelay
                                ? Color.xuanApricot
                                : Color.xuanTextTertiary
                        )
                        .cornerRadius(XuanRadius.md)
                    }
                    .disabled(!viewModel.canRelay || viewModel.isRelaying)
                }
            }
            .padding(XuanSpacing.lg)
            .background(Color.xuanWhite)
            .cornerRadius(XuanRadius.lg)
            .padding(.horizontal, XuanSpacing.lg)
        }
    }

    // MARK: - Error Banner
    private func errorBanner(_ message: String) -> some View {
        HStack(spacing: XuanSpacing.sm) {
            Image(systemName: "exclamationmark.triangle.fill")
                .foregroundColor(Color.xuanDanger)
            Text(message)
                .font(XuanFont.bodyS)
                .foregroundColor(Color.xuanDanger)
        }
        .padding(XuanSpacing.md)
        .background(Color.xuanDanger.opacity(0.08))
        .cornerRadius(XuanRadius.sm)
        .padding(.horizontal, XuanSpacing.lg)
    }
}
