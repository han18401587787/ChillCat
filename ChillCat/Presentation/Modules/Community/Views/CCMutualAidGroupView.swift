import SwiftUI

struct CCMutualAidGroupView: View {
    @State private var viewModel = CCMutualAidGroupViewModel()
    @Environment(CCAppCoordinator.self) private var coordinator
        var body: some View {
        VStack(spacing: 0) {
            // Header
            headerSection

            // Category filter tabs
            categoryFilterTabs

            // Content
            if viewModel.isLoading {
                Spacer()
                CCLoadingView(message: "正在加载互助小组…")
                Spacer()
            } else if let error = viewModel.errorMessage, viewModel.filteredGroups.isEmpty {
                Spacer()
                CCEmptyStateView(
                    title: "加载失败",
                    message: error,
                    imageName: "wifi.slash"
                )
                Spacer()
            } else if viewModel.filteredGroups.isEmpty {
                Spacer()
                CCEmptyStateView(
                    title: "该分类暂无小组",
                    message: "试试其他分类，或稍后再来看看",
                    imageName: "person.3"
                )
                Spacer()
            } else {
                groupList
            }
        }
        .background(AppTheme.background)
        .task { await viewModel.loadGroups() }
    }

    // MARK: - Header

    private var headerSection: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("互助小组")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(AppTheme.textPrimary)
                Text("找到理解你的人，一起成长")
                    .font(.system(size: 13))
                    .foregroundColor(AppTheme.textSecondary)
            }
            Spacer()

            if !viewModel.myGroups.isEmpty {
                HStack(spacing: 4) {
                    Image(systemName: "person.2.fill")
                        .font(.system(size: 12))
                    Text("已加入 \(viewModel.myGroups.count) 个")
                        .font(.system(size: 12))
                        .foregroundColor(AppTheme.accentMint)
                }
                .padding(.horizontal, 10)
                .padding(.vertical, 4)
                .background(AppTheme.accentMint.opacity(0.1))
                .cornerRadius(AppRadius.sm)
            }
        }
        .padding(.horizontal)
        .padding(.top, 8)
        .padding(.bottom, 4)
    }

    // MARK: - Category Filter Tabs

    private var categoryFilterTabs: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(viewModel.categories, id: \.self) { category in
                    Button(action: {
                        CCHaptic.light()
                        viewModel.selectCategory(category == "全部" ? nil : category)
                    }) {
                        Text(category)
                            .font(.system(size: 13, weight: .medium))
                            .foregroundColor(isSelected(category) ? .white : AppTheme.textSecondary)
                            .padding(.horizontal, 14)
                            .padding(.vertical, 6)
                            .background(
                                isSelected(category)
                                    ? AppTheme.primary
                                    : AppTheme.surface
                            )
                            .cornerRadius(AppRadius.full)
                    }
                }
            }
            .padding(.horizontal)
            .padding(.vertical, 8)
        }
    }

    // MARK: - Group List

    private var groupList: some View {
        ScrollView {
            LazyVStack(spacing: 12) {
                ForEach(viewModel.filteredGroups) { group in
                    groupCard(group)
                }
            }
            .padding(.horizontal)
            .padding(.bottom, 16)
        }
    }

    // MARK: - Group Card

    private func groupCard(_ group: CCMutualAidGroup) -> some View {
        Button(action: {
            coordinator.navigate(to: .mutualAidGroupDetail(group.id))
        }) {
            HStack(spacing: 12) {
                // Icon in colored circle
                ZStack {
                    Circle()
                        .fill(iconColor(for: group.iconName).opacity(0.15))
                        .frame(width: 48, height: 48)

                    Image(systemName: group.iconName)
                        .font(.system(size: 20))
                        .foregroundColor(iconColor(for: group.iconName))
                }

                // Info
                VStack(alignment: .leading, spacing: 4) {
                    Text(group.name)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(AppTheme.textPrimary)

                    Text(group.description)
                        .font(.system(size: 13))
                        .foregroundColor(AppTheme.textSecondary)
                        .lineLimit(1)

                    // Member count badge
                    HStack(spacing: 4) {
                        Image(systemName: "person.2")
                            .font(.system(size: 10))
                        Text(formattedMemberCount(group.memberCount) + " 人")
                            .font(.system(size: 11))
                    }
                    .foregroundColor(AppTheme.textSecondary)
                }

                Spacer()

                // Join / Joined button
                Button(action: {
                    CCHaptic.medium()
                    Task {
                        if group.isJoined {
                            await viewModel.leaveGroup(id: group.id)
                        } else {
                            await viewModel.joinGroup(id: group.id)
                        }
                    }
                }) {
                    Text(group.isJoined ? "已加入" : "加入")
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(group.isJoined ? AppTheme.accentMint : AppTheme.primary)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(
                            group.isJoined
                                ? AppTheme.accentMint.opacity(0.1)
                                : AppTheme.primary.opacity(0.1)
                        )
                        .cornerRadius(AppRadius.sm)
                }
                .buttonStyle(.plain)
            }
            .padding(12)
            .background(AppTheme.cardBackground)
            .cornerRadius(AppRadius.lg)
            .shadow(color: Color.black.opacity(0.03), radius: 4, y: 2)
        }
        .buttonStyle(.plain)
    }

    // MARK: - Helpers

    private func isSelected(_ category: String) -> Bool {
        if category == "全部" { return viewModel.selectedCategory == nil }
        return viewModel.selectedCategory == category
    }

    private func formattedMemberCount(_ count: Int64) -> String {
        if count >= 10000 {
            return String(format: "%.1f万", Double(count) / 10000.0)
        } else if count >= 1000 {
            return String(format: "%.1fk", Double(count) / 1000.0)
        }
        return "\(count)"
    }

    private func iconColor(for iconName: String) -> Color {
        if iconName.contains("heart") { return AppTheme.warmPink }
        if iconName.contains("leaf") { return AppTheme.accentMint }
        if iconName.contains("wind") { return AppTheme.primary }
        if iconName.contains("cloud") || iconName.contains("moon") || iconName.contains("rain") { return AppTheme.warmPurple }
        if iconName.contains("briefcase") { return AppTheme.warmGold }
        if iconName.contains("book") { return AppTheme.primaryLight }
        return AppTheme.primary
    }
}
