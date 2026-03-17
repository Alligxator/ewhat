import SwiftUI
import SwiftData

/// 饮食记录管理 ViewModel
@MainActor
@Observable
final class RecordViewModel {

    // MARK: - State

    /// 当前查询范围的记录
    var records: [MealRecord] = []

    /// 本周记录
    var weekRecords: [MealRecord] = []

    /// 本月记录
    var monthRecords: [MealRecord] = []

    /// 今日记录
    var todayRecords: [MealRecord] = []

    private(set) var modelContext: ModelContext?

    func configure(modelContext: ModelContext) {
        self.modelContext = modelContext
    }

    // MARK: - CRUD

    /// 记录一次饮食选择
    func addRecord(food: Food) {
        guard let context = modelContext else { return }
        let record = MealRecord(food: food)
        context.insert(record)
        save()
        refreshAll()
    }

    /// 删除一条记录
    func deleteRecord(_ record: MealRecord) {
        guard let context = modelContext else { return }
        context.delete(record)
        save()
        refreshAll()
    }

    /// 删除多条记录
    func deleteRecords(_ records: [MealRecord]) {
        guard let context = modelContext else { return }
        for record in records {
            context.delete(record)
        }
        save()
        refreshAll()
    }

    /// 保存上下文
    private func save() {
        do {
            try modelContext?.save()
        } catch {
            #if DEBUG
            print("[RecordViewModel] save failed: \(error)")
            #endif
        }
    }

    // MARK: - 查询

    /// 获取指定日期范围的记录
    func fetchRecords(from start: Date, to end: Date) -> [MealRecord] {
        guard let context = modelContext else { return [] }
        let descriptor = FetchDescriptor<MealRecord>(
            predicate: MealRecord.predicate(from: start, to: end),
            sortBy: [SortDescriptor(\.date, order: .reverse)]
        )
        return (try? context.fetch(descriptor)) ?? []
    }

    /// 获取所有记录
    func fetchAllRecords() -> [MealRecord] {
        guard let context = modelContext else { return [] }
        let descriptor = FetchDescriptor<MealRecord>(
            sortBy: [SortDescriptor(\.date, order: .reverse)]
        )
        return (try? context.fetch(descriptor)) ?? []
    }

    /// 获取最近 N 天的食物名称列表（用于抽卡去重）
    func recentFoodNames(days: Int = 7) -> [String] {
        let cal = Calendar.current
        guard let start = cal.date(byAdding: .day, value: -days, to: .now) else { return [] }
        return fetchRecords(from: start, to: .now).map(\.foodName)
    }

    /// 刷新所有时间维度的数据
    func refreshAll() {
        let cal = Calendar.current
        let now = Date.now

        // 今日
        let startOfDay = cal.startOfDay(for: now)
        guard let endOfDay = cal.date(byAdding: .day, value: 1, to: startOfDay) else { return }
        todayRecords = fetchRecords(from: startOfDay, to: endOfDay)

        // 本周
        guard let startOfWeek = cal.date(from: cal.dateComponents([.yearForWeekOfYear, .weekOfYear], from: now)),
              let endOfWeek = cal.date(byAdding: .day, value: 7, to: startOfWeek) else { return }
        weekRecords = fetchRecords(from: startOfWeek, to: endOfWeek)

        // 本月
        guard let startOfMonth = cal.date(from: cal.dateComponents([.year, .month], from: now)),
              let endOfMonth = cal.date(byAdding: .month, value: 1, to: startOfMonth) else { return }
        monthRecords = fetchRecords(from: startOfMonth, to: endOfMonth)

        // 全量（供日历视图使用）
        records = fetchAllRecords()
    }

    // MARK: - 统计：菜系分布

    /// 指定数据集的菜系分布
    func cuisineDistribution(from source: [MealRecord]? = nil) -> [(cuisine: String, count: Int, ratio: CGFloat)] {
        let data = source ?? records
        let grouped = Dictionary(grouping: data, by: \.cuisine)
        let sorted = grouped.map { ($0.key, $0.value.count) }
            .sorted { $0.1 > $1.1 }
        let maxCount = sorted.first?.1 ?? 1
        return sorted.map { ($0.0, $0.1, CGFloat($0.1) / CGFloat(maxCount)) }
    }

    /// 本周菜系分布
    var weekCuisineDistribution: [(cuisine: String, count: Int, ratio: CGFloat)] {
        cuisineDistribution(from: weekRecords)
    }

    /// 本月菜系分布
    var monthCuisineDistribution: [(cuisine: String, count: Int, ratio: CGFloat)] {
        cuisineDistribution(from: monthRecords)
    }

    // MARK: - 统计：最爱 Top 5

    func topFoods(from source: [MealRecord]? = nil, limit: Int = 5) -> [(name: String, emoji: String, count: Int)] {
        let data = source ?? records
        let grouped = Dictionary(grouping: data, by: \.foodName)
        let mapped: [(String, String, Int)] = grouped.map { (key, values) in
            (key, values.first?.emoji ?? "🍽️", values.count)
        }
        let sorted = mapped.sorted { $0.2 > $1.2 }
        return Array(sorted.prefix(limit))
    }

    var weekTopFoods: [(name: String, emoji: String, count: Int)] {
        topFoods(from: weekRecords)
    }

    var monthTopFoods: [(name: String, emoji: String, count: Int)] {
        topFoods(from: monthRecords)
    }

    // MARK: - 统计：上瘾警告

    /// 检测连续吃同一类别/菜系的次数
    func addictionWarning() -> String? {
        let recent = Array(records.prefix(5))
        guard recent.count >= 3 else { return nil }

        // 检查连续相同菜系
        let cuisines = recent.map(\.cuisine)
        if let first = cuisines.first, cuisines.prefix(3).allSatisfy({ $0 == first }) {
            return "你已经连续 \(cuisines.prefix(while: { $0 == first }).count) 顿吃\(first)了！"
        }

        // 检查连续相同食物
        let names = recent.map(\.foodName)
        if let first = names.first, names.prefix(3).allSatisfy({ $0 == first }) {
            return "你已经连续 \(names.prefix(while: { $0 == first }).count) 顿吃\(first)了！"
        }

        return nil
    }

    // MARK: - 统计：按日期分组（日历视图用）

    /// 按日期分组记录
    func recordsByDate() -> [Date: [MealRecord]] {
        let cal = Calendar.current
        return Dictionary(grouping: records) { record in
            cal.startOfDay(for: record.date)
        }
    }

    /// 指定日期的记录
    func records(for date: Date) -> [MealRecord] {
        let cal = Calendar.current
        let start = cal.startOfDay(for: date)
        guard let end = cal.date(byAdding: .day, value: 1, to: start) else { return [] }
        return records.filter { $0.date >= start && $0.date < end }
    }

    // MARK: - 统计摘要

    /// 总记录数
    var totalCount: Int { records.count }

    /// 本周记录数
    var weekCount: Int { weekRecords.count }

    /// 本月记录数
    var monthCount: Int { monthRecords.count }

    /// 不同食物数
    var uniqueFoodCount: Int {
        Set(records.map(\.foodName)).count
    }

    /// 不同菜系数
    var uniqueCuisineCount: Int {
        Set(records.map(\.cuisine)).count
    }
}
