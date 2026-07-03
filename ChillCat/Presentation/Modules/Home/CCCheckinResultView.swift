//
//  CCCheckinResultView.swift
//  绪安 - 打卡成功页
//
//  设计规范: 绪安设计系统 v3.0
//  布局: AI倾听官头像+在线状态 → 打卡成功提示+情绪标签+陪伴天数 → AI回应卡片 → 操作按钮组

import SwiftUI

// MARK: - CCCheckinResultView

struct CCCheckinResultView: View {
    @Environment(CCAppCoordinator.self) private var coordinator
    @Environment(\.dismiss) private var dismiss

    @State private var animateEntrance = false
    @State private var showAIResponse = false
    @State private var animateButtons = false

    // 打卡数据（后续可接入 ViewModel）
    @State private var emotionLabel = "平静"
    @State private var companionDays = 7
    @State private var aiResponse = "你今天的状态很平稳，内心的宁静是一种珍贵的力量。记得给自己一些温柔的肯定，你已经做得很好了。🌿"
    @State private var aiListenerName = "绪安"
    @State private var isOnline = true

    var body: some View {
        ScrollView {
            VStack(spacing: XuanSpacing.xl3) {
                // 1. AI倾听官头像区域
                aiListenerHeader
                    .opacity(animateEntrance ? 1 : 0)
                    .offset(y: animateEntrance ? 0 : 20)

                // 2. 打卡成功提示区
                checkinSuccessSection
                    .opacity(animateEntrance ? 1 : 0)
                    .offset(y: animateEntrance ? 0 : 20)

                // 3. AI回应卡片
                if showAIResponse {
                    aiResponseCard
                        .transition(
                            .opacity
                                .combined(with: .move(edge: .bottom))
                                .combined(with: .scale(scale: 0.95))
                        )
                }

                // 4. 操作按钮组
                if animateButtons {
                    actionButtonsSection
                        .transition(.opacity.combined(with: .move(edge: .bottom)))
                }
            }
            .padding(.horizontal, XuanSpacing.lg)
            .padding(.top, XuanSpacing.xl2)
            .padding(.bottom, XuanSpacing.xl3)
        }
        .background(Color.xuanApricotBg)
        .navigationBarBackButtonHidden(false)
        .onAppear {
            withAnimation(.easeOut(duration: 0.5)) {
                animateEntrance = true
            }
            withAnimation(.spring(response: 0.5, dampingFraction: 0.7).delay(0.3)) {
                showAIResponse = true
            }
            withAnimation(.easeOut(duration: 0.4).delay(0.6)) {
                animateButtons = true
            }
        }
    }

    // MARK: - 1. AI倾听官头像区域
    private var aiListenerHeader: some View {
        VStack(spacing: XuanSpacing.md) {
            ZStack {
                // 外圈光环
                Circle()
                    .fill(Color.xuanApricot.opacity(0.15))
                    .frame(width: 88, height: 88)

                // Lottie 情绪动画
                CCEmotionAnimationView(
                    emotion: emotionLabel,
                    level: 2,
                    loopMode: .loop,
                    size: 72
                )

                // 在线状态点
                Circle()
                    .fill(isOnline ? Color.xuanSuccess : Color.xuanTextTertiary)
                    .frame(width: 14, height: 14)
                    .overlay(
                        Circle()
                            .stroke(Color.xuanWhite, lineWidth: 2)
                    )
                    .offset(x: 28, y: 28)
            }

            VStack(spacing: XuanSpacing.xs) {
                Text(aiListenerName)
                    .font(XuanFont.h3)
                    .foregroundColor(Color.xuanTextPrimary)

                HStack(spacing: XuanSpacing.xs) {
                    ComponentStyles.PulseIndicator(color: Color.xuanSuccess)
                        .frame(width: 8, height: 8)

                    Text(isOnline ? "在线" : "离线")
                        .font(XuanFont.bodyS)
                        .foregroundColor(isOnline ? Color.xuanSuccess : Color.xuanTextTertiary)
                }
            }
        }
    }

