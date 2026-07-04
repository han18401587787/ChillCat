//
//  CCStablePlanView.swift
//  绪安 - 稳情计划页
//
//  设计规范: 绪安设计系统 v3.0
//  布局: 大标题 → 7天情绪概览 → 本周进度 → 7天任务列表 → 查看完整计划按钮

import SwiftUI

// MARK: - 任务数据模型
struct StablePlanTask: Identifiable {
    let id: Int
    let day: Int          // 1-7 (周一到周日)
    let dayName: String
    let taskTitle: String
    let status: TaskStatus

    enum TaskStatus {
        case completed
        case inProgress
        case pending

        var icon: String {
            switch self {
            case .completed:  return "checkmark.circle.fill"
            case .inProgress: return "arrow.right.circle.fill"
            case .pending:    return "circle"
            }
        }

        var color: Color {
            switch self {
            case .completed:  return Color.xuanSuccess
            case .inProgress: return Color.xuanApricotDark
            case .pending:    return Color.xuanTextTertiary
            }
        }

        var label: String {
            switch self {
            case .completed:  return "已完成"
            case .inProgress: return "进行中"
            case .pending:    return "待完成"
            }
        }

        var bgColor: Color {
            switch self {
            case .completed:  return Color.xuanSuccess.opacity(0.1)
            case .inProgress: return Color.xuanApricot.opacity(0.1)
            case .pending:    return Color.xuanSurface
            }
        }
    }
}

// MARK: - CCStablePlanView

struct CCStablePlanView: View {
    @Environment(CCAppCoordinator.self) private var coordinator
    @Environment(\.dismiss) private var dismiss

    @State private var animateEntrance = false

    // 7天任务数据
    private let tasks: [StablePlanTask] = [
        StablePlanTask(id: 1, day: 1, dayName: "周一", taskTitle: "4-7-8呼吸练习", status: .completed),
        StablePlanTask(id: 2, day: 2, dayName: "周二", taskTitle: "记录3件感恩小事", status: .completed),
        StablePlanTask(id: 3, day: 3, dayName: "周三", taskTitle: "正念散步15分钟", status: .completed),
        StablePlanTask(id: 4, day: 4, dayName: "周四", taskTitle: "给朋友发一条温暖消息", status: .inProgress),
        StablePlanTask(id: 5, day: 5, dayName: "周五", taskTitle: "写下今天的心情日记", status: .pending),
        StablePlanTask(id: 6, day: 6, dayName: "周六", taskTitle: "听一首治愈音乐", status: .pending),
        StablePlanTask(id: 7, day: 7, dayName: "周日", taskTitle: "回顾本周的成长", status: .pending),
    ]

    // 7天情绪状态（0.0-1.0 表示情绪高低）
    private let weekEmotions: [(day: String, value: Double, color: Color)] = [
        ("一", 0.65, Color.xuanMint),
        ("二", 0.72, Color.xuanMint),
        ("三", 0.55, Color.xuanApricot),
        ("四", 0.48, Color.xuanWarning),
        ("五", 0.62, Color.xuanMint),
        ("六", 0.80, Color.xuanMint),
        ("日", 0.75, Color.xuanMint),
    ]

    private var completedDays: Int {
        tasks.filter { $0.status == .completed }.count
    }

    private var totalDays: Int { tasks.count }

    var body: some View {
        ScrollView {
            VStack(spacing: XuanSpacing.xl2) {
                // 1. 大标题
                titleSection
                    .opacity(animateEntrance ? 1 : 0)
                    .offset(y: animateEntrance ? 0 : 20)

                // 2. 情绪概览卡片
                emotionOverviewCard
                    .opacity(animateEntrance ? 1 : 0)
                    .offset(y: animateEntrance ? 0 : 20)

                // 3. 本周进度卡片
                weeklyProgressCard
                    .opacity(animateEntrance ? 1 : 0)
                    .offset(y: animateEntrance ? 0 : 20)

                // 4. 7天任务列表
                taskListSection
                    .opacity(animateEntrance ? 1 : 0)
                    .offset(y: animateEntrance ? 0 : 20)

                // 5. 查看完整计划按钮
                viewFullPlanButton
                    .opacity(animateEntrance ? 1 : 0)
                    .offset(y: animateEntrance ? 0 : 20)
            }
            .padding(XuanSpacing.lg)
        }
        .background(Color.xuanApricotBg)
        .navigationBarBackButtonHidden(false)
        .onAppear {
            withAnimation(.easeOut(duration: 0.5)) {
                animateEntrance = true
            }
        }
    }

