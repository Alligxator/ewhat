import Foundation

/// 加权随机选择算法
enum WeightedRandom {

    /// 加权随机选择单个元素
    /// - Parameters:
    ///   - items: 候选项数组
    ///   - weights: 对应权重数组（长度需与 items 一致）
    /// - Returns: 被选中的元素，如果数组为空则返回 nil
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
    /// - Parameters:
    ///   - foods: 候选食物列表
    ///   - recentFoods: 最近吃过的食物名称（用于去重降权）
    ///   - favoriteCuisines: 偏好菜系（用于加权）
    ///   - fortuneAttributes: 今日食运推荐属性（用于加权）
    ///   - fortuneEnabled: 是否启用食运加成
    /// - Returns: 选中的食物
    static func selectFood(
        from foods: [Food],
        recentFoods: [String] = [],
        favoriteCuisines: [Cuisine] = [],
        fortuneAttributes: [String] = [],
        fortuneEnabled: Bool = true
    ) -> Food? {
        guard !foods.isEmpty else { return nil }

        let weights = foods.map { food in
            calculateWeight(
                for: food,
                recentFoods: recentFoods,
                favoriteCuisines: favoriteCuisines,
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

        // 2) 最近吃过降权
        if recentFoods.contains(food.name) {
            let recency = recentFoods.firstIndex(of: food.name)!
            // 越近期吃过，降权越多
            let penalty = max(0.1, 1.0 - Double(recentFoods.count - recency) * 0.15)
            weight *= penalty
        }

        // 3) 偏好菜系加权
        if favoriteCuisines.contains(food.cuisine) {
            weight *= 1.5
        }

        // 4) 食运加成
        if fortuneEnabled {
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

// MARK: - 洗牌扩展

extension Array {
    /// Fisher-Yates 洗牌
    func shuffledWeighted(by weights: [Double]) -> [Element] {
        guard count == weights.count, !isEmpty else { return self }

        var result: [Element] = []
        var remaining = Array(zip(self, weights))

        while !remaining.isEmpty {
            if let selected = WeightedRandom.select(
                from: remaining.map(\.0),
                weights: remaining.map(\.1)
            ) {
                result.append(selected)
                if let idx = remaining.firstIndex(where: { ($0.0 as AnyObject) === (selected as AnyObject) }) {
                    remaining.remove(at: idx)
                } else {
                    remaining.removeFirst()
                }
            } else {
                break
            }
        }

        return result
    }
}