    // MARK: - 2. 打卡成功提示区
    private var checkinSuccessSection: some View {
        VStack(spacing: XuanSpacing.md) {
            Text("今日已打卡 ✨")
                .font(XuanFont.h1)
                .foregroundColor(Color.xuanTextPrimary)

            // 情绪标签
            Text(emotionLabel)
                .font(XuanFont.h3)
                .foregroundColor(Color.xuanApricotDark)
                .padding(.horizontal, XuanSpacing.lg)
                .padding(.vertical, XuanSpacing.sm)
                .background(Color.xuanApricot.opacity(0.15))
                .cornerRadius(XuanRadius.full)

            // 陪伴天数
            HStack(spacing: XuanSpacing.xs) {
                Image(systemName: "heart.fill")
                    .font(.system(size: 14))
                    .foregroundColor(Color.xuanPink)

                Text("已陪伴你 ")
                    .font(XuanFont.bodyM)
                    .foregroundColor(Color.xuanTextSecondary)
                +
                Text("\(companionDays)")
                    .font(XuanFont.bodyLBold)
                    .foregroundColor(Color.xuanApricotDark)
                +
                Text(" 天")
                    .font(XuanFont.bodyM)
                    .foregroundColor(Color.xuanTextSecondary)
            }
        }
    }

    // MARK: - 3. AI回应卡片
    private var aiResponseCard: some View {
        VStack(alignment: .leading, spacing: XuanSpacing.md) {
            HStack(spacing: XuanSpacing.sm) {
                ZStack {
                    Circle()
                        .fill(Color.xuanApricot.opacity(0.25))
                        .frame(width: 36, height: 36)
                    Image(systemName: "sparkles")
                        .font(.system(size: 14))
                        .foregroundColor(Color.xuanApricotDark)
                }

                Text("绪安的回应")
                    .font(XuanFont.bodyLBold)
                    .foregroundColor(Color.xuanTextPrimary)

                Spacer()

                Text("刚刚")
                    .font(XuanFont.bodyS)
                    .foregroundColor(Color.xuanTextTertiary)
            }

            Text(aiResponse)
                .font(XuanFont.bodyL)
                .foregroundColor(Color.xuanTextPrimary)
                .lineSpacing(6)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(XuanSpacing.lg)
        .background(
            RoundedRectangle(cornerRadius: XuanRadius.lg)
                .fill(Color.xuanApricot.opacity(0.12))
        )
        .overlay(
            RoundedRectangle(cornerRadius: XuanRadius.lg)
                .stroke(Color.xuanApricot.opacity(0.2), lineWidth: 1)
        )
        .xuanCardShadow()
    }

    // MARK: - 4. 操作按钮组
    private var actionButtonsSection: some View {
        VStack(spacing: XuanSpacing.md) {
            // 主按钮: 继续和绪安聊聊
            Button(action: {
                coordinator.navigate(to: .aiListener)
            }) {
                HStack(spacing: XuanSpacing.sm) {
                    Image(systemName: "bubble.left.and.bubble.right.fill")
                        .font(.system(size: 16))
                    Text("继续和绪安聊聊")
                        .font(XuanFont.bodyLBold)
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(Color.xuanApricot)
                .cornerRadius(XuanRadius.lg)
                .xuanCardShadow()
            }
            .buttonStyle(.plain)

            // 次按钮: 发布到共鸣墙
            Button(action: {
                coordinator.navigate(to: .resonanceWall)
            }) {
                HStack(spacing: XuanSpacing.sm) {
                    Image(systemName: "waveform.circle")
                        .font(.system(size: 16))
                    Text("发布到共鸣墙")
                        .font(XuanFont.bodyLBold)
                }
                .foregroundColor(Color.xuanApricotDark)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(Color.xuanApricotLight)
                .cornerRadius(XuanRadius.lg)
                .overlay(
                    RoundedRectangle(cornerRadius: XuanRadius.lg)
                        .stroke(Color.xuanApricot.opacity(0.3), lineWidth: 1)
                )
            }
            .buttonStyle(.plain)

            // 文字按钮: 查看情绪解码
            Button(action: {
                coordinator.navigate(to: .emotionDecoder)
            }) {
                HStack(spacing: XuanSpacing.xs) {
                    Text("查看情绪解码")
                        .font(XuanFont.bodyLBold)
                        .foregroundColor(Color.xuanApricot)
                    Image(systemName: "chevron.right")
                        .font(.system(size: 12))
                        .foregroundColor(Color.xuanApricot)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 10)
            }
            .buttonStyle(.plain)
        }
    }
}

// MARK: - Preview
#Preview {
    NavigationStack {
        CCCheckinResultView()
    }
}
