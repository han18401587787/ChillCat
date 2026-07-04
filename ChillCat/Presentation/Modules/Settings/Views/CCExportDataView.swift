//
//  CCExportDataView.swift
//  绪安 - 导出数据 (严格对照设计稿 page_07)
//

import SwiftUI

struct CCExportDataView: View {
    @State private var selectedFormat: ExportFormat = .pdf
    @State private var dateRange: DateRange = .lastMonth
    @State private var isExporting = false

    enum ExportFormat: String, CaseIterable { case pdf = "PDF", json = "JSON", csv = "CSV" }
    enum DateRange: String, CaseIterable { case lastWeek = "最近一周", lastMonth = "最近一月", last3Months = "最近三月", all = "全部数据" }

    var body: some View {
        ScrollView {
            VStack(spacing: XuanSpacing.xl2) {
                headerCard

                formatSelector

                dateRangeSelector

                exportButton
            }
            .padding(XuanSpacing.lg)
        }
        .background(Color.xuanApricotBg)
        .navigationTitle("导出数据")
        .navigationBarTitleDisplayMode(.large)
    }

    private var headerCard: some View {
        VStack(spacing: XuanSpacing.md) {
            Image("report_export")
                .font(.system(size: 36))
                .foregroundColor(Color.xuanApricotDark)

            Text("导出你的情绪数据")
                .font(XuanFont.h2)
                .foregroundColor(Color.xuanTextPrimary)

            Text("选择导出格式和时间范围，\n我们会将数据打包发送到你的邮箱。")
                .font(XuanFont.bodyM)
                .foregroundColor(Color.xuanTextSecondary)
                .multilineTextAlignment(.center)
                .lineSpacing(4)
        }
        .padding(XuanSpacing.xl)
        .frame(maxWidth: .infinity)
        .background(Color.xuanWhite)
        .cornerRadius(XuanRadius.lg)
        .xuanCardShadow()
    }

    private var formatSelector: some View {
        VStack(alignment: .leading, spacing: XuanSpacing.md) {
            Text("导出格式")
                .font(XuanFont.h3)
                .foregroundColor(Color.xuanTextPrimary)

            HStack(spacing: XuanSpacing.sm) {
                ForEach(ExportFormat.allCases, id: \.self) { format in
                    Button(action: { selectedFormat = format }) {
                        VStack(spacing: XuanSpacing.xs) {
                            CCIconMapper.image(for: formatIcon(format))
                                .font(.system(size: 24))
                            Text(format.rawValue)
                                .font(XuanFont.bodyS)
                        }
                        .foregroundColor(selectedFormat == format ? .white : Color.xuanTextSecondary)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, XuanSpacing.lg)
                        .background(selectedFormat == format ? Color.xuanApricot : Color.xuanSurface)
                        .cornerRadius(XuanRadius.md)
                    }
                }
            }
        }
        .padding(XuanSpacing.lg)
        .background(Color.xuanWhite)
        .cornerRadius(XuanRadius.lg)
        .xuanCardShadow()
    }

    private func formatIcon(_ format: ExportFormat) -> String {
        switch format {
        case .pdf: return "doc.richtext.fill"
        case .json: return "curlybraces"
        case .csv: return "tablecells.fill"
        }
    }

    private var dateRangeSelector: some View {
        VStack(alignment: .leading, spacing: XuanSpacing.md) {
            Text("时间范围")
                .font(XuanFont.h3)
                .foregroundColor(Color.xuanTextPrimary)

            VStack(spacing: XuanSpacing.sm) {
                ForEach(DateRange.allCases, id: \.self) { range in
                    Button(action: { dateRange = range }) {
                        HStack {
                            Text(range.rawValue)
                                .font(XuanFont.bodyL)
                                .foregroundColor(Color.xuanTextPrimary)
                            Spacer()
                            if dateRange == range {
                                Image("home_checkin")
                                    .font(.system(size: 20))
                                    .foregroundColor(Color.xuanApricot)
                            }
                        }
                        .padding(XuanSpacing.md)
                        .background(dateRange == range ? Color.xuanApricot.opacity(0.06) : Color.clear)
                        .cornerRadius(XuanRadius.md)
                    }
                    .buttonStyle(.plain)
                }
            }
        }
        .padding(XuanSpacing.lg)
        .background(Color.xuanWhite)
        .cornerRadius(XuanRadius.lg)
        .xuanCardShadow()
    }

    private var exportButton: some View {
        Button(action: {
            isExporting = true
            Task {
                try? await Task.sleep(nanoseconds: 2_000_000_000)
                isExporting = false
            }
        }) {
            HStack(spacing: XuanSpacing.sm) {
                if isExporting {
                    ProgressView().tint(.white)
                } else {
                    Image("report_export")
                }
                Text(isExporting ? "正在导出..." : "确认导出")
            }
            .font(XuanFont.bodyLMedium)
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(Color.xuanApricot)
            .cornerRadius(XuanRadius.lg)
        }
        .disabled(isExporting)
    }
}

#Preview { NavigationStack { CCExportDataView() } }
