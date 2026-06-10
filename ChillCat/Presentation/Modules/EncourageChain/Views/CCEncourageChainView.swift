import SwiftUI

/// 鼓励链 — §2.4
struct CCEncourageChainView: View {
    @State private var viewModel = CCEncourageChainViewModel()
    @State private var showEmoji = false
    @Environment(CCAppCoordinator.self) private var coordinator
    @Environment(\.ccAppTheme) private var theme
    @FocusState private var isFocused: Bool

    var body: some View {
        ScrollViewReader { proxy in
            ScrollView {
                VStack(spacing: 0) {
                    // Header
                    headerSection

                    if viewModel.isLoading {
                        CCLoadingView(message: "加载鼓励链…")
                            .frame(height: 300)
                    } else {
                        // Chain visualization
                        chainVisualization
                    }

                    // Input area (only on current chain)
                    if !viewModel.links.isEmpty && viewModel.chainId > 0 {
                        inputSection
                            .id("inputArea")
                    }

                    // "我的鼓励链" link
                    NavigationLink(value: CCAppRoute.myEncourageChains) {
                        HStack {
                            Image(systemName: "list.bullet.rectangle.portrait")
                                .font(.system(size: 14))
                            Text("我的鼓励链")
                                .font(.system(size: 14, weight: .medium))
                            Spacer()
                            Image(systemName: "chevron.right")
                                .font(.system(size: 12))
                        }
                        .foregroundColor(theme.warm)
                        .padding()
                        .background(theme.cardBackground)
                        .cornerRadius(theme.radiusMD)
                        .padding(.horizontal)
                        .padding(.top, theme.spacingMD)
                    }

                    // Error message
                    if let error = viewModel.errorMessage {
                        HStack {
                            Image(systemName: "exclamationmark.triangle.fill")
                                .foregroundColor(theme.error)
                            Text(error)
                                .foregroundColor(theme.error)
                        }
                        .font(.system(size: 14))
                        .padding()
                        .background(theme.error.opacity(0.08))
                        .cornerRadius(theme.radiusSM)
                        .padding(.horizontal)
                    }
                }
                .padding(.bottom, 40)
            }
            .background(theme.background)
            .onChange(of: viewModel.links.count) { _, _ in
                withAnimation {
                    proxy.scrollTo("inputArea", anchor: .bottom)
                }
            }
        }
        .overlay(alignment: .bottom) {
            if showEmoji {
                CCEmojiPicker(isShowing: $showEmoji) { emoji in
                    viewModel.relayText += emoji
                }
                .frame(height: 280)
                .transition(.move(edge: .bottom))
            }
        }
        .animation(.easeInOut, value: showEmoji)
        .navigationTitle("鼓励链")
        .task { await viewModel.loadCurrentChain() }
    }

    // MARK: - Header

    private var headerSection: some View {
        VStack(spacing: 6) {
            HStack {
                Spacer()
                Text("🌟 鼓励链 #\(viewModel.chainId)")
                    .font(.system(size: 22, weight: .bold))
                    .foregroundColor(theme.textPrimary)
                Spacer()
            }
            if viewModel.participantCount > 0 {
                Text("\(viewModel.participantCount) 人参与传递")
                    .font(.system(size: 14))
                    .foregroundColor(theme.textSecondary)
            }

            // Milestone banner
            if viewModel.links.count >= 100 {
                HStack(spacing: 4) {
                    Text("🎉")
                    Text("已达成里程碑！")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(theme.warm)
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(theme.warm.opacity(0.1))
                .cornerRadius(theme.radiusSM)
            }
        }
        .padding()
    }

    // MARK: - Chain Visualization

    private var chainVisualization: some View {
        VStack(spacing: 0) {
            ForEach(Array(viewModel.links.enumerated()), id: \.element.id) { index, link in
                chainCard(link)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 4)

                if index < viewModel.links.count - 1 {
                    chainConnector
                }
            }

            // Empty state
            if viewModel.links.isEmpty {
                VStack(spacing: 16) {
                    Image(systemName: "flame.fill")
                        .font(.system(size: 48))
                        .foregroundColor(theme.warm)
                    Text("还没有鼓励链")
                        .font(.system(size: 18, weight: .semibold))
                    Text("成为第一个发起鼓励的人")
                        .font(.system(size: 14))
                        .foregroundColor(theme.textSecondary)
                }
                .padding(.vertical, 60)
            }
        }
    }

    private func chainCard(_ link: ChainLinkDisplay) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(link.displayIcon)
                    .font(.system(size: 20))
                Text("\(link.label) — 匿名")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(theme.warm)
                Spacer()
                Text(link.createdAt, style: .relative)
                    .font(.system(size: 11))
                    .foregroundColor(theme.textMuted)
            }

            Text(link.content)
                .font(.system(size: 15))
                .foregroundColor(theme.textPrimary)
                .lineSpacing(5)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding()
        .background(theme.cardBackground)
        .cornerRadius(theme.radiusMD)
        .shadow(color: Color.black.opacity(0.03), radius: 3, y: 1)
    }

    private var chainConnector: some View {
        VStack(spacing: 0) {
            Rectangle()
                .fill(theme.primaryMuted.opacity(0.4))
                .frame(width: 2, height: 20)
            Image(systemName: "arrowtriangle.down.fill")
                .font(.system(size: 8))
                .foregroundColor(theme.primaryMuted.opacity(0.6))
        }
    }

    // MARK: - Input Section

    private var inputSection: some View {
        VStack(spacing: 12) {
            Rectangle()
                .fill(theme.primaryMuted.opacity(0.3))
                .frame(width: 2, height: 20)

            VStack(spacing: 10) {
                HStack(spacing: 4) {
                    Text("✍️")
                        .font(.system(size: 16))
                    Text("写下你的鼓励，传递下去")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(theme.textSecondary)
                }

                ZStack(alignment: .bottomTrailing) {
                    TextField("写下你的鼓励…", text: $viewModel.relayText, axis: .vertical)
                        .focused($isFocused)
                        .font(.system(size: 15))
                        .lineLimit(3...5)
                        .padding()
                        .background(theme.surface)
                        .cornerRadius(theme.radiusMD)

                    Text("\(viewModel.characterCount)/140")
                        .font(.system(size: 11))
                        .foregroundColor(
                            viewModel.characterCount > 140 ? theme.error : theme.textMuted
                        )
                        .padding(.trailing, 12)
                        .padding(.bottom, 8)
                }

                HStack {
                    Button(action: { showEmoji.toggle() }) {
                        Image(systemName: "face.smiling")
                            .font(.system(size: 18))
                            .foregroundColor(theme.primary)
                            .frame(width: 40, height: 40)
                            .background(theme.primary.opacity(0.1))
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
                                ProgressView()
                                    .tint(.white)
                                    .scaleEffect(0.8)
                            } else {
                                Image(systemName: "paperplane.fill")
                            }
                            Text("发送")
                        }
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.white)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 10)
                        .background(viewModel.canRelay ? theme.primary : theme.textMuted)
                        .cornerRadius(theme.radiusMD)
                    }
                    .disabled(!viewModel.canRelay || viewModel.isRelaying)
                }
            }
            .padding()
            .background(theme.cardBackground)
            .cornerRadius(theme.radiusMD)
            .padding(.horizontal, 16)
        }
    }
}
