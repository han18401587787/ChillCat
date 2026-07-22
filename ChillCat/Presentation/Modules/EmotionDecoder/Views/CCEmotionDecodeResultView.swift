//
//  CCEmotionDecodeResultView.swift
//  绪安 - 情绪解码结果页 (严格对照设计稿 page_39 像素级还原)
//

import SwiftUI

struct CCEmotionDecodeResultView: View {
    @Environment(CCAppCoordinator.self) private var coordinator

    // 示例数据
    let emotionType: String = "焦虑"
    let intensity: Int = 7
    let surfaceEmotion: String = "对下个月绩效考核感到心慌和不安，担心自己表现不够好，害怕被否定。"
    let middleEmotion: String = "对不确定性的恐惧、完美主义倾向。害怕犯错，害怕不被认可——这是对「未知结果」的本能焦虑反应。"
    let suggestion: String = "今晚尝试「4-7-8 呼吸法」助眠。明天可以写一篇「我过去的成功经历」，把注意力从「我会不会失败」转移到「我已经做到了什么」。"
    let deepNeed: String = "你渴望安全感与被认可。希望自己的努力被看见。这是非常正常的人类需求——我们都需要确认自己的价值。"

    var body: some View {
        ScrollView {
            VStack(spacing: XuanSpacing.xl2) {
                // 情绪强度标签
                emotionTag

                // 表层情绪
                surfaceCard

                // 中层情绪
                middleCard

                // 个性化建议
                suggestionCard

                // 深层需求
                deepNeedCard

                // 底部按钮
                bottomActions

                // 免责声明
                disclaimer
            }
            .padding(XuanSpacing.lg)
        }
        .background(Color.xuanApricotBg)
        .navigationTitle("情绪解码")
        .navigationBarTitleDisplayMode(.inline)
    }

    // MARK: - 情绪强度标签
    private var emotionTag: some View {
        Text("\(emotionType) · 强度 \(intensity)/10")
            .font(XuanFont.bodyLBold)
            .foregroundColor(Color(hex: "A085C6"))
            .padding(.horizontal, XuanSpacing.xl)
            .padding(.vertical, XuanSpacing.sm)
            .background(Color(hex: "A085C6").opacity(0.1))
            .cornerRadius(XuanRadius.full)
    }

    // MARK: - 表层情绪卡片
    private var surfaceCard: some View {
        VStack(alignment: .leading, spacing: XuanSpacing.md) {
            HStack(spacing: XuanSpacing.sm) {
                Image("common_search")
                    .font(.system(size: 14))
                    .foregroundColor(Color.xuanTextSecondary)
                Text("表层情绪")
                    .font(XuanFont.bodyS)
                    .foregroundColor(Color.xuanTextSecondary)
            }

            Text(surfaceEmotion)
                .font(XuanFont.bodyL)
                .foregroundColor(Color.xuanTextPrimary)
                .lineSpacing(6)
        }
        .padding(XuanSpacing.lg)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.xuanWhite)
        .cornerRadius(XuanRadius.lg)
        .xuanCardShadow()
    }

    // MARK: - 中层情绪卡片
    private var middleCard: some View {
        VStack(alignment: .leading, spacing: XuanSpacing.md) {
            HStack(spacing: XuanSpacing.sm) {
                Text("🧠")
                    .font(.system(size: 14))
                Text("中层情绪")
                    .font(XuanFont.bodyS)
                    .foregroundColor(Color.xuanTextSecondary)
            }

            Text(middleEmotion)
                .font(XuanFont.bodyL)
                .foregroundColor(Color.xuanTextPrimary)
                .lineSpacing(6)
        }
        .padding(XuanSpacing.lg)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.xuanWhite)
        .cornerRadius(XuanRadius.lg)
        .xuanCardShadow()
    }

    // MARK: - 个性化建议卡片
    private var suggestionCard: some View {
        VStack(alignment: .leading, spacing: XuanSpacing.md) {
            HStack(spacing: XuanSpacing.sm) {
                Image("healing_meditate")
                    .font(.system(size: 14))
                    .foregroundColor(Color.xuanMint)
                Text("个性化建议")
                    .font(XuanFont.bodyS)
                    .foregroundColor(Color.xuanMint)
            }

            Text(suggestion)
                .font(XuanFont.bodyL)
                .foregroundColor(Color.xuanTextPrimary)
                .lineSpacing(6)
        }
        .padding(XuanSpacing.lg)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.xuanMintLight)
        .cornerRadius(XuanRadius.lg)
    }

    // MARK: - 深层需求卡片
    private var deepNeedCard: some View {
        VStack(alignment: .leading, spacing: XuanSpacing.md) {
            HStack(spacing: XuanSpacing.sm) {
                Image("resonance_like")
                    .font(.system(size: 14))
                    .foregroundColor(Color.xuanPink)
                Text("深层需求")
                    .font(XuanFont.bodyS)
                    .foregroundColor(Color.xuanTextSecondary)
            }

            Text(deepNeed)
                .font(XuanFont.bodyL)
                .foregroundColor(Color.xuanTextPrimary)
                .lineSpacing(6)
        }
        .padding(XuanSpacing.lg)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.xuanApricotBg)
        .cornerRadius(XuanRadius.lg)
        .xuanCardShadow()
    }

    // MARK: - 底部操作按钮
    private var bottomActions: some View {
        HStack(spacing: XuanSpacing.md) {
            Button(action: {
                coordinator.navigate(to: .aiListener)
            }) {
                Text("继续和AI聊聊")
                    .font(XuanFont.bodyLMedium)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(Color.xuanApricot)
                    .cornerRadius(XuanRadius.lg)
            }
            .accessibilityIdentifier("decode_continue_chat")

            Button(action: {
                coordinator.navigate(to: .resonanceWall)
            }) {
                Text("匿名分享")
                    .font(XuanFont.bodyLMedium)
                    .foregroundColor(Color.xuanPink)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(Color.xuanPinkLight)
                    .cornerRadius(XuanRadius.lg)
            }
            .accessibilityIdentifier("decode_share_anonymous")
        }
    }

    // MARK: - 免责声明
    private var disclaimer: some View {
        Text("情绪解码结果由AI生成，仅供参考，不能替代专业心理治疗")
            .font(XuanFont.caption)
            .foregroundColor(Color.xuanTextTertiary)
            .multilineTextAlignment(.center)
            .padding(.top, XuanSpacing.sm)
    }
}

// MARK: - Preview
#Preview {
    NavigationStack {
        CCEmotionDecodeResultView()
    }
}
