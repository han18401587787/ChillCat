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
            VStack(spacing: XuanSpacing.xl) {
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
            .padding(XuanSpacing.lg)
        }
        .background(Color.xuanApricotBg)
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
        VStack(spacing: XuanSpacing.sm) {
            Image("alert_guardian")
                .font(.system(size: 36))
                .foregroundColor(Color.xuanApricotDark)

            Text("安全守护")
                .font(XuanFont.h1)
                .foregroundColor(Color.xuanTextPrimary)

            Text("提前准备，从容应对。安全计划是你在情绪危机时可以依靠的个性化方案。")
                .font(XuanFont.bodyM)
                .foregroundColor(Color.xuanTextSecondary)
                .multilineTextAlignment(.center)
                .lineSpacing(4)
        }
        .padding(XuanSpacing.xl)
        .frame(maxWidth: .infinity)
        .background(Color.xuanWhite)
        .cornerRadius(XuanRadius.lg)
    }

    // MARK: - Warning Signs Section

    private var warningSignsSection: some View {
        VStack(alignment: .leading, spacing: XuanSpacing.md) {
            sectionHeader(
                icon: "exclamationmark.triangle.fill",
                title: "预警信号",
                subtitle: "当我出现以下情况时，我知道自己需要寻求帮助",
                color: Color.xuanApricotDark
            )

            VStack(spacing: XuanSpacing.sm) {
                ForEach($warningSigns) { $item in
                    warningSignRow(item: $item)
                }
            }
        }
    }

    private func warningSignRow(item: Binding<SafetyPlanItem>) -> some View {
        HStack(spacing: XuanSpacing.md) {
            Button(action: {
                withAnimation(.easeInOut(duration: 0.3)) {
                    item.wrappedValue.isChecked.toggle()
                }
            }) {
                CCIconMapper.image(for: item.wrappedValue.isChecked ? "checkmark.circle.fill" : "circle")
                    .font(.system(size: 22))
                    .foregroundColor(item.wrappedValue.isChecked ? Color.xuanApricotDark : Color.xuanTextSecondary)
            }

            Text(item.wrappedValue.text)
                .font(XuanFont.bodyL)
                .foregroundColor(
                    item.wrappedValue.isChecked ? Color.xuanTextSecondary : Color.xuanTextPrimary
                )
                .strikethrough(item.wrappedValue.isChecked)

            Spacer()
        }
        .padding(XuanSpacing.md)
        .background(Color.xuanWhite)
        .cornerRadius(XuanRadius.md)
    }

    // MARK: - Calming Strategies Section

    private var calmingStrategiesSection: some View {
        VStack(alignment: .leading, spacing: XuanSpacing.md) {
            sectionHeader(
                icon: "leaf.fill",
                title: "安抚策略",
                subtitle: "当我感到情绪失控时，可以尝试以下方法",
                color: Color.xuanMint
            )

            VStack(spacing: XuanSpacing.sm) {
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
                    Image("common_add")
                        .font(.system(size: 16))
                    Text("添加安抚策略")
                        .font(XuanFont.bodyL)
                }
                .foregroundColor(Color.xuanMint)
                .frame(maxWidth: .infinity)
                .padding(.vertical, XuanSpacing.sm)
                .background(Color.xuanMint.opacity(0.08))
                .cornerRadius(XuanRadius.sm)
            }
        }
    }

    private func strategyRow(item: Binding<SafetyPlanItem>) -> some View {
        HStack(spacing: XuanSpacing.md) {
            Button(action: {
                withAnimation(.easeInOut(duration: 0.3)) {
                    item.wrappedValue.isChecked.toggle()
                }
            }) {
                CCIconMapper.image(for: item.wrappedValue.isChecked ? "checkmark.circle.fill" : "circle")
                    .font(.system(size: 22))
                    .foregroundColor(item.wrappedValue.isChecked ? Color.xuanMint : Color.xuanTextSecondary)
            }

            Text(item.wrappedValue.text)
                .font(XuanFont.bodyL)
                .foregroundColor(
                    item.wrappedValue.isChecked ? Color.xuanTextSecondary : Color.xuanTextPrimary
                )
                .strikethrough(item.wrappedValue.isChecked)

            Spacer()
        }
        .padding(XuanSpacing.md)
        .background(Color.xuanWhite)
        .cornerRadius(XuanRadius.md)
    }

    // MARK: - Support Contacts Section

    private var supportContactsSection: some View {
        VStack(alignment: .leading, spacing: XuanSpacing.md) {
            sectionHeader(
                icon: "person.2.fill",
                title: "支持联系人",
                subtitle: "当我需要倾诉时，可以联系这些人",
                color: Color(hex: "A085C6")
            )

            VStack(spacing: XuanSpacing.sm) {
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
                    Image("common_add")
                        .font(.system(size: 16))
                    Text("添加联系人")
                        .font(XuanFont.bodyL)
                }
                .foregroundColor(Color(hex: "A085C6"))
                .frame(maxWidth: .infinity)
                .padding(.vertical, XuanSpacing.sm)
                .background(Color(hex: "A085C6").opacity(0.08))
                .cornerRadius(XuanRadius.sm)
            }
        }
    }

    private func contactRow(contact: Binding<EmergencyContact>) -> some View {
        HStack(spacing: XuanSpacing.md) {
            Image("profile_user")
                .font(.system(size: 28))
                .foregroundColor(Color(hex: "A085C6"))

            VStack(alignment: .leading, spacing: 2) {
                TextField("联系人姓名", text: contact.name)
                    .font(XuanFont.bodyL)
                    .foregroundColor(Color.xuanTextPrimary)
                TextField("电话号码", text: contact.phone)
                    .font(XuanFont.bodyS)
                    .foregroundColor(Color.xuanTextSecondary)
                    .keyboardType(.phonePad)
            }

            Spacer()

            if !contact.wrappedValue.phone.isEmpty {
                Link(destination: URL(string: "tel:\(contact.wrappedValue.phone.replacingOccurrences(of: " ", with: ""))")!) {
                    Image("alert_call")
                        .font(.system(size: 14))
                        .foregroundColor(Color.xuanApricot)
                        .frame(width: 32, height: 32)
                        .background(Color.xuanApricot.opacity(0.12))
                        .cornerRadius(XuanRadius.sm)
                }
            }
        }
        .padding(XuanSpacing.md)
        .background(Color.xuanWhite)
        .cornerRadius(XuanRadius.md)
    }

    // MARK: - Professional Resources Quick Links

    private var professionalResourcesSection: some View {
        VStack(alignment: .leading, spacing: XuanSpacing.md) {
            sectionHeader(
                icon: "cross.case.fill",
                title: "专业资源",
                subtitle: "快速拨打专业援助热线",
                color: Color.xuanDanger
            )

            VStack(spacing: XuanSpacing.sm) {
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
                Image("alert_call")
                    .font(.system(size: 14))
                    .foregroundColor(Color.xuanDanger)

                VStack(alignment: .leading, spacing: 2) {
                    Text(name)
                        .font(XuanFont.bodyL)
                        .foregroundColor(Color.xuanTextPrimary)
                    Text(number)
                        .font(XuanFont.bodyM)
                        .foregroundColor(Color.xuanDanger)
                        .fontWeight(.medium)
                }

                Spacer()

                Image("common_more")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(Color.xuanTextSecondary)
            }
            .padding(XuanSpacing.md)
            .background(Color.xuanWhite)
            .cornerRadius(XuanRadius.md)
        }
    }

    // MARK: - Share Button

    private var shareButton: some View {
        Button(action: {
            // Share action — in production this would invoke the system share sheet
        }) {
            HStack(spacing: XuanSpacing.sm) {
                Image("report_share")
                    .font(.system(size: 16))
                Text("分享安全计划")
                    .font(XuanFont.bodyLMedium)
                    .fontWeight(.medium)
            }
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, XuanSpacing.md)
            .background(Color.xuanApricot)
            .cornerRadius(XuanRadius.md)
        }
        .padding(.top, XuanSpacing.sm)
    }

    // MARK: - Add Strategy Sheet

    private var addStrategySheet: some View {
        NavigationStack {
            VStack(spacing: XuanSpacing.lg) {
                Text("添加安抚策略")
                    .font(XuanFont.h1)
                    .foregroundColor(Color.xuanTextPrimary)
                    .frame(maxWidth: .infinity, alignment: .leading)

                TextField("例如：做10个深蹲、喝一杯温水…", text: $newStrategyText, axis: .vertical)
                    .font(XuanFont.bodyL)
                    .padding(XuanSpacing.md)
                    .background(Color.xuanSurface)
                    .cornerRadius(XuanRadius.md)
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
                        .padding(.vertical, XuanSpacing.md)
                        .background(newStrategyText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
                            ? Color.xuanApricot.opacity(0.6) : Color.xuanApricot)
                        .cornerRadius(XuanRadius.md)
                }
                .disabled(newStrategyText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)

                Spacer()
            }
            .padding(XuanSpacing.lg)
            .background(Color.xuanApricotBg)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("取消") { showingAddStrategy = false }
                        .foregroundColor(Color.xuanTextSecondary)
                }
            }
        }
        .presentationDetents([.medium])
    }

    // MARK: - Add Contact Sheet

    private var addContactSheet: some View {
        NavigationStack {
            VStack(spacing: XuanSpacing.lg) {
                Text("添加联系人")
                    .font(XuanFont.h1)
                    .foregroundColor(Color.xuanTextPrimary)
                    .frame(maxWidth: .infinity, alignment: .leading)

                TextField("联系人姓名", text: $newContactName)
                    .font(XuanFont.bodyL)
                    .padding(XuanSpacing.md)
                    .background(Color.xuanSurface)
                    .cornerRadius(XuanRadius.md)

                TextField("电话号码", text: $newContactPhone)
                    .font(XuanFont.bodyL)
                    .padding(XuanSpacing.md)
                    .background(Color.xuanSurface)
                    .cornerRadius(XuanRadius.md)
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
                        .padding(.vertical, XuanSpacing.md)
                        .background(newContactName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
                            ? Color.xuanApricot.opacity(0.6) : Color.xuanApricot)
                        .cornerRadius(XuanRadius.md)
                }
                .disabled(newContactName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)

                Spacer()
            }
            .padding(XuanSpacing.lg)
            .background(Color.xuanApricotBg)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("取消") { showingAddContact = false }
                        .foregroundColor(Color.xuanTextSecondary)
                }
            }
        }
        .presentationDetents([.medium])
    }

    // MARK: - Helpers

    private func sectionHeader(icon: String, title: String, subtitle: String, color: Color) -> some View {
        VStack(alignment: .leading, spacing: XuanSpacing.xs) {
            HStack(spacing: XuanSpacing.sm) {
                CCIconMapper.image(for: icon)
                    .font(.system(size: 16))
                    .foregroundColor(color)
                Text(title)
                    .font(XuanFont.h3)
                    .foregroundColor(Color.xuanTextPrimary)
            }
            Text(subtitle)
                .font(XuanFont.bodyS)
                .foregroundColor(Color.xuanTextSecondary)
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
