import SwiftUI
import SwiftData

/// 饮食记录页面 — 日历 + 列表 + 统计入口
struct RecordView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \MealRecord.date, order: .reverse) private var allRecords: [MealRecord]
    @State private var selectedDate: Date = .now
    @State private var showStats = false

    var body: some View {
        ScrollView {
            VStack(spacing: AppLayout.sectionSpacing) {

                // ── 月历网格 ──
                calendarSection

                // ── 选中日期的记录 ──
                selectedDaySection

                // ── 本周速览 ──
                weekSummary
            }
            .padding(.vertical, AppLayout.pagePadding)
        }
        .background(AppColors.pageBg.ignoresSafeArea())
        .navigationTitle("饮食记录")
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    showStats = true
                } label: {
                    Image(systemName: "chart.pie")
                }
            }
        }
        .sheet(isPresented: $showStats) {
            NavigationStack {
                StatsView(records: allRecords)
            }
        }
    }

    // MARK: - 日历

    private var calendarSection: some View {
        VStack(spacing: 12) {
            // 月份导航
            HStack {
                Button {
                    if let prev = Calendar.current.date(byAdding: .month, value: -1, to: selectedDate) {
                        withAnimation { selectedDate = prev }
                    }
                } label: {
                    Image(systemName: "chevron.left")
                }
                Spacer()
                Text(monthYearString)
                    .font(AppFonts.sectionTitle)
                Spacer()
                Button {
                    if let next = Calendar.current.date(byAdding: .month, value: 1, to: selectedDate) {
                        withAnimation { selectedDate = next }
                    }
                } label: {
                    Image(systemName: "chevron.right")
                }
            }
            .padding(.horizontal, AppLayout.pagePadding)

            // 星期表头
            let weekdays = ["日", "一", "二", "三", "四", "五", "六"]
            HStack {
                ForEach(weekdays, id: \.self) { d in
                    Text(d)
                        .font(AppFonts.tiny)
                        .foregroundStyle(.secondary)
                        .frame(maxWidth: .infinity)
                }
            }
            .padding(.horizontal, AppLayout.pagePadding)

            // 日期网格
            let days = calendarDays
            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 2), count: 7), spacing: 6) {
                ForEach(days, id: \.self) { date in
                    if let date {
                        calendarDayCell(date)
                    } else {
                        Color.clear.frame(height: 40)
                    }
                }
            }
            .padding(.horizontal, AppLayout.pagePadding)
        }
        .cardStyle()
        .padding(.horizontal, AppLayout.pagePadding)
    }

    private func calendarDayCell(_ date: Date) -> some View {
        let cal = Calendar.current
        let isToday = cal.isDateInToday(date)
        let isSelected = cal.isDate(date, inSameDayAs: selectedDate)
        let dayRecords = recordsFor(date)
        let hasRecords = !dayRecords.isEmpty

        return Button {
            withAnimation(AppAnimations.bouncy) { selectedDate = date }
        } label: {
            VStack(spacing: 2) {
                Text("\(cal.component(.day, from: date))")
                    .font(isToday ? AppFonts.captionBold : AppFonts.caption)
                    .foregroundStyle(isSelected ? .white : isToday ? AppColors.warmOrange : .primary)

                // 记录指示点
                if hasRecords {
                    Circle()
                        .fill(isSelected ? .white : AppColors.warmOrange)
                        .frame(width: 5, height: 5)
                } else {
                    Color.clear.frame(width: 5, height: 5)
                }
            }
            .frame(maxWidth: .infinity)
            .frame(height: 40)
            .background(
                RoundedRectangle(cornerRadius: 8, style: .continuous)
                    .fill(isSelected ? AppColors.warmOrange : .clear)
            )
        }
        .buttonStyle(.plain)
        .accessibilityLabel("\(cal.component(.day, from: date))日\(hasRecords ? "，有记录" : "")")
    }

    // MARK: - 选中日期记录

    private var selectedDaySection: some View {
        let dayRecords = recordsFor(selectedDate)

        return VStack(alignment: .leading, spacing: 10) {
            Text(selectedDateString)
                .font(AppFonts.sectionTitle)
                .padding(.horizontal, AppLayout.pagePadding)

            if dayRecords.isEmpty {
                HStack {
                    Spacer()
                    VStack(spacing: 8) {
                        Image(systemName: "fork.knife.circle")
                            .font(.largeTitle)
                            .foregroundStyle(.tertiary)
                        Text("这天还没有记录")
                            .font(AppFonts.caption)
                            .foregroundStyle(.secondary)
                    }
                    Spacer()
                }
                .padding(.vertical, 20)
            } else {
                ForEach(dayRecords) { record in
                    HStack(spacing: 12) {
                        Text(record.emoji)
                            .font(.title2)
                        VStack(alignment: .leading, spacing: 2) {
                            Text(record.foodName)
                                .font(AppFonts.bodyMedium)
                            Text(record.cuisine)
                                .font(AppFonts.caption)
                                .foregroundStyle(.secondary)
                        }
                        Spacer()
                        Text(record.date, format: .dateTime.hour().minute())
                            .font(AppFonts.tiny)
                            .foregroundStyle(.tertiary)
                    }
                    .padding(.horizontal, AppLayout.pagePadding)
                    .padding(.vertical, 6)
                }
            }
        }
    }

    // MARK: - 本周速览

    private var weekSummary: some View {
        let cal = Calendar.current
        let startOfWeek = cal.date(from: cal.dateComponents([.yearForWeekOfYear, .weekOfYear], from: Date.now)) ?? Date.now
        let endOfWeek = cal.date(byAdding: .day, value: 7, to: startOfWeek) ?? Date.now
        let weekRecs = allRecords.filter { $0.date >= startOfWeek && $0.date < endOfWeek }

        return VStack(alignment: .leading, spacing: 10) {
            Text("本周概览")
                .font(AppFonts.sectionTitle)

            HStack(spacing: 0) {
                statBadge(value: "\(weekRecs.count)", label: "总餐数")
                statBadge(value: "\(Set(weekRecs.map(\.foodName)).count)", label: "不同食物")
                statBadge(value: "\(Set(weekRecs.map(\.cuisine)).count)", label: "涉及菜系")
            }
        }
        .cardStyle()
        .padding(.horizontal, AppLayout.pagePadding)
    }

    private func statBadge(value: String, label: String) -> some View {
        VStack(spacing: 4) {
            Text(value)
                .font(AppFonts.statNumber)
                .foregroundStyle(AppColors.warmOrange)
            Text(label)
                .font(AppFonts.statLabel)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
    }

    // MARK: - Helpers

    private func recordsFor(_ date: Date) -> [MealRecord] {
        let cal = Calendar.current
        return allRecords.filter { cal.isDate($0.date, inSameDayAs: date) }
    }

    private static let monthYearFormatter: DateFormatter = {
        let fmt = DateFormatter()
        fmt.dateFormat = "yyyy年M月"
        return fmt
    }()

    private static let selectedDateFormatter: DateFormatter = {
        let fmt = DateFormatter()
        fmt.dateFormat = "M月d日 EEEE"
        fmt.locale = Locale(identifier: "zh_CN")
        return fmt
    }()

    private var monthYearString: String {
        Self.monthYearFormatter.string(from: selectedDate)
    }

    private var selectedDateString: String {
        Self.selectedDateFormatter.string(from: selectedDate)
    }

    private var calendarDays: [Date?] {
        let cal = Calendar.current
        let comps = cal.dateComponents([.year, .month], from: selectedDate)
        guard let firstOfMonth = cal.date(from: comps),
              let range = cal.range(of: .day, in: .month, for: firstOfMonth) else { return [] }
        let weekdayOfFirst = cal.component(.weekday, from: firstOfMonth) - 1 // 0=Sun
        let daysInMonth = range.count

        var days: [Date?] = Array(repeating: nil, count: weekdayOfFirst)
        for d in 1...daysInMonth {
            var dc = comps
            dc.day = d
            days.append(cal.date(from: dc))
        }
        // Pad to complete last row
        while days.count % 7 != 0 { days.append(nil) }
        return days
    }
}
