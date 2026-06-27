//
//  CCSafetyPlanView.swift
//  ChillCat
//
//  安全计划 — 预警信号识别、安抚策略、支持联系人、专业资源链接
//

import SwiftUI

struct CCSafetyPlanView: View {
        @Environment(CCAppCoordinator.self) private var coordinator

    // MARK: - Warning Signs State
    @State private var warningSigns: [SafetyPlanItem] = [
        SafetyPlanItem(text: "感到绝望、没有出路"),
        SafetyPlanItem(text: "想要远离所有人、把自己关起来"),
        SafetyPlanItem(text: "觉得自己是别人的负担"),
        SafetyPlanItem(text: "睡眠出现严重问题（失眠或嗜睡）"),
        SafetyPlanItem(text: "对平时喜欢的事情完全失去兴趣"),
        SafetyPlanItem(text: "频繁想到死亡或自杀"),
        SafetyPlanItem(text: "情绪极度波动、无法自控"),
    ]

    // MARK: - Calming Strategies State
    @State private var calmingStrategies: [SafetyPlanItem] = [
        SafetyPlanItem(text: "做5分钟深呼吸练习（4-7-8呼吸法）"),
        SafetyPlanItem(text: "给信任的朋友打一个电话"),
        SafetyPlanItem(text: "出去走一走，感受阳光和风"),
        SafetyPlanItem(text: "听一首让自己平静的音乐"),
        SafetyPlanItem(text: "用冷水洗把脸，感受当下的触觉"),
        SafetyPlanItem(text: "写下此刻的想法和感受"),
    ]

    // MARK: - Emergency Contacts State
    @State private var emergencyContacts: [EmergencyContact] = [
        EmergencyContact(name: "信任的朋友", phone: ""),
        EmergencyContact(name: "家人", phone: ""),
        EmergencyContact(name: "心理咨询师", phone: ""),
    ]

    // MARK: - New Item Input
    @State private var showingAddStrategy = false
    @State private var newStrategyText = ""

    @State private var showingAddContact = false
    @State private var newContactName = ""
    @State private var newContactPhone = ""

