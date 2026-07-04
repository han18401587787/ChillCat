//
//  CCMeditationView.swift
//  绪安 - 治愈空间 (严格对照设计稿 page_21 像素级还原)
//

import SwiftUI
import Combine

struct CCMeditationView: View {
    @Environment(CCAppCoordinator.self) private var coordinator
    @State private var breathing = false
    @State private var breathPhase = "吸气"
    @State private var timerRunning = false
    @State private var secondsElapsed = 0
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    @State private var selectedAudio: HealingAudioType? = nil

    var body: some View {
        ScrollView {
            VStack(spacing: XuanSpacing.xl2) {
                // 1. 冥想练习卡片
                meditationSection

                // 2. 治愈音频
                healingAudioSection

                // 3. 呼吸训练
                breathingSection
            }
            .padding(XuanSpacing.lg)
        }
        .background(Color.xuanApricotBg)
        .navigationTitle("治愈空间")
        .navigationBarTitleDisplayMode(.large)
        .onDisappear { timerRunning = false; breathing = false }
        .onReceive(timer) { _ in
            guard timerRunning else { return }
            secondsElapsed += 1
            let cycle = secondsElapsed % 19
            switch cycle {
            case 0..<4:  breathPhase = "吸气"
            case 4..<11: breathPhase = "屏息"
            default:     breathPhase = "呼气"
            }
        }
    }

    // MARK: - 冥想练习
    private var meditationSection: some View {
        VStack(alignment: .leading, spacing: XuanSpacing.md) {
            Text("冥想练习")
                .font(XuanFont.h2)
                .foregroundColor(Color.xuanTextPrimary)

            VStack(spacing: XuanSpacing.sm) {
                ForEach(CCMeditationSession.presets) { session in
                    meditationCard(session)
                }
            }
        }
    }

