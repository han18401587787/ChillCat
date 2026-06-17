//
//  CCMeditationPlayerView.swift
//  ChillCat
//
//  冥想音频播放页面 — 时间轴滑块、播放/暂停、进度标签
//

import SwiftUI

struct CCMeditationPlayerView: View {
    let session: CCMeditationSession

    @Environment(\.dismiss) private var dismiss
    @State private var viewModel = CCAudioPlayerViewModel()
    @State private var isDragging = false
    @State private var dragTime: TimeInterval = 0

    var body: some View {
        VStack(spacing: AppSpacing.lg) {
            // 顶部占位
            Spacer().frame(height: 40)

            // 音频可视化占位（呼吸光晕）
            audioVisualizer

            // 标题
            VStack(spacing: AppSpacing.xs) {
                Text(session.title)
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(AppTheme.textPrimary)
                Text(session.category.displayName)
                    .font(.system(size: 15))
                    .foregroundColor(AppTheme.textSecondary)
            }

            // 进度条 + 时间
            VStack(spacing: AppSpacing.sm) {
                Slider(
                    value: isDragging ? $dragTime : $viewModel.currentTime,
                    in: 0...max(viewModel.duration, 1),
                    onEditingChanged: { editing in
                        isDragging = editing
                        if editing {
                            dragTime = viewModel.currentTime
                        } else {
                            viewModel.seek(to: dragTime)
                        }
                    }
                )
                .accentColor(Color(hex: session.category.themeColor))
                .disabled(viewModel.isLoading || viewModel.duration <= 0)

                HStack {
                    Text(formatTime(isDragging ? dragTime : viewModel.currentTime))
                        .font(.system(size: 13, design: .monospaced))
                        .foregroundColor(AppTheme.textSecondary)
                    Spacer()
                    Text(formatTime(viewModel.duration))
                        .font(.system(size: 13, design: .monospaced))
                        .foregroundColor(AppTheme.textMuted)
                }
            }
            .padding(.horizontal, AppSpacing.lg)

            // 播放/暂停按钮
            Button(action: { viewModel.togglePlayPause() }) {
                ZStack {
                    Circle()
                        .fill(Color(hex: session.category.themeColor).opacity(0.15))
                        .frame(width: 80, height: 80)

                    if viewModel.isLoading {
                        ProgressView()
                    } else {
                        Image(systemName: viewModel.isPlaying ? "pause.fill" : "play.fill")
                            .font(.system(size: 32))
                            .foregroundColor(Color(hex: "5A7A8A"))
                    }
                }
            }
            .disabled(viewModel.isLoading)

            // 信息提示
            if let error = viewModel.errorMessage {
                Text(error)
                    .font(.system(size: 13))
                    .foregroundColor(AppTheme.error)
                    .padding(.horizontal)
            } else if viewModel.isLoading {
                Text("正在准备音频...")
                    .font(.system(size: 13))
                    .foregroundColor(AppTheme.textSecondary)
            } else {
                hintText
                    .font(.system(size: 14))
                    .foregroundColor(AppTheme.textMuted)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, AppSpacing.lg)
            }

            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(AppTheme.background)
        .navigationTitle("冥想播放")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(false)
        .onDisappear { viewModel.stop() }
        .task {
            await viewModel.load(session: session)
        }
    }

    // MARK: - Audio Visualizer (animated breathing ring)

    private var audioVisualizer: some View {
        ZStack {
            Circle()
                .stroke(Color(hex: session.category.themeColor).opacity(0.15), lineWidth: 2)
                .frame(width: 180, height: 180)

            Circle()
                .trim(from: 0, to: viewModel.duration > 0
                    ? CGFloat(viewModel.currentTime / viewModel.duration)
                    : 0)
                .stroke(
                    Color(hex: session.category.themeColor),
                    style: StrokeStyle(lineWidth: 3, lineCap: .round)
                )
                .frame(width: 180, height: 180)
                .rotationEffect(.degrees(-90))
                .animation(.linear(duration: 0.25), value: viewModel.currentTime)

            VStack(spacing: 4) {
                Image(systemName: session.category.iconName)
                    .font(.system(size: 36))
                    .foregroundColor(Color(hex: session.category.themeColor))
                if viewModel.isPlaying {
                    Text("播放中")
                        .font(.system(size: 13))
                        .foregroundColor(AppTheme.textSecondary)
                }
            }
        }
    }

    private var hintText: some View {
        switch session.category {
        case .sleep:
            return Text("闭上眼睛，跟随音波的节奏缓缓入眠。\n适合睡前聆听，帮助放松身心。")
        case .relax:
            return Text("给自己一段独处的时间。\n让思绪随着音频自然流淌。")
        case .anxiety:
            return Text("接纳此刻的感受，不评判不抗拒。\n让声音带走紧绷与不安。")
        }
    }

    private func formatTime(_ interval: TimeInterval) -> String {
        let total = Int(max(0, interval))
        let m = total / 60
        let s = total % 60
        return String(format: "%d:%02d", m, s)
    }
}
