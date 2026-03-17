import Foundation

/// 加权随机选择算法
enum WeightedRandom {

    /// 加权随机选择单个元素
    static func select<T>(from items: [T], weights: [Double]) -> T? {
        guard !items.isEmpty, items.count == weights.count else { return nil }

        let totalWeight = weights.reduce(0, +)
        guard totalWeight > 0 else { return items.randomElement() }

        let random = Double.random(in: 0..<totalWeight)
        var cumulative: Double = 0

        for (index, weight) in weights.enumerated() {
            cumulative += weight
            if random < cumulative {
                return items[index]
            }
        }

        return items.last
    }

    /// 加权随机选择，使用 (item, weight) 元组
    static func select<T>(from weightedItems: [(item: T, weight: Double)]) -> T? {
        select(from: weightedItems.map(\.item), weights: weightedItems.map(\.weight))
    }

    /// 从食物列表中按权重选择，考虑多种因素
    static func selectFood(
        from foods: [Food],
        recentFoods: [String] = [],
        favoriteCuisines: [Cuisine] = [],
        favoriteTags: [String] = [],
        fortuneAttributes: [String] = [],
        fortuneEnabled: Bool = true
    ) -> Food? {
        guard !foods.isEmpty else { return nil }

        let weights = foods.map { food in
            calculateWeight(
                for: food,
                recentFoods: recentFoods,
                favoriteCuisines: favoriteCuisines,
                favoriteTags: favoriteTags,
                fortuneAttributes: fortuneAttributes,
                fortuneEnabled: fortuneEnabled
            )
        }

        return select(from: foods, weights: weights)
    }

    // MARK: - 权重计算

    /// 计算单个食物的推荐权重
    static func calculateWeight(
        for food: Food,
        recentFoods: [String],
        favoriteCuisines: [Cuisine],
        favoriteTags: [String] = [],
        fortuneAttributes: [String],
        fortuneEnabled: Bool
    ) -> Double {
        var weight: Double = 1.0

        // 1) 稀有度基础权重（传说级稍低出现率，增加惊喜感）
        switch food.rarity {
        case .common:    weight *= 1.0
        case .rare:      weight *= 0.6
        case .legendary: weight *= 0.2
        }

        // 2) 最近吃过降权 — 越近期吃的降权越狠
        if let idx = recentFoods.firstIndex(of: food.name) {
            // idx == 0 表示最近刚吃过，降权最多
            let recencyPenalty = max(0.05, 1.0 - Double(recentFoods.count - idx) * 0.12)
            weight *= recencyPenalty
        }

        // 3) 偏好菜系加权
        if favoriteCuisines.contains(food.cuisine) {
            weight *= 1.5
        }

        // 4) 偏好标签加权
        if !favoriteTags.isEmpty {
            let tagMatchCount = food.tags.filter { tag in
                favoriteTags.contains { fav in tag.contains(fav) }
            }.count
            if tagMatchCount > 0 {
                weight *= (1.0 + Double(tagMatchCount) * 0.25)
            }
        }

        // 5) 食运加成
        if fortuneEnabled, !fortuneAttributes.isEmpty {
            let matchCount = food.tags.filter { tag in
                fortuneAttributes.contains { attr in tag.contains(attr) }
            }.count
            if matchCount > 0 {
                weight *= (1.0 + Double(matchCount) * 0.3)
            }
        }

        return max(weight, 0.01) // 保证最低权重
    }
}