    private func meditationCard(_ session: CCMeditationSession) -> some View {
        NavigationLink(value: CCAppRoute.meditationPlayer(session: session)) {
            HStack(spacing: XuanSpacing.md) {
                // 图标
                ZStack {
                    RoundedRectangle(cornerRadius: XuanRadius.md)
                        .fill(Color(hex: session.category.themeColor).opacity(0.12))
                        .frame(width: 56, height: 56)
                    CCIconMapper.image(for: session.category.iconName)
                        .font(.system(size: 24))
                        .foregroundColor(Color(hex: session.category.themeColor))
                }

                // 文字
                VStack(alignment: .leading, spacing: 4) {
                    Text(session.title)
                        .font(XuanFont.bodyLBold)
                        .foregroundColor(Color.xuanTextPrimary)
                    Text(session.category.subtitle)
                        .font(XuanFont.bodyS)
                        .foregroundColor(Color.xuanTextSecondary)
                }

                Spacer()

                // 时长标签
                Text(session.category.subtitle)
                    .font(XuanFont.caption)
                    .foregroundColor(Color.xuanTextTertiary)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.xuanSurface)
                    .cornerRadius(XuanRadius.sm)

                // 播放按钮
                ZStack {
                    Circle()
                        .fill(Color(hex: session.category.themeColor).opacity(0.1))
                        .frame(width: 36, height: 36)
                    Image("healing_course")
                        .font(.system(size: 14))
                        .foregroundColor(Color(hex: session.category.themeColor))
                }
            }
            .padding(XuanSpacing.lg)
            .background(Color.xuanWhite)
            .cornerRadius(XuanRadius.lg)
            .xuanCardShadow()
        }
    }

    // MARK: - 治愈音频
    private var healingAudioSection: some View {
        VStack(alignment: .leading, spacing: XuanSpacing.md) {
            Text("治愈音频")
                .font(XuanFont.h2)
                .foregroundColor(Color.xuanTextPrimary)

            VStack(spacing: XuanSpacing.sm) {
                audioCard(
                    type: .rain,
                    title: "白噪音·雨声",
                    subtitle: "淅沥雨声，平静思绪",
                    icon: "cloud.rain.fill",
                    color: Color.xuanInfo
                )
                audioCard(
                    type: .forest,
                    title: "森林声音",
                    subtitle: "鸟鸣与风吹树叶",
                    icon: "leaf.fill",
                    color: Color.xuanSuccess
                )
                audioCard(
                    type: .piano,
                    title: "钢琴曲",
                    subtitle: "舒缓古典钢琴，放松身心",
                    icon: "music.quarternote.3",
                    color: Color(hex: "A085C6")
                )
            }
        }
    }

    private func audioCard(type: HealingAudioType, title: String, subtitle: String, icon: String, color: Color) -> some View {
        Button(action: {
            selectedAudio = (selectedAudio == type) ? nil : type
        }) {
            HStack(spacing: XuanSpacing.md) {
                ZStack {
                    RoundedRectangle(cornerRadius: XuanRadius.md)
                        .fill(color.opacity(0.12))
                        .frame(width: 56, height: 56)
                    CCIconMapper.image(for: icon)
                        .font(.system(size: 24))
                        .foregroundColor(color)
                }

                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(XuanFont.bodyLBold)
                        .foregroundColor(Color.xuanTextPrimary)
                    Text(subtitle)
                        .font(XuanFont.bodyS)
                        .foregroundColor(Color.xuanTextSecondary)
                }

                Spacer()

                ZStack {
                    Circle()
                        .fill(selectedAudio == type ? color : color.opacity(0.1))
                        .frame(width: 40, height: 40)
                    CCIconMapper.image(for: selectedAudio == type ? "pause.fill" : "play.fill")
                        .font(.system(size: 16))
                        .foregroundColor(selectedAudio == type ? .white : color)
                }
                .animation(.easeInOut(duration: 0.2), value: selectedAudio)
            }
            .padding(XuanSpacing.lg)
            .background(Color.xuanWhite)
            .cornerRadius(XuanRadius.lg)
            .xuanCardShadow()
        }
        .accessibilityIdentifier("healing_audio_\(title)")
    }

    // MARK: - 呼吸训练
    private var breathingSection: some View {
        VStack(alignment: .leading, spacing: XuanSpacing.md) {
            Text("呼吸训练")
                .font(XuanFont.h2)
                .foregroundColor(Color.xuanTextPrimary)

            VStack(spacing: XuanSpacing.lg) {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("4-7-8 呼吸法")
                            .font(XuanFont.h3)
                            .foregroundColor(Color.xuanTextPrimary)
                        Text("经典放松呼吸法，缓解焦虑")
                            .font(XuanFont.bodyS)
                            .foregroundColor(Color.xuanTextSecondary)
                    }
                    Spacer()
                }

                // 呼吸动画
                ZStack {
                    Circle()
                        .stroke(Color.xuanMint.opacity(0.15), lineWidth: 3)
                        .frame(width: 180, height: 180)

                    Circle()
                        .trim(from: 0, to: breathing ? 1 : 0.4)
                        .stroke(
                            LinearGradient(
                                colors: [Color.xuanMint, Color.xuanMintDark],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            style: StrokeStyle(lineWidth: 3, lineCap: .round)
                        )
                        .frame(width: 180, height: 180)
                        .rotationEffect(.degrees(-90))
                        .animation(breathing ? .easeInOut(duration: 4).repeatForever() : .default, value: breathing)

                    VStack(spacing: XuanSpacing.sm) {
                        Text(breathPhase)
                            .font(.system(size: 28, weight: .light))
                            .foregroundColor(Color.xuanMintDark)

                        if timerRunning {
                            Text(String(format: "%d:%02d", secondsElapsed / 60, secondsElapsed % 60))
                                .font(XuanFont.bodyS)
                                .foregroundColor(Color.xuanTextSecondary)
                                .monospacedDigit()
                        }
                    }
                }
                .frame(maxWidth: .infinity)

                Button(action: {
                    CCHaptic.light()
                    breathing.toggle()
                    timerRunning.toggle()
                    if !breathing { secondsElapsed = 0 }
                }) {
                    HStack(spacing: XuanSpacing.sm) {
                        CCIconMapper.image(for: breathing ? "stop.fill" : "play.fill")
                            .font(.system(size: 16))
                        Text(breathing ? "结束练习" : "开始练习")
                            .font(XuanFont.bodyLMedium)
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(Color.xuanMint)
                    .cornerRadius(XuanRadius.lg)
                }
                .accessibilityIdentifier("healing_breathing_button")
            }
            .padding(XuanSpacing.xl)
            .background(Color.xuanWhite)
            .cornerRadius(XuanRadius.lg)
            .xuanCardShadow()
        }
    }
}

// MARK: - 治愈音频类型
enum HealingAudioType {
    case rain, forest, piano
}
