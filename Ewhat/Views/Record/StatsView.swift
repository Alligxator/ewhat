import SwiftUI

/// 饮食统计页面 — 菜系分布 + Top5 + 时间维度
struct StatsView: View {
    let records: [MealRecord]
    @Environment(\.dismiss) private var dismiss
    @State private var timeScope: TimeScope = .month

    enum TimeScope: String, CaseIterable { case week = "本周", month = "本月", all = "全部" }

    private var scopedRecords: [MealRecord] {
        let cal = Calendar.current
        let now = Date.now
        switch timeScope {
        case .week:
            let start = cal.date(from: cal.dateComponents([.yearForWeekOfYear, .weekOfYear], from: now)) ?? now
            return records.filter { $0.date >= start }
        case .month:
            let start = cal.date(from: cal.dateComponents([.year, .month], from: now)) ?? now
            return records.filter { $0.date >= start }
        case .all:
            return records
        }
    }

    var body: some View {
        ScrollView {
            VStack(spacing: AppLayout.sectionSpacing) {

                // ── 时间维度选择 ──
                Picker("时间范围", selection: $timeScope) {
                    ForEach(TimeScope.allCases, id: \.self) { s in
                        Text(s.rawValue).tag(s)
                    }
                }
                .pickerStyle(.segmented)
                .padding(.horizontal, AppLayout.pagePadding)

                // ── 概览数字 ──
                HStack(spacing: 0) {
                    overviewBadge(value: "\(scopedRecords.count)", label: "总餐数", color: AppColors.warmOrange)
                    overviewBadge(value: "\(Set(scopedRecords.map(\.foodName)).count)", label: "不同食物", color: AppColors.jadeGreen)
                    overviewBadge(value: "\(Set(scopedRecords.map(\.cuisine)).count)", label: "菜系", color: AppColors.fortune)
                }
                .cardStyle()
                .padding(.horizontal, AppLayout.pagePadding)

                // ── 菜系分布 ──
                VStack(alignment: .leading, spacing: 12) {
                    Text("菜系分布")
                        .font(AppFonts.sectionTitle)

                    if cuisineData.isEmpty {
                        Text("暂无数据")
                            .font(AppFonts.caption)
                            .foregroundStyle(.secondary)
                            .frame(maxWidth: .infinity, alignment: .center)
                            .padding()
                    } else {
                        ForEach(cuisineData, id: \.cuisine) { item in
                            HStack(spacing: 10) {
                                Text(item.cuisine)
                                    .font(AppFonts.caption)
                                    .frame(width: 50, alignment: .trailing)

                                GeometryReader { geo in
                                    RoundedRectangle(cornerRadius: 4, style: .continuous)
                                        .fill(
                                            LinearGradient(
                                                colors: [AppColors.warmOrange, AppColors.warmAmber],
                                                startPoint: .leading, endPoint: .trailing
                                            )
                                        )
                                        .frame(width: max(4, geo.size.width * item.ratio))
                                        .animation(.spring(duration: 0.5), value: item.ratio)
                                }
                                .frame(height: 18)

                                Text("\(item.count)")
                                    .font(AppFonts.captionBold)
                                    .foregroundStyle(.secondary)
                                    .frame(width: 24, alignment: .leading)
                            }
                        }
                    }
                }
                .cardStyle()
                .padding(.horizontal, AppLayout.pagePadding)

                // ── 最爱 Top 5 ──
                VStack(alignment: .leading, spacing: 12) {
                    Text("最爱 Top 5")
                        .font(AppFonts.sectionTitle)

                    if topFoods.isEmpty {
                        Text("暂无数据")
                            .font(AppFonts.caption)
                            .foregroundStyle(.secondary)
                            .frame(maxWidth: .infinity, alignment: .center)
                            .padding()
                    } else {
                        ForEach(Array(topFoods.enumerated()), id: \.offset) { idx, item in
                            HStack(spacing: 12) {
                                // 排名
                                Text("\(idx + 1)")
                                    .font(AppFonts.captionBold)
                                    .foregroundStyle(idx < 3 ? AppColors.warmOrange : .secondary)
                                    .frame(width: 20)

                                Text(item.emoji)
                                    .font(.title3)

                                Text(item.name)
                                    .font(AppFonts.bodyMedium)

                                Spacer()

                                Text("\(item.count) 次")
                                    .font(AppFonts.caption)
                                    .foregroundStyle(.secondary)
                            }
                            .padding(.vertical, 4)

                            if idx < topFoods.count - 1 {
                                Divider()
                            }
                        }
                    }
                }
                .cardStyle()
                .padding(.horizontal, AppLayout.pagePadding)
            }
            .padding(.vertical, AppLayout.pagePadding)
        }
        .background(AppColors.pageBg.ignoresSafeArea())
        .navigationTitle("统计")
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("关闭") { dismiss() }
            }
        }
    }

    // MARK: - Data

    private var cuisineData: [(cuisine: String, count: Int, ratio: CGFloat)] {
        let grouped = Dictionary(grouping: scopedRecords, by: \.cuisine)
        let sorted = grouped.map { ($0.key, $0.value.count) }.sorted { $0.1 > $1.1 }
        let maxCount = sorted.first?.1 ?? 1
        return sorted.map { ($0.0, $0.1, CGFloat($0.1) / CGFloat(maxCount)) }
    }

    private var topFoods: [(name: String, emoji: String, count: Int)] {
        let grouped = Dictionary(grouping: scopedRecords, by: \.foodName)
        return grouped.map { (key, vals) in
            (key, vals.first?.emoji ?? "🍽️", vals.count)
        }
        .sorted { $0.count > $1.count }
        .prefix(5)
        .map { ($0.0, $0.1, $0.2) }
    }

    private func overviewBadge(value: String, label: String, color: Color) -> some View {
        VStack(spacing: 4) {
            Text(value)
                .font(AppFonts.statNumber)
                .foregroundStyle(color)
            Text(label)
                .font(AppFonts.statLabel)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
    }
}
