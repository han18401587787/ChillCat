//
//  CCSafetyPlanView.swift
//  ChillCat
//
//  安全计划 — 预警信号识别、安抚策略、支持联系人、专业资源链接
//

import SwiftUI

struct CCSafetyPlanView: View {
    @Environment(\.ccAppTheme) private var theme
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
            VStack(spacing: theme.spacingXL) {
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
            .padding(theme.spacingLG)
        }
        .background(theme.background)
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
        VStack(spacing: theme.spacingSM) {
            Image(systemName: "shield.checkered")
                .font(.system(size: 36))
                .foregroundColor(theme.primary)

            Text("提前准备，从容应对")
                .font(theme.fontH2)
                .foregroundColor(theme.textPrimary)

            Text("安全计划是你在情绪危机时可以依靠的个性化方案。花一点时间填写它，未来你会感谢现在的自己。")
                .font(theme.fontBody)
                .foregroundColor(theme.textSecondary)
                .multilineTextAlignment(.center)
                .lineSpacing(4)
        }
        .padding(theme.spacingXL)
        .frame(maxWidth: .infinity)
        .background(theme.cardBackground)
        .cornerRadius(theme.radiusLG)
    }

    // MARK: - Warning Signs Section

    private var warningSignsSection: some View {
        VStack(alignment: .leading, spacing: theme.spacingMD) {
            sectionHeader(
                icon: "exclamationmark.triangle.fill",
                title: "预警信号",
                subtitle: "当我出现以下情况时，我知道自己需要寻求帮助",
                color: theme.warm
            )

            VStack(spacing: theme.spacingSM) {
                ForEach($warningSigns) { $item in
                    warningSignRow(item: $item)
                }
            }
        }
    }

    private func warningSignRow(item: Binding<SafetyPlanItem>) -> some View {
        HStack(spacing: theme.spacingMD) {
            Button(action: {
                withAnimation(.easeInOut(duration: theme.durationNormal)) {
                    item.wrappedValue.isChecked.toggle()
                }
            }) {
                Image(systemName: item.wrappedValue.isChecked ? "checkmark.circle.fill" : "circle")
                    .font(.system(size: 22))
                    .foregroundColor(item.wrappedValue.isChecked ? theme.warm : theme.textMuted)
            }

            Text(item.wrappedValue.text)
                .font(theme.fontBody)
                .foregroundColor(
                    item.wrappedValue.isChecked ? theme.textSecondary : theme.textPrimary
                )
                .strikethrough(item.wrappedValue.isChecked)

            Spacer()
        }
        .padding(theme.spacingMD)
        .background(theme.cardBackground)
        .cornerRadius(theme.radiusMD)
    }

    // MARK: - Calming Strategies Section

    private var calmingStrategiesSection: some View {
        VStack(alignment: .leading, spacing: theme.spacingMD) {
            sectionHeader(
                icon: "leaf.fill",
                title: "安抚策略",
                subtitle: "当我感到情绪失控时，可以尝试以下方法",
                color: theme.softGreen
            )

            VStack(spacing: theme.spacingSM) {
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
                        .font(theme.fontBody)
                }
                .foregroundColor(theme.softGreen)
                .frame(maxWidth: .infinity)
                .padding(.vertical, theme.spacingSM)
                .background(theme.softGreen.opacity(0.08))
                .cornerRadius(theme.radiusSM)
            }
        }
    }

    private func strategyRow(item: Binding<SafetyPlanItem>) -> some View {
        HStack(spacing: theme.spacingMD) {
            Button(action: {
                withAnimation(.easeInOut(duration: theme.durationNormal)) {
                    item.wrappedValue.isChecked.toggle()
                }
            }) {
                Image(systemName: item.wrappedValue.isChecked ? "checkmark.circle.fill" : "circle")
                    .font(.system(size: 22))
                    .foregroundColor(item.wrappedValue.isChecked ? theme.softGreen : theme.textMuted)
            }

            Text(item.wrappedValue.text)
                .font(theme.fontBody)
                .foregroundColor(
                    item.wrappedValue.isChecked ? theme.textSecondary : theme.textPrimary
                )
                .strikethrough(item.wrappedValue.isChecked)

            Spacer()
        }
        .padding(theme.spacingMD)
        .background(theme.cardBackground)
        .cornerRadius(theme.radiusMD)
    }

    // MARK: - Support Contacts Section

    private var supportContactsSection: some View {
        VStack(alignment: .leading, spacing: theme.spacingMD) {
            sectionHeader(
                icon: "person.2.fill",
                title: "支持联系人",
                subtitle: "当我需要倾诉时，可以联系这些人",
                color: theme.softPurple
            )

            VStack(spacing: theme.spacingSM) {
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
                        .font(theme.fontBody)
                }
                .foregroundColor(theme.softPurple)
                .frame(maxWidth: .infinity)
                .padding(.vertical, theme.spacingSM)
                .background(theme.softPurple.opacity(0.08))
                .cornerRadius(theme.radiusSM)
            }
        }
    }

    private func contactRow(contact: Binding<EmergencyContact>) -> some View {
        HStack(spacing: theme.spacingMD) {
            Image(systemName: "person.crop.circle.fill")
                .font(.system(size: 28))
                .foregroundColor(theme.softPurple)

            VStack(alignment: .leading, spacing: 2) {
                TextField("联系人姓名", text: contact.name)
                    .font(theme.fontBody)
                    .foregroundColor(theme.textPrimary)
                TextField("电话号码", text: contact.phone)
                    .font(theme.fontBodyS)
                    .foregroundColor(theme.textSecondary)
                    .keyboardType(.phonePad)
            }

            Spacer()

            if !contact.wrappedValue.phone.isEmpty {
                Link(destination: URL(string: "tel:\(contact.wrappedValue.phone.replacingOccurrences(of: " ", with: ""))")!) {
                    Image(systemName: "phone.fill")
                        .font(.system(size: 14))
                        .foregroundColor(theme.primary)
                        .frame(width: 32, height: 32)
                        .background(theme.primary.opacity(0.12))
                        .cornerRadius(theme.radiusSM)
                }
            }
        }
        .padding(theme.spacingMD)
        .background(theme.cardBackground)
        .cornerRadius(theme.radiusMD)
    }

    // MARK: - Professional Resources Quick Links

    private var professionalResourcesSection: some View {
        VStack(alignment: .leading, spacing: theme.spacingMD) {
            sectionHeader(
                icon: "cross.case.fill",
                title: "专业资源",
                subtitle: "快速拨打专业援助热线",
                color: theme.error
            )

            VStack(spacing: theme.spacingSM) {
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
                    .foregroundColor(theme.error)

                VStack(alignment: .leading, spacing: 2) {
                    Text(name)
                        .font(theme.fontBody)
                        .foregroundColor(theme.textPrimary)
                    Text(number)
                        .font(theme.fontCaption)
                        .foregroundColor(theme.error)
                        .fontWeight(.medium)
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(theme.textMuted)
            }
            .padding(theme.spacingMD)
            .background(theme.cardBackground)
            .cornerRadius(theme.radiusMD)
        }
    }

    // MARK: - Share Button

    private var shareButton: some View {
        Button(action: {
            // Share action — in production this would invoke the system share sheet
        }) {
            HStack(spacing: theme.spacingSM) {
                Image(systemName: "square.and.arrow.up.fill")
                    .font(.system(size: 16))
                Text("分享安全计划")
                    .font(theme.fontBodyL)
                    .fontWeight(.medium)
            }
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, theme.spacingMD)
            .background(theme.primary)
            .cornerRadius(theme.radiusMD)
        }
        .padding(.top, theme.spacingSM)
    }

    // MARK: - Add Strategy Sheet

    private var addStrategySheet: some View {
        NavigationStack {
            VStack(spacing: theme.spacingLG) {
                Text("添加安抚策略")
                    .font(theme.fontH2)
                    .foregroundColor(theme.textPrimary)
                    .frame(maxWidth: .infinity, alignment: .leading)

                TextField("例如：做10个深蹲、喝一杯温水…", text: $newStrategyText, axis: .vertical)
                    .font(theme.fontBody)
                    .padding(theme.spacingMD)
                    .background(theme.surface)
                    .cornerRadius(theme.radiusMD)
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
                        .padding(.vertical, theme.spacingMD)
                        .background(newStrategyText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
                            ? theme.primaryMuted : theme.primary)
                        .cornerRadius(theme.radiusMD)
                }
                .disabled(newStrategyText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)

                Spacer()
            }
            .padding(theme.spacingLG)
            .background(theme.background)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("取消") { showingAddStrategy = false }
                        .foregroundColor(theme.textSecondary)
                }
            }
        }
        .presentationDetents([.medium])
    }

    // MARK: - Add Contact Sheet

    private var addContactSheet: some View {
        NavigationStack {
            VStack(spacing: theme.spacingLG) {
                Text("添加联系人")
                    .font(theme.fontH2)
                    .foregroundColor(theme.textPrimary)
                    .frame(maxWidth: .infinity, alignment: .leading)

                TextField("联系人姓名", text: $newContactName)
                    .font(theme.fontBody)
                    .padding(theme.spacingMD)
                    .background(theme.surface)
                    .cornerRadius(theme.radiusMD)

                TextField("电话号码", text: $newContactPhone)
                    .font(theme.fontBody)
                    .padding(theme.spacingMD)
                    .background(theme.surface)
                    .cornerRadius(theme.radiusMD)
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
                        .padding(.vertical, theme.spacingMD)
                        .background(newContactName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
                            ? theme.primaryMuted : theme.primary)
                        .cornerRadius(theme.radiusMD)
                }
                .disabled(newContactName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)

                Spacer()
            }
            .padding(theme.spacingLG)
            .background(theme.background)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("取消") { showingAddContact = false }
                        .foregroundColor(theme.textSecondary)
                }
            }
        }
        .presentationDetents([.medium])
    }

    // MARK: - Helpers

    private func sectionHeader(icon: String, title: String, subtitle: String, color: Color) -> some View {
        VStack(alignment: .leading, spacing: theme.spacingXS) {
            HStack(spacing: theme.spacingSM) {
                Image(systemName: icon)
                    .font(.system(size: 16))
                    .foregroundColor(color)
                Text(title)
                    .font(theme.fontH3)
                    .foregroundColor(theme.textPrimary)
            }
            Text(subtitle)
                .font(theme.fontBodyS)
                .foregroundColor(theme.textMuted)
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