    var body: some View {
        ScrollView {
            VStack(spacing: AppSpacing.xl) {
                // MARK: - 页面头部
                headerSection

                // MARK: - 预警信号
                warningSignsSection

                // MARK: - 安抚策略
                calmingStrategiesSection

                // MARK: - 支持联系人
                supportContactsSection

                // MARK: - 专业资源快速入口
                professionalResourcesSection

                // MARK: - 分享按钮
                shareButton
            }
            .padding(AppSpacing.lg)
        }
        .background(AppTheme.background)
        .navigationTitle("我的安全计划")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showingAddStrategy) {
            addStrategySheet
        }
        .sheet(isPresented: $showingAddContact) {
            addContactSheet
        }
    }

    // MARK: - Header

    private var headerSection: some View {
        VStack(spacing: AppSpacing.sm) {
            Image(systemName: "shield.checkered")
                .font(.system(size: 36))
                .foregroundColor(AppTheme.primary)

            Text("提前准备，从容应对")
                .font(AppFont.title1)
                .foregroundColor(AppTheme.textPrimary)

            Text("安全计划是你在情绪危机时可以依靠的个性化方案。花一点时间填写它，未来你会感谢现在的自己。")
                .font(AppFont.body)
                .foregroundColor(AppTheme.textSecondary)
                .multilineTextAlignment(.center)
                .lineSpacing(4)
        }
        .padding(AppSpacing.xl)
        .frame(maxWidth: .infinity)
        .background(AppTheme.cardBackground)
        .cornerRadius(AppRadius.lg)
    }

    // MARK: - Warning Signs Section

    private var warningSignsSection: some View {
        VStack(alignment: .leading, spacing: AppSpacing.md) {
            sectionHeader(
                icon: "exclamationmark.triangle.fill",
                title: "预警信号",
                subtitle: "当我出现以下情况时，我知道自己需要寻求帮助",
                color: AppTheme.warmGold
            )

            VStack(spacing: AppSpacing.sm) {
                ForEach($warningSigns) { $item in
                    warningSignRow(item: $item)
                }
            }
        }
    }

    private func warningSignRow(item: Binding<SafetyPlanItem>) -> some View {
        HStack(spacing: AppSpacing.md) {
            Button(action: {
                withAnimation(.easeInOut(duration: 0.3)) {
                    item.wrappedValue.isChecked.toggle()
                }
            }) {
                Image(systemName: item.wrappedValue.isChecked ? "checkmark.circle.fill" : "circle")
                    .font(.system(size: 22))
                    .foregroundColor(item.wrappedValue.isChecked ? AppTheme.warmGold : AppTheme.textSecondary)
            }

            Text(item.wrappedValue.text)
                .font(AppFont.body)
                .foregroundColor(
                    item.wrappedValue.isChecked ? AppTheme.textSecondary : AppTheme.textPrimary
                )
                .strikethrough(item.wrappedValue.isChecked)

            Spacer()
        }
        .padding(AppSpacing.md)
        .background(AppTheme.cardBackground)
        .cornerRadius(AppRadius.md)
    }

    // MARK: - Calming Strategies Section

    private var calmingStrategiesSection: some View {
        VStack(alignment: .leading, spacing: AppSpacing.md) {
            sectionHeader(
                icon: "leaf.fill",
                title: "安抚策略",
                subtitle: "当我感到情绪失控时，可以尝试以下方法",
                color: AppTheme.accentMint
            )

            VStack(spacing: AppSpacing.sm) {
                ForEach($calmingStrategies) { $item in
                    strategyRow(item: $item)
                }
            }

            // Add new strategy button
            Button(action: {
                newStrategyText = ""
                showingAddStrategy = true
            }) {
                HStack {
                    Image(systemName: "plus.circle.fill")
                        .font(.system(size: 16))
                    Text("添加安抚策略")
                        .font(AppFont.body)
                }
                .foregroundColor(AppTheme.accentMint)
                .frame(maxWidth: .infinity)
                .padding(.vertical, AppSpacing.sm)
                .background(AppTheme.accentMint.opacity(0.08))
                .cornerRadius(AppRadius.sm)
            }
        }
    }

    private func strategyRow(item: Binding<SafetyPlanItem>) -> some View {
        HStack(spacing: AppSpacing.md) {
            Button(action: {
                withAnimation(.easeInOut(duration: 0.3)) {
                    item.wrappedValue.isChecked.toggle()
                }
            }) {
                Image(systemName: item.wrappedValue.isChecked ? "checkmark.circle.fill" : "circle")
                    .font(.system(size: 22))
                    .foregroundColor(item.wrappedValue.isChecked ? AppTheme.accentMint : AppTheme.textSecondary)
            }

            Text(item.wrappedValue.text)
                .font(AppFont.body)
                .foregroundColor(
                    item.wrappedValue.isChecked ? AppTheme.textSecondary : AppTheme.textPrimary
                )
                .strikethrough(item.wrappedValue.isChecked)

            Spacer()
        }
        .padding(AppSpacing.md)
        .background(AppTheme.cardBackground)
        .cornerRadius(AppRadius.md)
    }

    // MARK: - Support Contacts Section

    private var supportContactsSection: some View {
        VStack(alignment: .leading, spacing: AppSpacing.md) {
            sectionHeader(
                icon: "person.2.fill",
                title: "支持联系人",
                subtitle: "当我需要倾诉时，可以联系这些人",
                color: AppTheme.warmPurple
            )

            VStack(spacing: AppSpacing.sm) {
                ForEach($emergencyContacts) { $contact in
                    contactRow(contact: $contact)
                }
            }

            Button(action: {
                newContactName = ""
                newContactPhone = ""
                showingAddContact = true
            }) {
                HStack {
                    Image(systemName: "plus.circle.fill")
                        .font(.system(size: 16))
                    Text("添加联系人")
                        .font(AppFont.body)
                }
                .foregroundColor(AppTheme.warmPurple)
                .frame(maxWidth: .infinity)
                .padding(.vertical, AppSpacing.sm)
                .background(AppTheme.warmPurple.opacity(0.08))
                .cornerRadius(AppRadius.sm)
            }
        }
    }

    private func contactRow(contact: Binding<EmergencyContact>) -> some View {
        HStack(spacing: AppSpacing.md) {
            Image(systemName: "person.crop.circle.fill")
                .font(.system(size: 28))
                .foregroundColor(AppTheme.warmPurple)

            VStack(alignment: .leading, spacing: 2) {
                TextField("联系人姓名", text: contact.name)
                    .font(AppFont.body)
                    .foregroundColor(AppTheme.textPrimary)
                TextField("电话号码", text: contact.phone)
                    .font(AppFont.footnote)
                    .foregroundColor(AppTheme.textSecondary)
                    .keyboardType(.phonePad)
            }

            Spacer()

            if !contact.wrappedValue.phone.isEmpty {
                Link(destination: URL(string: "tel:\(contact.wrappedValue.phone.replacingOccurrences(of: " ", with: ""))")!) {
                    Image(systemName: "phone.fill")
                        .font(.system(size: 14))
                        .foregroundColor(AppTheme.primary)
                        .frame(width: 32, height: 32)
                        .background(AppTheme.primary.opacity(0.12))
                        .cornerRadius(AppRadius.sm)
                }
            }
        }
        .padding(AppSpacing.md)
        .background(AppTheme.cardBackground)
        .cornerRadius(AppRadius.md)
    }

    // MARK: - Professional Resources Quick Links

    private var professionalResourcesSection: some View {
        VStack(alignment: .leading, spacing: AppSpacing.md) {
            sectionHeader(
                icon: "cross.case.fill",
                title: "专业资源",
                subtitle: "快速拨打专业援助热线",
                color: AppTheme.crisisRed
            )

            VStack(spacing: AppSpacing.sm) {
                crisisLink(
                    name: "全国24小时心理援助热线",
                    number: "400-161-9995"
                )
                crisisLink(
                    name: "北京心理危机研究与干预中心",
                    number: "010-82951332"
                )
                crisisLink(
                    name: "生命热线",
                    number: "400-821-1215"
                )
            }
        }
    }

    private func crisisLink(name: String, number: String) -> some View {
        Link(destination: URL(string: "tel:\(number.replacingOccurrences(of: "-", with: ""))")!) {
            HStack {
                Image(systemName: "phone.fill")
                    .font(.system(size: 14))
                    .foregroundColor(AppTheme.crisisRed)

                VStack(alignment: .leading, spacing: 2) {
                    Text(name)
                        .font(AppFont.body)
                        .foregroundColor(AppTheme.textPrimary)
                    Text(number)
                        .font(AppFont.caption)
                        .foregroundColor(AppTheme.crisisRed)
                        .fontWeight(.medium)
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(AppTheme.textSecondary)
            }
            .padding(AppSpacing.md)
            .background(AppTheme.cardBackground)
            .cornerRadius(AppRadius.md)
        }
    }

    // MARK: - Share Button

    private var shareButton: some View {
        Button(action: {
            // Share action — in production this would invoke the system share sheet
        }) {
            HStack(spacing: AppSpacing.sm) {
                Image(systemName: "square.and.arrow.up.fill")
                    .font(.system(size: 16))
                Text("分享安全计划")
                    .font(AppFont.body.weight(.medium))
                    .fontWeight(.medium)
            }
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, AppSpacing.md)
            .background(AppTheme.primary)
            .cornerRadius(AppRadius.md)
        }
        .padding(.top, AppSpacing.sm)
    }

    // MARK: - Add Strategy Sheet

    private var addStrategySheet: some View {
        NavigationStack {
            VStack(spacing: AppSpacing.lg) {
                Text("添加安抚策略")
                    .font(AppFont.title1)
                    .foregroundColor(AppTheme.textPrimary)
                    .frame(maxWidth: .infinity, alignment: .leading)

                TextField("例如：做10个深蹲、喝一杯温水…", text: $newStrategyText, axis: .vertical)
                    .font(AppFont.body)
                    .padding(AppSpacing.md)
                    .background(AppTheme.surface)
                    .cornerRadius(AppRadius.md)
                    .lineLimit(2...4)

                Button(action: {
                    guard !newStrategyText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
                    calmingStrategies.append(SafetyPlanItem(text: newStrategyText))
                    showingAddStrategy = false
                }) {
                    Text("添加")
                        .fontWeight(.medium)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, AppSpacing.md)
                        .background(newStrategyText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
                            ? AppTheme.primaryMuted : AppTheme.primary)
                        .cornerRadius(AppRadius.md)
                }
                .disabled(newStrategyText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)

                Spacer()
            }
            .padding(AppSpacing.lg)
            .background(AppTheme.background)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("取消") { showingAddStrategy = false }
                        .foregroundColor(AppTheme.textSecondary)
                }
            }
        }
        .presentationDetents([.medium])
    }

    // MARK: - Add Contact Sheet

    private var addContactSheet: some View {
        NavigationStack {
            VStack(spacing: AppSpacing.lg) {
                Text("添加联系人")
                    .font(AppFont.title1)
                    .foregroundColor(AppTheme.textPrimary)
                    .frame(maxWidth: .infinity, alignment: .leading)

                TextField("联系人姓名", text: $newContactName)
                    .font(AppFont.body)
                    .padding(AppSpacing.md)
                    .background(AppTheme.surface)
                    .cornerRadius(AppRadius.md)

                TextField("电话号码", text: $newContactPhone)
                    .font(AppFont.body)
                    .padding(AppSpacing.md)
                    .background(AppTheme.surface)
                    .cornerRadius(AppRadius.md)
                    .keyboardType(.phonePad)

                Button(action: {
                    guard !newContactName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
                    emergencyContacts.append(
                        EmergencyContact(
                            name: newContactName,
                            phone: newContactPhone
                        )
                    )
                    showingAddContact = false
                }) {
                    Text("添加")
                        .fontWeight(.medium)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, AppSpacing.md)
                        .background(newContactName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
                            ? AppTheme.primaryMuted : AppTheme.primary)
                        .cornerRadius(AppRadius.md)
                }
                .disabled(newContactName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)

                Spacer()
            }
            .padding(AppSpacing.lg)
            .background(AppTheme.background)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("取消") { showingAddContact = false }
                        .foregroundColor(AppTheme.textSecondary)
                }
            }
        }
        .presentationDetents([.medium])
    }

    // MARK: - Helpers

    private func sectionHeader(icon: String, title: String, subtitle: String, color: Color) -> some View {
        VStack(alignment: .leading, spacing: AppSpacing.xs) {
            HStack(spacing: AppSpacing.sm) {
                Image(systemName: icon)
                    .font(.system(size: 16))
                    .foregroundColor(color)
                Text(title)
                    .font(AppFont.title3)
                    .foregroundColor(AppTheme.textPrimary)
            }
            Text(subtitle)
                .font(AppFont.footnote)
                .foregroundColor(AppTheme.textSecondary)
        }
    }
}

// MARK: - Supporting Types

struct SafetyPlanItem: Identifiable {
    let id = UUID()
    var text: String
    var isChecked: Bool = false
}

struct EmergencyContact: Identifiable {
    let id = UUID()
    var name: String
    var phone: String
}
