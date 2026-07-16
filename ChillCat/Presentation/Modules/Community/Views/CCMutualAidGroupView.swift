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
        .background(Color.xuanApricotBg)
        .task { await viewModel.loadGroups() }
    }

    // MARK: - Header

    private var headerSection: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("互助小组")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(Color.xuanTextPrimary)
                Text("找到理解你的人，一起成长")
                    .font(.system(size: 13))
                    .foregroundColor(Color.xuanTextSecondary)
            }
            Spacer()

            if !viewModel.myGroups.isEmpty {
                HStack(spacing: 4) {
                    Image("resonance_people")
                        .font(.system(size: 12))
                    Text("已加入 \(viewModel.myGroups.count) 个")
                        .font(.system(size: 12))
                        .foregroundColor(Color.xuanMint)
                }
                .padding(.horizontal, 10)
                .padding(.vertical, 4)
                .background(Color.xuanMint.opacity(0.1))
                .cornerRadius(XuanRadius.sm)
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
                            .foregroundColor(isSelected(category) ? .white : Color.xuanTextSecondary)
                            .padding(.horizontal, 14)
                            .padding(.vertical, 6)
                            .background(
                                isSelected(category)
                                    ? Color.xuanApricot
                                    : Color.xuanSurface
                            )
                            .cornerRadius(XuanRadius.full)
                    }
                    .accessibilityIdentifier("mutual_aid_category_\(category)")
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

                    CCIconMapper.image(for: group.iconName)
                        .font(.system(size: 20))
                        .foregroundColor(iconColor(for: group.iconName))
                }

                // Info
                VStack(alignment: .leading, spacing: 4) {
                    Text(group.name)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(Color.xuanTextPrimary)

                    Text(group.description)
                        .font(.system(size: 13))
                        .foregroundColor(Color.xuanTextSecondary)
                        .lineLimit(1)

                    // Member count badge
                    HStack(spacing: 4) {
                        Image("resonance_people")
                            .font(.system(size: 10))
                        Text(formattedMemberCount(group.memberCount) + " 人")
                            .font(.system(size: 11))
                    }
                    .foregroundColor(Color.xuanTextSecondary)
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
                        .foregroundColor(group.isJoined ? Color.xuanMint : Color.xuanApricot)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(
                            group.isJoined
                                ? Color.xuanMint.opacity(0.1)
                                : Color.xuanApricot.opacity(0.1)
                        )
                        .cornerRadius(XuanRadius.sm)
                }
                .buttonStyle(.plain)
                .accessibilityIdentifier("mutual_aid_join_\(group.id)")
            }
            .padding(12)
            .background(Color.xuanWhite)
            .cornerRadius(XuanRadius.lg)
            .shadow(color: Color.black.opacity(0.03), radius: 4, y: 2)
        }
        .buttonStyle(.plain)
        .accessibilityIdentifier("mutual_aid_group_\(group.id)")
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
        if iconName.contains("heart") || iconName.contains("sad") { return Color.xuanPink }
        if iconName.contains("meditate") || iconName.contains("calm") { return Color.xuanMint }
        if iconName.contains("breath") || iconName.contains("apricot") { return Color.xuanApricot }
        if iconName.contains("rain") || iconName.contains("sound") || iconName.contains("moon") { return Color(hex: "A085C6") }
        if iconName.contains("knowledge") || iconName.contains("briefcase") { return Color.xuanApricotDark }
        if iconName.contains("course") || iconName.contains("book") || iconName.contains("diary") { return Color.xuanApricotLight }
        return Color.xuanApricot
    }
}
