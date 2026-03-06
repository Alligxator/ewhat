import SwiftUI
import SwiftData

/// 饮食记录管理 ViewModel
@Observable
final class RecordViewModel {
    var records: [MealRecord] = []
    var modelContext: ModelContext?

    /// 记录一次饮食选择
    func addRecord(food: Food) {
        guard let context = modelContext else { return }
        let record = MealRecord(food: food)
        context.insert(record)
        try? context.save()
    }

    /// 获取指定日期范围的记录
    func fetchRecords(from start: Date, to end: Date) {
        guard let context = modelContext else { return }
        let descriptor = FetchDescriptor<MealRecord>(
            predicate: MealRecord.predicate(from: start, to: end),
            sortBy: [SortDescriptor(\.date, order: .reverse)]
        )
        records = (try? context.fetch(descriptor)) ?? []
    }

    /// 获取最近 N 天的食物名称列表（用于去重）
    func recentFoodNames(days: Int = 7) -> [String] {
        guard let context = modelContext else { return [] }
        let calendar = Calendar.current
        let start = calendar.date(byAdding: .day, value: -days, to: .now)!
        let descriptor = FetchDescriptor<MealRecord>(
            predicate: MealRecord.predicate(from: start, to: .now),
            sortBy: [SortDescriptor(\.date, order: .reverse)]
        )
        let fetched = (try? context.fetch(descriptor)) ?? []
        return fetched.map(\.foodName)
    }

    /// 菜系分布统计
    func cuisineDistribution() -> [(cuisine: String, count: Int)] {
        let grouped = Dictionary(grouping: records, by: \.cuisine)
        return grouped.map { ($0.key, $0.value.count) }
            .sorted { $0.count > $1.count }
    }

    /// Top N 最爱食物
    func topFoods(limit: Int = 5) -> [(name: String, count: Int)] {
        let grouped = Dictionary(grouping: records, by: \.foodName)
        return grouped.map { ($0.key, $0.value.count) }
            .sorted { $0.count > $1.count }
            .prefix(limit)
            .map { ($0.0, $0.1) }
    }
}
