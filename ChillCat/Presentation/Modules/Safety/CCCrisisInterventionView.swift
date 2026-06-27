import SwiftUI

// MARK: - CrisisInterventionView v3.0 (Ardot 对照截图 #1 & #11)
/// 安全守护 — 双模式：标准版(暖色系) + 紧急求助版(红色系)
/// 截图 #1 = 紧急求助模式 (红色大按钮 + 热线列表 + 紧急联系人 + 安全计划)
/// 截图 #11 = 标准安全守护 (暖色提示横幅 + 联系人 + 热线 + 练习入口)

struct CCCrisisInterventionView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var showHealingPlan = false
    @State private var animateIn = false

    /// 是否为紧急模式 (红色主题)
    var isEmergency: Bool = false

    var body: some View {
        ZStack {
            // 背景色
            (isEmergency ? AppTheme.crisisRedLight : AppTheme.warmGlowLight)
                .ignoresSafeArea()

            ScrollView {
                VStack(spacing: AppSpacing.xxl) {
                    Spacer(minLength: 20)

                    // 顶部图标
                    topIcon
                        .opacity(animateIn ? 1 : 0)
                        .scaleEffect(animateIn ? 1 : 0.5)
                        .offset(y: animateIn ? 0 : 30)

                    // 标题
                    titleSection
                        .opacity(animateIn ? 1 : 0)
                        .offset(y: animateIn ? 0 : 20)

                    // 紧急求助大按钮 (紧急模式独有)
                    if isEmergency {
                        emergencyButton
                            .opacity(animateIn ? 1 : 0)
                    }

                    // 热线电话列表
                    hotlineList
                        .opacity(animateIn ? 1 : 0)
                        .offset(y: animateIn ? 0 : 20)

                    // 紧急联系人 (紧急模式)
                    if isEmergency {
                        emergencyContactsSection
                            .opacity(animateIn ? 1 : 0)
                    }

                    // 稳情练习
                    healingExercisesSection
                        .opacity(animateIn ? 1 : 0)
                        .offset(y: animateIn ? 0 : 20)

                    // 安全计划入口
                    safetyPlanEntry
                        .opacity(animateIn ? 1 : 0)

                    // 底部按钮
                    bottomActions
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

    // MARK: - Top Icon
    private var topIcon: some View {
        ZStack {
            Circle()
                .fill(
                    isEmergency
                        ? AppTheme.crisisRed.opacity(0.12)
                        : AppTheme.warmGlow.opacity(0.12)
                )
                .frame(width: 120, height: 120)

            Circle()
                .stroke(
                    isEmergency
                        ? AppTheme.crisisRed.opacity(0.2)
                        : AppTheme.warmGlow.opacity(0.2),
                    lineWidth: 1
                )
                .frame(width: 160, height: 160)

            Image(systemName: isEmergency ? "heart.circle.fill" : "heart.text.square.fill")
                .font(.system(size: 48))
                .foregroundColor(
                    isEmergency ? AppTheme.crisisRed : AppTheme.warmGlow
                )
                .scaleEffect(animateIn ? 1.05 : 0.95)
                .animation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true), value: animateIn)
        }
        .padding(.top, AppSpacing.xl)
    }

    // MARK: - Title
    private var titleSection: some View {
        VStack(spacing: AppSpacing.md) {
            Text(isEmergency
                 ? "紧急求助"
                 : "安全守护")
                .font(AppFont.title1)
                .foregroundColor(AppTheme.textPrimary)

            Text(isEmergency
                 ? "你不是一个人，请立即寻求帮助"
                 : "我们注意到你可能正在经历困难时刻")
                .font(AppFont.body)
                .foregroundColor(AppTheme.textSecondary)
                .multilineTextAlignment(.center)
                .lineSpacing(6)
        }
    }

    // MARK: - Emergency Button (紧急模式)
    private var emergencyButton: some View {
        Link(destination: URL(string: "tel://4001619995")!) {
            HStack(spacing: AppSpacing.sm) {
                Image(systemName: "phone.fill")
                    .font(.system(size: 20))
                Text("一键拨打热线 400-161-9995")
                    .font(AppFont.buttonLabel)
            }
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 18)
            .background(
                LinearGradient(
                    colors: [AppTheme.crisisRed, AppTheme.crisisRedDark],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .cornerRadius(AppRadius.lg)
            .shadow(color: AppTheme.crisisRed.opacity(0.35), radius: 12, x: 0, y: 4)
        }
    }

    // MARK: - Hotline List
    private var hotlineList: some View {
        VStack(alignment: .leading, spacing: AppSpacing.md) {
            Text(isEmergency ? "心理援助热线" : "专业资源")
                .font(AppFont.title3)
                .foregroundColor(AppTheme.textPrimary)

            VStack(spacing: AppSpacing.sm) {
                hotlineRow(
                    title: "全国24小时心理援助热线",
                    number: "400-161-9995",
                    subtitle: "免费 · 保密 · 全天候"
                )
                hotlineRow(
                    title: "北京心理危机研究与干预中心",
                    number: "010-82951332",
                    subtitle: "专业危机干预"
                )
                hotlineRow(
                    title: "生命热线（希望24）",
                    number: "400-821-1215",
                    subtitle: "全国通用 · 24小时"
                )
            }
        }
    }

    private func hotlineRow(title: String, number: String, subtitle: String) -> some View {
        Link(destination: URL(string: "tel:\(number.filter { $0.isNumber })")!) {
            HStack(spacing: AppSpacing.md) {
                ZStack {
                    Circle()
                        .fill(
                            isEmergency
                                ? AppTheme.crisisRed.opacity(0.12)
                                : AppTheme.accentMint.opacity(0.12)
                        )
                        .frame(width: 44, height: 44)

                    Image(systemName: "phone.fill")
                        .font(.system(size: 16))
                        .foregroundColor(isEmergency ? AppTheme.crisisRed : AppTheme.accentMint)
                }

                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(AppFont.bodyBold)
                        .foregroundColor(AppTheme.textPrimary)
                    Text(number)
                        .font(.system(size: 17, weight: .semibold, design: .monospaced))
                        .foregroundColor(isEmergency ? AppTheme.crisisRed : AppTheme.primary)
                    Text(subtitle)
                        .font(AppFont.caption2)
                        .foregroundColor(AppTheme.textMuted)
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(AppTheme.textMuted)
            }
            .padding(AppSpacing.md)
            .background(AppTheme.cardBackground)
            .cornerRadius(AppRadius.md)
        }
    }

    // MARK: - Emergency Contacts (紧急模式独有)
    private var emergencyContactsSection: some View {
        VStack(alignment: .leading, spacing: AppSpacing.md) {
            Text("紧急联系人")
                .font(AppFont.title3)
                .foregroundColor(AppTheme.textPrimary)

            VStack(spacing: AppSpacing.sm) {
                contactRow(name: "信任的朋友", icon: "person.fill")
                contactRow(name: "家人", icon: "house.fill")
                contactRow(name: "心理咨询师", icon: "brain.head.profile")
            }
        }
    }

    private func contactRow(name: String, icon: String) -> some View {
        HStack(spacing: AppSpacing.md) {
            ZStack {
                Circle()
                    .fill(AppTheme.surface)
                    .frame(width: 44, height: 44)

                Image(systemName: icon)
                    .font(.system(size: 18))
                    .foregroundColor(AppTheme.textSecondary)
            }

            Text(name)
                .font(AppFont.body)
                .foregroundColor(AppTheme.textPrimary)

            Spacer()

            Image(systemName: "phone.fill")
                .font(.system(size: 14))
                .foregroundColor(AppTheme.primary)
                .frame(width: 36, height: 36)
                .background(AppTheme.primary.opacity(0.1))
                .cornerRadius(AppRadius.sm)
        }
        .padding(AppSpacing.md)
        .background(AppTheme.cardBackground)
        .cornerRadius(AppRadius.md)
    }

    // MARK: - Healing Exercises
    private var healingExercisesSection: some View {
        VStack(alignment: .leading, spacing: AppSpacing.md) {
            Text("稳情练习")
                .font(AppFont.title3)
                .foregroundColor(AppTheme.textPrimary)

            VStack(spacing: AppSpacing.sm) {
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
                    description: "通过感官重新连接当下",
                    color: AppTheme.warmPurple,
                    action: { showHealingPlan = true }
                )
            }
        }
    }

    // MARK: - Safety Plan Entry
    private var safetyPlanEntry: some View {
        HStack(spacing: AppSpacing.md) {
            ZStack {
                RoundedRectangle(cornerRadius: AppRadius.md)
                    .fill(AppTheme.accentMint.opacity(0.12))
                    .frame(width: 44, height: 44)

                Image(systemName: "shield.checkered")
                    .font(.system(size: 20))
                    .foregroundColor(AppTheme.accentMint)
            }

            VStack(alignment: .leading, spacing: 2) {
                Text("安全计划")
                    .font(AppFont.bodyBold)
                    .foregroundColor(AppTheme.textPrimary)
                Text("提前准备，从容应对")
                    .font(AppFont.caption2)
                    .foregroundColor(AppTheme.textMuted)
            }

            Spacer()

            Image(systemName: "chevron.right")
                .font(.system(size: 13, weight: .semibold))
                .foregroundColor(AppTheme.textMuted)
        }
        .padding(AppSpacing.lg)
        .background(AppTheme.cardBackground)
        .cornerRadius(AppRadius.lg)
    }

    // MARK: - Bottom
    private var bottomActions: some View {
        VStack(spacing: AppSpacing.md) {
            Button(action: { showHealingPlan = true }) {
                HStack(spacing: AppSpacing.sm) {
                    Image(systemName: "leaf.fill")
                    Text("开始稳情练习")
                }
            }
            .buttonStyle(ComponentStyles.PrimaryButtonStyle())

            Button(action: { dismiss() }) {
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
                    RoundedRectangle(cornerRadius: AppRadius.sm)
                        .fill(color.opacity(0.12))
                        .frame(width: 44, height: 44)

                    Image(systemName: icon)
                        .font(.system(size: 20))
                        .foregroundColor(color)
                }

                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(AppFont.bodyBold)
                        .foregroundColor(AppTheme.textPrimary)
                    Text(description)
                        .font(AppFont.caption2)
                        .foregroundColor(AppTheme.textMuted)
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(AppTheme.textMuted)
            }
            .padding(AppSpacing.md)
            .background(AppTheme.cardBackground)
            .cornerRadius(AppRadius.lg)
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    CCCrisisInterventionView(isEmergency: false)
}
