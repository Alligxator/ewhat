import Foundation

struct Food: Codable, Identifiable, Hashable {
    var id: String { name }

    let name: String
    let cuisine: Cuisine
    let category: FoodType
    let tags: [String]
    let scene: [DiningScene]
    let priceRange: PriceRange
    let emoji: String
    let funText: String
    let rarity: CardRarity

    // MARK: - 推荐算法用

    /// 检查是否匹配筛选条件
    func matches(
        cuisines: Set<Cuisine>?,
        categories: Set<FoodType>?,
        scenes: Set<DiningScene>?,
        priceRanges: Set<PriceRange>?,
        blacklist: Set<String>
    ) -> Bool {
        // 黑名单检查
        if blacklist.contains(name) { return false }

        // 菜系筛选
        if let cuisines, !cuisines.isEmpty, !cuisines.contains(cuisine) {
            return false
        }

        // 类别筛选
        if let categories, !categories.isEmpty, !categories.contains(category) {
            return false
        }

        // 场景筛选
        if let scenes, !scenes.isEmpty, scenes.isDisjoint(with: Set(scene)) {
            return false
        }

        // 价格筛选
        if let priceRanges, !priceRanges.isEmpty, !priceRanges.contains(priceRange) {
            return false
        }

        return true
    }

    /// 检查是否包含指定标签
    func hasTag(_ tag: String) -> Bool {
        tags.contains { $0.contains(tag) }
    }
}

// MARK: - 食物数据库加载

enum FoodDatabase {
    static func loadAll() -> [Food] {
        guard let url = Bundle.main.url(forResource: "foods", withExtension: "json"),
              let data = try? Data(contentsOf: url) else {
            return []
        }

        let decoder = JSONDecoder()
        return (try? decoder.decode([Food].self, from: data)) ?? []
    }
}
