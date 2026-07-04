//
//  CCRainSoundView.swift
//  绪安 - 雨声助眠页
//
//  设计规范: 绪安设计系统 v3.0
//  布局: 标题+关闭按钮 → 雨滴动画区 → 进度条+时间 → 播放控制(后退/播放暂停/前进) → 定时关闭选项

import SwiftUI

// MARK: - CCRainSoundView

struct CCRainSoundView: View {
    @Environment(CCAppCoordinator.self) private var coordinator
    @Environment(\.dismiss) private var dismiss

    @State private var isPlaying = false
    @State private var currentTime: Double = 0
    @State private var totalDuration: Double = 1800 // 30分钟
    @State private var timerOption: TimerOption = .none
    @State private var animateRaindrops = false

    // 雨滴数据
    private let raindropPositions: [(x: CGFloat, y: CGFloat, size: CGFloat, delay: Double)] = [
        (0.15, -0.1, 12, 0.0), (0.35, -0.3, 8, 0.4), (0.55, -0.15, 10, 0.2),
        (0.75, -0.35, 7, 0.6), (0.90, -0.05, 11, 0.3), (0.25, -0.5, 9, 0.1),
        (0.45, -0.25, 13, 0.5), (0.65, -0.45, 6, 0.35), (0.85, -0.2, 10, 0.55),
        (0.10, -0.6, 8, 0.15), (0.50, -0.7, 11, 0.25), (0.80, -0.55, 9, 0.45),
    ]

    enum TimerOption: Int, CaseIterable {
        case none = 0
        case fifteen = 15
        case thirty = 30
        case sixty = 60

        var label: String {
            switch self {
            case .none:    return "不自动关闭"
            case .fifteen: return "15分钟"
            case .thirty:  return "30分钟"
            case .sixty:   return "60分钟"
            }
        }
    }

    var body: some View {
        VStack(spacing: 0) {
            // 1. 顶部标题栏
            headerBar

            Spacer().frame(height: XuanSpacing.xl2)

            // 2. 雨滴动画区域
            raindropAnimationArea

            Spacer().frame(height: XuanSpacing.xl)

            // 3. 进度条 + 时间
            progressSection
                .padding(.horizontal, XuanSpacing.xl2)

            Spacer().frame(height: XuanSpacing.xl)

            // 4. 播放控制栏
            playbackControls

            Spacer().frame(height: XuanSpacing.xl)

            // 5. 定时关闭选项
            timerOptionsSection
                .padding(.horizontal, XuanSpacing.lg)

            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.xuanApricotBg)
        .navigationBarHidden(true)
        .onAppear {
            withAnimation(
                .linear(duration: 2.5)
                    .repeatForever(autoreverses: false)
            ) {
                animateRaindrops = true
            }
        }
        .onDisappear {
            isPlaying = false
        }
    }

    // MARK: - 1. 顶部标题栏
    private var headerBar: some View {
        HStack {
            Text("雨声助眠")
                .font(XuanFont.h2)
                .foregroundColor(Color.xuanTextPrimary)

            Spacer()

            Button(action: {
                dismiss()
            }) {
                Image("common_close")
                    .font(.system(size: 28))
                    .foregroundColor(Color.xuanTextTertiary)
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, XuanSpacing.lg)
        .padding(.top, XuanSpacing.lg)
    }

    // MARK: - 2. 雨滴动画区域
    private var raindropAnimationArea: some View {
        ZStack {
            // 外圈装饰圆
            Circle()
                .stroke(Color.xuanInfo.opacity(0.15), lineWidth: 2)
                .frame(width: 220, height: 220)

            Circle()
                .stroke(Color.xuanInfo.opacity(0.08), lineWidth: 1)
                .frame(width: 260, height: 260)

            // 雨滴
            GeometryReader { geometry in
                let size = geometry.size

                ZStack {
                    ForEach(raindropPositions.indices, id: \.self) { index in
                        let drop = raindropPositions[index]
                        let xPos = drop.x * size.width
                        let baseY = drop.y * size.height
                        let targetY = size.height + 30

                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: [Color.xuanInfo.opacity(0.4), Color.xuanInfo.opacity(0.15)],
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                            )
                            .frame(width: drop.size, height: drop.size * 1.8)
                            .clipShape(Capsule())
                            .position(
                                x: xPos,
                                y: animateRaindrops ? targetY : baseY
                            )
                            .animation(
                                .linear(duration: 2.5)
                                    .repeatForever(autoreverses: false)
                                    .delay(drop.delay),
                                value: animateRaindrops
                            )
                    }
                }
            }
            .frame(width: 240, height: 240)
            .clipped()

            // 中心图标
            VStack(spacing: XuanSpacing.sm) {
                Image("emotion_sad")
                    .font(.system(size: 48))
                    .foregroundColor(Color.xuanInfo.opacity(0.7))

                if isPlaying {
                    Text("雨声淅沥...")
                        .font(XuanFont.bodyS)
                        .foregroundColor(Color.xuanTextSecondary)
                        .transition(.opacity)
                }
            }
        }
        .frame(width: 260, height: 260)
    }

