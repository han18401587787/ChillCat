import SwiftUI

struct CCTrendsView: View {
    @State private var selectedTab = 0
    @State private var viewModel = CCTrendsViewModel()

    var body: some View {
        ScrollView {
            VStack(spacing: AppSpacing.lg) {
                Picker("", selection: $selectedTab) {
                    Text("本周").tag(0); Text("本月").tag(1); Text("成长").tag(2)
                }.pickerStyle(.segmented).padding(.horizontal)

                if selectedTab == 0 { weekView }
                else if selectedTab == 1 { monthView }
                else { growthView }
            }.padding()
        }
        .background(AppTheme.background).navigationTitle("情绪趋势")
        .task { await viewModel.loadStats() }
        .alert("提示", isPresented: .constant(viewModel.errorMessage != nil)) {
            Button("重试") { Task { await viewModel.retry() } }
            Button("取消", role: .cancel) { viewModel.errorMessage = nil }
        } message: {
            Text(viewModel.errorMessage ?? "")
        }
    }

    // MARK: - Week View
    var weekView: some View {
        VStack(spacing: AppSpacing.lg) {
            VStack(alignment: .leading, spacing: AppSpacing.sm) {
                Text("本周情绪波动").font(.system(size: 16, weight: .semibold))
                if viewModel.isLoading {
                    CCSkeletonView().frame(height: 100).cornerRadius(AppRadius.md)
                } else if viewModel.weekData.isEmpty {
                    emptyChartPlaceholder
                } else {
                    HStack(alignment: .bottom, spacing: 8) {
                        ForEach(viewModel.weekData, id: \.0) { (day, count) in
                            VStack(spacing: 4) {
                                RoundedRectangle(cornerRadius: 4)
                                    .fill(AppTheme.info).frame(width: 36, height: max(8, CGFloat(count) * 24))
                                Text(day).font(.system(size: 11)).foregroundColor(AppTheme.textSecondary)
                            }
                        }
                    }.frame(height: 120).padding().background(AppTheme.cardBackground).cornerRadius(AppRadius.md)
                }
            }

            if !viewModel.isLoading {
                HStack(spacing: AppSpacing.sm) {
                    statBox(value: "\(viewModel.stats?.totalCount ?? 0)", label: "本周记录", color: AppTheme.softPurpleLight)
                    statBox(value: "\(viewModel.stats?.streakDays ?? 0)", label: "连续天数", color: AppTheme.primaryMuted)
                    statBox(value: viewModel.stats?.topEmotion ?? "—", label: "主要情绪", color: AppTheme.softGreenLight)
                }
            }

            if !viewModel.isLoading, let s = viewModel.stats, !s.insight.isEmpty {
                VStack(alignment: .leading, spacing: AppSpacing.sm) {
                    Text("绪安洞察").font(.system(size: 16, weight: .semibold))
                    insightCard(text: s.insight, color: AppTheme.warmPurple)
                }
            }
        }
    }

    var monthView: some View {
        VStack(spacing: AppSpacing.lg) {
            Text("本月情绪回顾").font(.system(size: 18, weight: .bold))
            if viewModel.isLoading {
                CCSkeletonView().frame(height: 100).cornerRadius(AppRadius.md)
            } else if viewModel.isEmpty {
                emptyChartPlaceholder
            } else {
                HStack(spacing: AppSpacing.sm) {
                    statBox(value: "\(viewModel.stats?.totalCount ?? 0)", label: "打卡", color: AppTheme.softPurpleLight)
                    statBox(value: viewModel.stats?.topEmotion ?? "—", label: "主要情绪", color: AppTheme.accentMint.opacity(0.25))
                    statBox(value: "\(viewModel.stats?.streakDays ?? 0)", label: "连续", color: AppTheme.primaryMuted)
                }
            }
        }
    }

    var growthView: some View {
        VStack(spacing: AppSpacing.lg) {
            Text("成长轨迹").font(.system(size: 18, weight: .bold))
            if viewModel.isLoading {
                CCSkeletonView().frame(height: 120).cornerRadius(AppRadius.md)
            } else if viewModel.isEmpty {
                emptyChartPlaceholder
            } else {
                VStack(spacing: AppSpacing.sm) {
                    growthRow(icon: "chart.line.uptrend.xyaxis", title: "本周记录 \(viewModel.stats?.totalCount ?? 0) 次", subtitle: "继续坚持")
                    growthRow(icon: "figure.mind.and.body", title: "连续打卡 \(viewModel.stats?.streakDays ?? 0) 天", subtitle: "加油保持")
                    growthRow(icon: "pencil.and.list.clipboard", title: "今日主要情绪", subtitle: viewModel.stats?.topEmotion ?? "暂无数据")
                }
            }
        }
    }

    private var emptyChartPlaceholder: some View {
        VStack(spacing: 8) {
            Image(systemName: "chart.bar.xaxis.ascending")
                .font(.system(size: 28))
                .foregroundColor(AppTheme.textSecondary.opacity(0.4))
            Text("暂无数据")
                .font(.system(size: 13))
                .foregroundColor(AppTheme.textSecondary)
        }
        .frame(height: 100).frame(maxWidth: .infinity)
        .background(AppTheme.cardBackground).cornerRadius(AppRadius.md)
    }

    // MARK: - Components
    func statBox(value: String, label: String, color: Color) -> some View {
        VStack(spacing: 4) {
            Text(value).font(.system(size: 24, weight: .bold)).foregroundColor(AppTheme.primaryDark)
            Text(label).font(.system(size: 12)).foregroundColor(AppTheme.textSecondary)
        }
        .frame(maxWidth: .infinity).padding(.vertical, 16)
        .background(color.opacity(0.3)).cornerRadius(AppRadius.md)
    }

    func insightCard(text: String, color: Color) -> some View {
        HStack(spacing: 12) {
            Image(systemName: "sparkles").foregroundColor(AppTheme.warmGold)
            Text(text).font(.system(size: 14)).foregroundColor(AppTheme.textSecondary).lineSpacing(4)
            Spacer()
        }.padding().background(color.opacity(0.25)).cornerRadius(AppRadius.md)
    }

    func growthRow(icon: String, title: String, subtitle: String) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon).font(.system(size: 20)).foregroundColor(AppTheme.primaryDark).frame(width: 40)
            VStack(alignment: .leading, spacing: 2) {
                Text(title).font(.system(size: 15, weight: .medium))
                Text(subtitle).font(.system(size: 12)).foregroundColor(AppTheme.textSecondary)
            }
            Spacer()
        }.padding().background(AppTheme.cardBackground).cornerRadius(AppRadius.md)
    }
}
