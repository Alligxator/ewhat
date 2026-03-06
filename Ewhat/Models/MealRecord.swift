import Foundation
import SwiftData

/// 饮食记录 — SwiftData 持久化模型
@Model
final class MealRecord {
    var id: UUID
    var foodName: String
    var cuisine: String
    var category: String
    var emoji: String
    var date: Date

    init(
        foodName: String,
        cuisine: String,
        category: String,
        emoji: String,
        date: Date = .now
    ) {
        self.id = UUID()
        self.foodName = foodName
        self.cuisine = cuisine
        self.category = category
        self.emoji = emoji
        self.date = date
    }

    /// 从 Food 模型创建记录
    convenience init(food: Food, date: Date = .now) {
        self.init(
            foodName: food.name,
            cuisine: food.cuisine.rawValue,
            category: food.category.rawValue,
            emoji: food.emoji,
            date: date
        )
    }
}

// MARK: - 用户偏好 — SwiftData 持久化模型

@Model
final class UserPreference {
    var id: UUID

    /// 黑名单食物名称
    var blacklistedFoods: [String]

    /// 黑名单菜系 rawValue
    var blacklistedCuisines: [String]

    /// 偏好加权菜系 rawValue
    var favoriteCuisines: [String]

    /// 是否启用食运影响推荐
    var fortuneEnabled: Bool

    /// 是否启用触觉反馈
    var hapticsEnabled: Bool

    /// 是否启用音效
    var soundEnabled: Bool

    init() {
        self.id = UUID()
        self.blacklistedFoods = []
        self.blacklistedCuisines = []
        self.favoriteCuisines = []
        self.fortuneEnabled = true
        self.hapticsEnabled = true
        self.soundEnabled = true
    }
}

// MARK: - 查询辅助

extension MealRecord {
    /// 获取指定日期范围内的记录
    static func predicate(from startDate: Date, to endDate: Date) -> Predicate<MealRecord> {
        #Predicate<MealRecord> { record in
            record.date >= startDate && record.date <= endDate
        }
    }

    /// 获取今日记录
    static var todayPredicate: Predicate<MealRecord> {
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: .now)
        let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)!
        return #Predicate<MealRecord> { record in
            record.date >= startOfDay && record.date < endOfDay
        }
    }
}