    // MARK: - 3. 进度条+时间
    private var progressSection: some View {
        VStack(spacing: XuanSpacing.sm) {
            // 进度条
            Slider(value: $currentTime, in: 0...max(totalDuration, 1))
                .accentColor(Color.xuanInfo)
                .disabled(!isPlaying)

            // 时间显示
            HStack {
                Text(formatTime(currentTime))
                    .font(.system(size: 13, design: .monospaced))
                    .foregroundColor(Color.xuanTextSecondary)
                Spacer()
                Text("-\(formatTime(max(0, totalDuration - currentTime)))")
                    .font(.system(size: 13, design: .monospaced))
                    .foregroundColor(Color.xuanTextTertiary)
            }
        }
    }

    // MARK: - 4. 播放控制栏
    private var playbackControls: some View {
        HStack(spacing: XuanSpacing.xl3) {
            // 后退15s
            Button(action: {
                currentTime = max(0, currentTime - 15)
            }) {
                VStack(spacing: XuanSpacing.xs) {
                    Image("common_refresh")
                        .font(.system(size: 22))
                    Text("15s")
                        .font(XuanFont.caption)
                }
                .foregroundColor(Color.xuanTextSecondary)
                .frame(width: 56, height: 56)
            }
            .buttonStyle(.plain)

            // 播放/暂停 大按钮
            Button(action: {
                isPlaying.toggle()
            }) {
                ZStack {
                    Circle()
                        .fill(Color.xuanInfo.opacity(0.12))
                        .frame(width: 80, height: 80)

                    CCIconMapper.image(for: isPlaying ? "pause.fill" : "play.fill")
                        .font(.system(size: 34))
                        .foregroundColor(Color.xuanInfo)
                        .offset(x: isPlaying ? 0 : 2)
                }
            }
            .buttonStyle(.plain)
            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isPlaying)

            // 前进15s
            Button(action: {
                currentTime = min(totalDuration, currentTime + 15)
            }) {
                VStack(spacing: XuanSpacing.xs) {
                    Image("common_refresh")
                        .font(.system(size: 22))
                    Text("15s")
                        .font(XuanFont.caption)
                }
                .foregroundColor(Color.xuanTextSecondary)
                .frame(width: 56, height: 56)
            }
            .buttonStyle(.plain)
        }
    }

    // MARK: - 5. 定时关闭选项
    private var timerOptionsSection: some View {
        VStack(spacing: XuanSpacing.sm) {
            Text("定时关闭")
                .font(XuanFont.bodyS)
                .foregroundColor(Color.xuanTextTertiary)

            HStack(spacing: XuanSpacing.sm) {
                ForEach(TimerOption.allCases, id: \.self) { option in
                    timerChip(option)
                }
            }
        }
    }

    private func timerChip(_ option: TimerOption) -> some View {
        Button(action: {
            timerOption = option
        }) {
            Text(option.label)
                .font(XuanFont.caption)
                .foregroundColor(timerOption == option ? .white : Color.xuanTextSecondary)
                .padding(.horizontal, XuanSpacing.md)
                .padding(.vertical, XuanSpacing.xs)
                .background(
                    timerOption == option
                        ? Color.xuanInfo
                        : Color.xuanSurface
                )
                .cornerRadius(XuanRadius.full)
        }
        .buttonStyle(.plain)
        .animation(.easeInOut(duration: 0.2), value: timerOption)
    }

    // MARK: - Helpers
    private func formatTime(_ interval: Double) -> String {
        let total = Int(max(0, interval))
        let m = total / 60
        let s = total % 60
        return String(format: "%d:%02d", m, s)
    }
}

// MARK: - Preview
#Preview {
    NavigationStack {
        CCRainSoundView()
    }
}