    // MARK: - 1. 标题区
    private var titleSection: some View {
        VStack(alignment: .leading, spacing: XuanSpacing.xs) {
            Text("稳情计划")
                .font(XuanFont.h1)
                .foregroundColor(Color.xuanTextPrimary)

            Text("每天一个小练习，让情绪更稳定")
                .font(XuanFont.bodyL)
                .foregroundColor(Color.xuanTextSecondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    // MARK: - 2. 情绪概览卡片
    private var emotionOverviewCard: some View {
        VStack(alignment: .leading, spacing: XuanSpacing.md) {
            HStack {
                Text("近7天情绪波动")
                    .font(XuanFont.h3)
                    .foregroundColor(Color.xuanTextPrimary)

                Spacer()

                Text("本周")
                    .font(XuanFont.bodyS)
                    .foregroundColor(Color.xuanTextTertiary)
            }

            // 情绪柱状图
            HStack(alignment: .bottom, spacing: XuanSpacing.md) {
                ForEach(weekEmotions.indices, id: \.self) { index in
                    let item = weekEmotions[index]
                    VStack(spacing: XuanSpacing.xs) {
                        // 柱体
                        RoundedRectangle(cornerRadius: XuanRadius.sm)
                            .fill(
                                LinearGradient(
                                    colors: [item.color.opacity(0.6), item.color],
                                    startPoint: .bottom,
                                    endPoint: .top
                                )
                            )
                            .frame(
                                width: 32,
                                height: max(8, CGFloat(item.value) * 100)
                            )
                            .animation(
                                .spring(response: 0.6, dampingFraction: 0.7)
                                    .delay(Double(index) * 0.08),
                                value: animateEntrance
                            )

                        // 天数标签
                        Text(item.day)
                            .font(XuanFont.caption)
                            .foregroundColor(Color.xuanTextTertiary)
                    }
                }
            }
            .frame(height: 120)
            .padding(.top, XuanSpacing.sm)

            // 图例
            HStack(spacing: XuanSpacing.lg) {
                legendItem(color: Color.xuanMint, label: "平稳")
                legendItem(color: Color.xuanApricot, label: "一般")
                legendItem(color: Color.xuanWarning, label: "波动")
            }
        }
        .padding(XuanSpacing.lg)
        .background(Color.xuanWhite)
        .cornerRadius(XuanRadius.lg)
        .xuanCardShadow()
    }

    private func legendItem(color: Color, label: String) -> some View {
        HStack(spacing: XuanSpacing.xs) {
            Circle()
                .fill(color)
                .frame(width: 8, height: 8)
            Text(label)
                .font(XuanFont.caption)
                .foregroundColor(Color.xuanTextSecondary)
        }
    }

    // MARK: - 3. 本周进度卡片
    private var weeklyProgressCard: some View {
        VStack(alignment: .leading, spacing: XuanSpacing.md) {
            HStack {
                Text("本周进度")
                    .font(XuanFont.h3)
                    .foregroundColor(Color.xuanTextPrimary)

                Spacer()

                Text("\(completedDays)/\(totalDays) 天")
                    .font(XuanFont.bodyLBold)
                    .foregroundColor(Color.xuanMintDark)
            }

            // 进度条
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 6)
                        .fill(Color.xuanMint.opacity(0.15))
                        .frame(height: 12)

                    RoundedRectangle(cornerRadius: 6)
                        .fill(
                            LinearGradient(
                                colors: [Color.xuanMint, Color.xuanMintDark],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(
                            width: geometry.size.width * CGFloat(completedDays) / CGFloat(totalDays),
                            height: 12
                        )
                        .animation(.easeInOut(duration: 0.8).delay(0.2), value: animateEntrance)
                }
            }
            .frame(height: 12)

            // 鼓励文字
            HStack(spacing: XuanSpacing.xs) {
                Image("home_quote")
                    .font(.system(size: 12))
                    .foregroundColor(Color.xuanMintDark)
                Text(progressMessage)
                    .font(XuanFont.bodyS)
                    .foregroundColor(Color.xuanMintDark)
            }
        }
        .padding(XuanSpacing.lg)
        .background(Color.xuanMintLight)
        .cornerRadius(XuanRadius.lg)
    }

    private var progressMessage: String {
        if completedDays == totalDays {
            return "太棒了！本周全部完成 🎉"
        } else if completedDays >= 4 {
            return "已经过半啦，继续加油！"
        } else if completedDays >= 2 {
            return "稳步前进中，保持节奏"
        } else {
            return "开始就是最好的进步"
        }
    }

    // MARK: - 4. 任务列表
    private var taskListSection: some View {
        VStack(alignment: .leading, spacing: XuanSpacing.md) {
            Text("每日任务")
                .font(XuanFont.h3)
                .foregroundColor(Color.xuanTextPrimary)

            VStack(spacing: XuanSpacing.sm) {
                ForEach(tasks) { task in
                    taskRow(task)
                }
            }
        }
    }

    private func taskRow(_ task: StablePlanTask) -> some View {
        HStack(spacing: XuanSpacing.md) {
            // 星期标签
            Text(task.dayName)
                .font(XuanFont.bodyS)
                .foregroundColor(
                    task.status == .completed
                        ? Color.xuanSuccess
                        : Color.xuanTextSecondary
                )
                .frame(width: 36, alignment: .leading)

            // 任务内容
            VStack(alignment: .leading, spacing: 2) {
                Text(task.taskTitle)
                    .font(XuanFont.bodyL)
                    .foregroundColor(Color.xuanTextPrimary)
                    .strikethrough(task.status == .completed, color: Color.xuanTextTertiary)

                Text(task.status.label)
                    .font(XuanFont.caption)
                    .foregroundColor(task.status.color)
            }

            Spacer()

            // 状态图标
            Image(systemName: task.status.icon)
                .font(.system(size: 22))
                .foregroundColor(task.status.color)
        }
        .padding(XuanSpacing.md)
        .background(task.status.bgColor)
        .cornerRadius(XuanRadius.md)
        .overlay(
            RoundedRectangle(cornerRadius: XuanRadius.md)
                .stroke(task.status.color.opacity(0.2), lineWidth: 1)
        )
    }

    // MARK: - 5. 查看完整计划按钮
    private var viewFullPlanButton: some View {
        Button(action: {
            coordinator.navigate(to: .healing)
        }) {
            HStack(spacing: XuanSpacing.sm) {
                Image(systemName: "doc.text.magnifyingglass")
                    .font(.system(size: 16))
                Text("查看完整计划")
                    .font(XuanFont.bodyLBold)
            }
            .foregroundColor(Color.xuanMintDark)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .background(Color.xuanMintLight)
            .cornerRadius(XuanRadius.lg)
            .overlay(
                RoundedRectangle(cornerRadius: XuanRadius.lg)
                    .stroke(Color.xuanMint.opacity(0.3), lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Preview
#Preview {
    NavigationStack {
        CCStablePlanView()
    }
}
