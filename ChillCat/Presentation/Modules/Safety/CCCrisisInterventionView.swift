import SwiftUI

// MARK: - CrisisInterventionView v3.0
/// 危机干预页面
/// 安全协议触发时替换对话区域
/// 包含：热线电话、稳情练习快捷入口、温暖视觉设计

struct CCCrisisInterventionView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var showHealingPlan = false
    @State private var animateIn = false
    
    var body: some View {
        ZStack {
            // 温暖渐变背景
            LinearGradient(
                colors: [
                    AppTheme.roseGoldLight,
                    AppTheme.warmGlowLight,
                    AppTheme.background
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: AppSpacing.xxl) {
                    Spacer(minLength: 20)
                    
                    // 温暖图标
                    warmIcon
                        .opacity(animateIn ? 1 : 0)
                        .scaleEffect(animateIn ? 1 : 0.5)
                        .offset(y: animateIn ? 0 : 30)
                    
                    // 标题和正文
                    VStack(spacing: AppSpacing.md) {
                        Text("我们注意到你\n可能正在经历困难时刻")
                            .font(AppFont.title1)
                            .foregroundColor(AppTheme.textPrimary)
                            .multilineTextAlignment(.center)
                            .lineSpacing(8)
                        
                        Text("你不是一个人，我们在这里陪伴你\n请给自己一点时间，也请考虑寻求帮助")
                            .font(AppFont.body)
                            .foregroundColor(AppTheme.textSecondary)
                            .multilineTextAlignment(.center)
                            .lineSpacing(6)
                    }
                    .opacity(animateIn ? 1 : 0)
                    .offset(y: animateIn ? 0 : 20)
                    
                    // 热线电话卡片
                    hotlineCard
                        .opacity(animateIn ? 1 : 0)
                        .offset(y: animateIn ? 0 : 20)
                    
                    // 稳情练习快捷入口
                    healingExercisesSection
                        .opacity(animateIn ? 1 : 0)
                        .offset(y: animateIn ? 0 : 20)
                    
                    // 温暖寄语
                    warmMessage
                        .opacity(animateIn ? 1 : 0)
                    
                    // 底部按钮
                    bottomButtons
                        .opacity(animateIn ? 1 : 0)
                    
                    Spacer(minLength: 40)
                }
                .padding(.horizontal, AppSpacing.lg)
            }
        }
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.7).delay(0.1)) {
                animateIn = true
            }
        }
        .fullScreenCover(isPresented: $showHealingPlan) {
            NavigationStack {
                CCHealingPlanView()
            }
        }
    }
    
    // MARK: - Warm Icon
    private var warmIcon: some View {
        ZStack {
            // 外层柔和光晕
            ForEach(0..<3) { i in
                Circle()
                    .stroke(
                        AppTheme.warmGlow.opacity(0.15 - Double(i) * 0.05),
                        lineWidth: 1
                    )
                    .frame(width: 120 + CGFloat(i) * 40, height: 120 + CGFloat(i) * 40)
            }
            
            // 心跳动画
            Circle()
                .fill(
                    RadialGradient(
                        colors: [AppTheme.roseGold.opacity(0.2), Color.clear],
                        center: .center,
                        startRadius: 0,
                        endRadius: 60
                    )
                )
                .frame(width: 120, height: 120)
            
            // 手中捧着心
            VStack(spacing: 4) {
                Image(systemName: "heart.fill")
                    .font(.system(size: 36))
                    .foregroundColor(AppTheme.roseGold)
                    .scaleEffect(animateIn ? 1.05 : 0.95)
                    .animation(
                        .easeInOut(duration: 1.5).repeatForever(autoreverses: true),
                        value: animateIn
                    )
                
                Image(systemName: "hands.and.sparkles.fill")
                    .font(.system(size: 24))
                    .foregroundColor(AppTheme.warmGlow)
            }
        }
        .padding(.top, AppSpacing.xxl)
    }
    
    // MARK: - Hotline Card
    private var hotlineCard: some View {
        VStack(spacing: AppSpacing.lg) {
            VStack(spacing: AppSpacing.md) {
                Image(systemName: "phone.circle.fill")
                    .font(.system(size: 40))
                    .foregroundColor(AppTheme.safeGreen)
                
                Text("24小时心理援助热线")
                    .font(AppFont.bodyBold)
                    .foregroundColor(AppTheme.textPrimary)
                
                Text("400-161-9995")
                    .font(.system(size: 36, weight: .bold, design: .monospaced))
                    .foregroundColor(AppTheme.primary)
            }
            
            // 一键拨打按钮
            Link(destination: URL(string: "tel://4001619995")!) {
                HStack(spacing: AppSpacing.sm) {
                    Image(systemName: "phone.fill")
                    Text("一键拨打热线")
                }
                .font(AppFont.bodyBold)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(
                    LinearGradient(
                        colors: [AppTheme.safeGreen, AppTheme.safeGreenDark],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .clipShape(RoundedRectangle(cornerRadius: AppRadius.lg))
                .shadow(color: AppTheme.safeGreen.opacity(0.3), radius: 8, x: 0, y: 4)
            }
            
            Text("免费、保密、24小时在线")
                .font(AppFont.footnote)
                .foregroundColor(AppTheme.textTertiary)
        }
        .padding(AppSpacing.xl)
        .background(
            RoundedRectangle(cornerRadius: AppRadius.xl)
                .fill(AppTheme.surface)
                .shadow(color: .black.opacity(0.06), radius: 12, x: 0, y: 4)
        )
        .overlay(
            RoundedRectangle(cornerRadius: AppRadius.xl)
                .stroke(AppTheme.safeGreen.opacity(0.2), lineWidth: 1)
        )
    }
    
    // MARK: - Healing Exercises
    private var healingExercisesSection: some View {
        VStack(alignment: .leading, spacing: AppSpacing.md) {
            Text("也许这些可以帮到你")
                .font(AppFont.title3)
                .foregroundColor(AppTheme.textPrimary)
            
            VStack(spacing: AppSpacing.md) {
                HealingExerciseCard(
                    icon: "lungs.fill",
                    title: "4-7-8 呼吸练习",
                    description: "跟随节奏调节呼吸，缓解焦虑",
                    color: AppTheme.calmBlue,
                    action: { showHealingPlan = true }
                )
                
                HealingExerciseCard(
                    icon: "hand.draw.fill",
                    title: "5-4-3-2-1 感官练习",
                    description: "通过感官重新连接当下，稳定情绪",
                    color: AppTheme.softPurple,
                    action: { showHealingPlan = true }
                )
                
                HealingExerciseCard(
                    icon: "text.book.closed.fill",
                    title: "安全地带冥想",
                    description: "在内心构建一个安全舒适的空间",
                    color: AppTheme.mintGreen,
                    action: { showHealingPlan = true }
                )
            }
        }
    }
    
    // MARK: - Warm Message
    private var warmMessage: some View {
        VStack(spacing: AppSpacing.sm) {
            Image(systemName: "quote.bubble.fill")
                .font(.system(size: 20))
                .foregroundColor(AppTheme.warmGlow.opacity(0.5))
            
            Text("你很重要，你的感受也很重要。\n所有的情绪都会过去，就像乌云终会散去。\n给自己一些时间和温柔，你已经很勇敢了。")
                .font(AppFont.caption)
                .foregroundColor(AppTheme.textSecondary)
                .multilineTextAlignment(.center)
                .lineSpacing(6)
                .italic()
        }
        .padding(AppSpacing.xl)
        .background(AppTheme.warmGlow.opacity(0.05))
        .clipShape(RoundedRectangle(cornerRadius: AppRadius.lg))
    }
    
    // MARK: - Bottom Buttons
    private var bottomButtons: some View {
        VStack(spacing: AppSpacing.md) {
            Button {
                showHealingPlan = true
            } label: {
                HStack {
                    Image(systemName: "leaf.fill")
                    Text("开始稳情练习")
                }
            }
            .buttonStyle(ComponentStyles.PrimaryButtonStyle())
            
            Button {
                dismiss()
            } label: {
                Text("返回对话")
                    .font(AppFont.bodyBold)
                    .foregroundColor(AppTheme.textSecondary)
            }
        }
    }
}

// MARK: - Healing Exercise Card
struct HealingExerciseCard: View {
    let icon: String
    let title: String
    let description: String
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: AppSpacing.md) {
                ZStack {
                    Circle()
                        .fill(color.opacity(0.15))
                        .frame(width: 48, height: 48)
                    
                    Image(systemName: icon)
                        .font(.system(size: 22))
                        .foregroundColor(color)
                }
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(AppFont.bodyBold)
                        .foregroundColor(AppTheme.textPrimary)
                    
                    Text(description)
                        .font(AppFont.footnote)
                        .foregroundColor(AppTheme.textSecondary)
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.system(size: 14))
                    .foregroundColor(AppTheme.textTertiary)
            }
            .padding(AppSpacing.lg)
            .background(AppTheme.surface)
            .clipShape(RoundedRectangle(cornerRadius: AppRadius.lg))
            .shadow(color: .black.opacity(0.03), radius: 4, x: 0, y: 1)
        }
    }
}

#Preview {
    CCCrisisInterventionView()
}
