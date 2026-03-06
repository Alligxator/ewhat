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

    /// 永久黑名单食物名称
    var blacklistedFoods: [String]

    /// 永久黑名单菜系 rawValue
    var blacklistedCuisines: [String]

    /// 偏好加权菜系 rawValue
    var favoriteCuisines: [String]

    /// 偏好加权标签（如 "辣"、"海鲜"）
    var favoriteTags: [String]

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
        self.favoriteTags = []
        self.fortuneEnabled = true
        self.hapticsEnabled = true
        self.soundEnabled = true
    }

    // MARK: - 便捷方法

    /// 黑名单食物集合
    var blacklistSet: Set<String> {
        Set(blacklistedFoods)
    }

    /// 偏好菜系枚举列表
    var favoriteCuisineEnums: [Cuisine] {
        favoriteCuisines.compactMap { Cuisine(rawValue: $0) }
    }

    /// 黑名单菜系枚举列表
    var blacklistedCuisineEnums: [Cuisine] {
        blacklistedCuisines.compactMap { Cuisine(rawValue: $0) }
    }

    // MARK: - 黑名单管理

    func addToBlacklist(_ foodName: String) {
        guard !blacklistedFoods.contains(foodName) else { return }
        blacklistedFoods.append(foodName)
    }

    func removeFromBlacklist(_ foodName: String) {
        blacklistedFoods.removeAll { $0 == foodName }
    }

    func isBlacklisted(_ foodName: String) -> Bool {
        blacklistedFoods.contains(foodName)
    }

    // MARK: - 菜系黑名单

    func blacklistCuisine(_ cuisine: Cuisine) {
        let raw = cuisine.rawValue
        guard !blacklistedCuisines.contains(raw) else { return }
        blacklistedCuisines.append(raw)
    }

    func unblacklistCuisine(_ cuisine: Cuisine) {
        blacklistedCuisines.removeAll { $0 == cuisine.rawValue }
    }

    // MARK: - 偏好加权

    func addFavoriteCuisine(_ cuisine: Cuisine) {
        let raw = cuisine.rawValue
        guard !favoriteCuisines.contains(raw) else { return }
        favoriteCuisines.append(raw)
    }

    func removeFavoriteCuisine(_ cuisine: Cuisine) {
        favoriteCuisines.removeAll { $0 == cuisine.rawValue }
    }

    func toggleFavoriteCuisine(_ cuisine: Cuisine) {
        if favoriteCuisines.contains(cuisine.rawValue) {
            removeFavoriteCuisine(cuisine)
        } else {
            addFavoriteCuisine(cuisine)
        }
    }

    func addFavoriteTag(_ tag: String) {
        guard !favoriteTags.contains(tag) else { return }
        favoriteTags.append(tag)
    }

    func removeFavoriteTag(_ tag: String) {
        favoriteTags.removeAll { $0 == tag }
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
        let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay) ?? startOfDay.addingTimeInterval(86400)
        return #Predicate<MealRecord> { record in
            record.date >= startOfDay && record.date < endOfDay
        }
    }
}
