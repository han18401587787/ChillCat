//
//  CCMeditationPlayerView.swift
//  绪安 - 冥想播放器 (对照截图 #2 像素级还原)
//
//  布局: 方形封面图 → 标题+副标题 → 进度条+时间 → 播放/暂停大按钮 → 定时关闭选项

import SwiftUI

struct CCMeditationPlayerView: View {
    let session: CCMeditationSession
    @Environment(\.dismiss) private var dismiss
    @State private var viewModel = CCAudioPlayerViewModel()
    @State private var isDragging = false
    @State private var dragTime: TimeInterval = 0
    @State private var timerOption: Int = 0  // 0=不限, 1=15min, 2=30min, 3=60min
    private let timerOptions = [0, 15, 30, 60]

    var body: some View {
        VStack(spacing: XuanSpacing.xl) {
            Spacer().frame(height: 20)

            // 方形封面
            coverImage

            // 标题
            VStack(spacing: XuanSpacing.xs) {
                Text(session.title)
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(Color.xuanTextPrimary)
                Text(session.category.subtitle)
                    .font(XuanFont.bodyS)
                    .foregroundColor(Color.xuanTextSecondary)
            }

            // 进度条 + 时间
            VStack(spacing: XuanSpacing.sm) {
                Slider(
                    value: isDragging ? $dragTime : $viewModel.currentTime,
                    in: 0...max(viewModel.duration, 1),
                    onEditingChanged: { editing in
                        isDragging = editing
                        if editing { dragTime = viewModel.currentTime }
                        else { viewModel.seek(to: dragTime) }
                    }
                )
                .accentColor(Color.xuanMint)
                .disabled(viewModel.isLoading || viewModel.duration <= 0)

                HStack {
                    Text(formatTime(isDragging ? dragTime : viewModel.currentTime))
                        .font(.system(size: 13, design: .monospaced))
                        .foregroundColor(Color.xuanTextSecondary)
                    Spacer()
                    Text(formatTime(viewModel.duration))
                        .font(.system(size: 13, design: .monospaced))
                        .foregroundColor(Color.xuanTextTertiary)
                }
            }
            .padding(.horizontal, XuanSpacing.xl2)

            // 播放/暂停 大按钮
            Button(action: { viewModel.togglePlayPause() }) {
                ZStack {
                    Circle()
                        .fill(Color.xuanMint.opacity(0.12))
                        .frame(width: 88, height: 88)

                    if viewModel.isLoading {
                        ProgressView()
                            .scaleEffect(1.5)
                    } else {
                        CCIconMapper.image(for: viewModel.isPlaying ? "pause.fill" : "play.fill")
                            .font(.system(size: 36))
                            .foregroundColor(Color.xuanMint)
                    }
                }
            }
            .disabled(viewModel.isLoading)

            // 定时关闭
            VStack(spacing: XuanSpacing.sm) {
                Text("定时关闭")
                    .font(XuanFont.bodyS)
                    .foregroundColor(Color.xuanTextTertiary)

                HStack(spacing: XuanSpacing.sm) {
                    timerChip(label: "不限", minutes: 0)
                    timerChip(label: "15分钟", minutes: 15)
                    timerChip(label: "30分钟", minutes: 30)
                    timerChip(label: "60分钟", minutes: 60)
                }
            }

            // 提示文字
            if let error = viewModel.errorMessage {
                Text(error)
                    .font(XuanFont.bodyS)
                    .foregroundColor(Color.xuanDanger)
            } else if viewModel.isLoading {
                Text("正在准备音频...")
                    .font(XuanFont.bodyS)
                    .foregroundColor(Color.xuanTextSecondary)
            } else {
                hintText
                    .font(XuanFont.bodyS)
                    .foregroundColor(Color.xuanTextTertiary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, XuanSpacing.xl2)
            }

            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.xuanApricotBg)
        .navigationTitle(session.title)
        .navigationBarTitleDisplayMode(.inline)
        .onDisappear { viewModel.stop() }
        .task { await viewModel.load(session: session) }
    }

    // MARK: - 方形封面
    private var coverImage: some View {
        ZStack {
            RoundedRectangle(cornerRadius: XuanRadius.lg)
                .fill(
                    LinearGradient(
                        colors: [
                            Color(hex: session.category.themeColor).opacity(0.3),
                            Color(hex: session.category.themeColor).opacity(0.1),
                            Color.xuanApricotBg
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: 200, height: 200)

            VStack(spacing: XuanSpacing.md) {
                CCIconMapper.image(for: session.category.iconName)
                    .font(.system(size: 48))
                    .foregroundColor(Color(hex: session.category.themeColor))

                if viewModel.isPlaying {
                    HStack(spacing: 3) {
                        ForEach(0..<3) { i in
                            RoundedRectangle(cornerRadius: 2)
                                .fill(Color(hex: session.category.themeColor).opacity(0.6))
                                .frame(width: 3, height: [12, 20, 8][i])
                                .scaleEffect(y: viewModel.isPlaying ? [1.0, 0.6, 0.8][i] : 1.0, anchor: .center)
                                .animation(
                                    .easeInOut(duration: 0.4).repeatForever(autoreverses: true)
                                    .delay(Double(i) * 0.15),
                                    value: viewModel.isPlaying
                                )
                        }
                    }
                }
            }
        }
    }

    // MARK: - 定时Chip
    private func timerChip(label: String, minutes: Int) -> some View {
        Button(action: { timerOption = minutes }) {
            Text(label)
                .font(XuanFont.caption)
                .foregroundColor(timerOption == minutes ? .white : Color.xuanTextSecondary)
                .padding(.horizontal, XuanSpacing.md)
                .padding(.vertical, XuanSpacing.xs)
                .background(
                    timerOption == minutes
                        ? Color.xuanMint
                        : Color.xuanSurface
                )
                .cornerRadius(XuanRadius.full)
        }
        .buttonStyle(.plain)
    }

    private var hintText: Text {
        switch session.category {
        case .sleep:
            return Text("闭上眼睛，跟随音波的节奏缓缓入眠。")
        case .relax:
            return Text("给自己一段独处的时间，让思绪自然流淌。")
        case .anxiety:
            return Text("接纳此刻的感受，让声音带走紧绷与不安。")
        }
    }

    private func formatTime(_ interval: TimeInterval) -> String {
        let total = Int(max(0, interval))
        let m = total / 60
        let s = total % 60
        return String(format: "%d:%02d", m, s)
    }
}
