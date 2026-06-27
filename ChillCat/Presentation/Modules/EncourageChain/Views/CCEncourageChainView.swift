import SwiftUI

/// 鼓励链 — §2.4
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
                        .foregroundColor(Color.xuanApricotDark)
                        .padding()
                        .background(Color.xuanWhite)
                        .cornerRadius(XuanRadius.md)
                        .padding(.horizontal)
                        .padding(.top, XuanSpacing.md)
                    }

                    // Error message
                    if let error = viewModel.errorMessage {
                        HStack {
                            Image(systemName: "exclamationmark.triangle.fill")
                                .foregroundColor(Color.xuanDanger)
                            Text(error)
                                .foregroundColor(Color.xuanDanger)
                        }
                        .font(.system(size: 14))
                        .padding()
                        .background(Color.xuanDanger.opacity(0.08))
                        .cornerRadius(XuanRadius.sm)
                        .padding(.horizontal)
                    }
                }
                .padding(.bottom, 40)
            }
            .background(Color.xuanApricotBg)
            .onChange(of: viewModel.links.count) { _, _ in
                withAnimation {
                    proxy.scrollTo("inputArea", anchor: .bottom)
                }
            }
        }
        .cc_emojiPickerOverlay(isShowing: $showEmoji) { emoji in
            viewModel.relayText += emoji.displayName
        }
        .animation(.easeInOut, value: showEmoji)
        .navigationTitle("鼓励链")
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
        VStack(spacing: 6) {
            HStack {
                Spacer()
                Text("🌟 鼓励链 #\(viewModel.chainId)")
                    .font(.system(size: 22, weight: .bold))
                    .foregroundColor(Color.xuanTextPrimary)
                Spacer()
            }
            if viewModel.participantCount > 0 {
                Text("\(viewModel.participantCount) 人参与传递")
                    .font(.system(size: 14))
                    .foregroundColor(Color.xuanTextSecondary)
            }

            // Milestone banner
            if viewModel.links.count >= 100 {
                HStack(spacing: 4) {
                    Text("🎉")
                    Text("已达成里程碑！")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(Color.xuanApricotDark)
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(Color.xuanApricotDark.opacity(0.1))
                .cornerRadius(XuanRadius.sm)
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
                        .foregroundColor(Color.xuanApricotDark)
                    Text("还没有鼓励链")
                        .font(.system(size: 18, weight: .semibold))
                    Text("成为第一个发起鼓励的人")
                        .font(.system(size: 14))
                        .foregroundColor(Color.xuanTextSecondary)
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
                    .foregroundColor(Color.xuanApricotDark)
                Spacer()
                Text(link.createdAt, style: .relative)
                    .font(.system(size: 11))
                    .foregroundColor(Color.xuanTextTertiary)
            }

            Text(link.content)
                .font(.system(size: 15))
                .foregroundColor(Color.xuanTextPrimary)
                .lineSpacing(5)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding()
        .background(Color.xuanWhite)
        .cornerRadius(XuanRadius.md)
        .shadow(color: Color.black.opacity(0.03), radius: 3, y: 1)
    }

    private var chainConnector: some View {
        VStack(spacing: 0) {
            Rectangle()
                .fill(Color.xuanApricot.opacity(0.6).opacity(0.4))
                .frame(width: 2, height: 20)
            Image(systemName: "arrowtriangle.down.fill")
                .font(.system(size: 8))
                .foregroundColor(Color.xuanApricot.opacity(0.6).opacity(0.6))
        }
    }

    // MARK: - Input Section

    private var inputSection: some View {
        VStack(spacing: 12) {
            Rectangle()
                .fill(Color.xuanApricot.opacity(0.6).opacity(0.3))
                .frame(width: 2, height: 20)

            VStack(spacing: 10) {
                HStack(spacing: 4) {
                    Text("✍️")
                        .font(.system(size: 16))
                    Text("写下你的鼓励，传递下去")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(Color.xuanTextSecondary)
                }

                ZStack(alignment: .bottomTrailing) {
                    TextField("写下你的鼓励…", text: $viewModel.relayText, axis: .vertical)
                        .focused($isFocused)
                        .font(.system(size: 15))
                        .lineLimit(3...5)
                        .padding()
                        .background(Color.xuanSurface)
                        .cornerRadius(XuanRadius.md)

                    Text("\(viewModel.characterCount)/140")
                        .font(.system(size: 11))
                        .foregroundColor(
                            viewModel.characterCount > 140 ? Color.xuanDanger : Color.xuanTextTertiary
                        )
                        .padding(.trailing, 12)
                        .padding(.bottom, 8)
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
                        .background(viewModel.canRelay ? Color.xuanApricot : Color.xuanTextTertiary)
                        .cornerRadius(XuanRadius.md)
                    }
                    .disabled(!viewModel.canRelay || viewModel.isRelaying)
                }
            }
            .padding()
            .background(Color.xuanWhite)
            .cornerRadius(XuanRadius.md)
            .padding(.horizontal, 16)
        }
    }
}
