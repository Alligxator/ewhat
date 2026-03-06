import SwiftUI

/// 抽卡逻辑 ViewModel
@MainActor
@Observable
final class CardViewModel {

    // MARK: - 抽卡状态

    /// 当前展示的食物卡牌
    var currentFood: Food?
    /// 卡牌是否已翻转
    var isCardFlipped = false
    /// 翻牌动画进行中
    var isAnimating = false
    /// 本轮抽卡次数（拒绝后累加）
    var drawCount = 0
    /// 上一次被拒绝的食物（用于飞出动画）
    var rejectedFood: Food?
    /// 本轮是否已确认
    var isConfirmed = false
    /// 筛选后可用的食物总数
    var availableCount: Int { filteredFoods.count }
    /// 抽卡无结果（筛选太严没有匹配）
    var noResult: Bool { filteredFoods.isEmpty && drawCount > 0 }

    // MARK: - 筛选条件

    var selectedCuisines: Set<Cuisine> = []
    var selectedCategories: Set<FoodType> = []
    var selectedScenes: Set<DiningScene> = []
    var selectedPriceRanges: Set<PriceRange> = []

    /// 临时排除标签（本次会话内有效，如 "今天不想吃辣"）
    var sessionExcludedTags: Set<String> = []

    // MARK: - Internal

    private var allFoods: [Food] = []
    private var filteredFoods: [Food] = []
    /// 本轮已经抽到过的食物 ID（避免连续重复）
    private var drawnFoodIds: Set<String> = []
    /// 最近吃过的食物名称列表（来自数据库）
    private var recentFoodNames: [String] = []

    // MARK: - Init

    init() {
        allFoods = FoodDatabase.allFoods
    }

    // MARK: - 数据注入

    /// 注入最近吃过的食物（由 RecordViewModel 提供）
    func setRecentFoods(_ names: [String]) {
        recentFoodNames = names
    }

    // MARK: - 抽卡核心

    /// 完整抽卡：筛选 → 排除 → 加权随机 → 出牌
    func drawCard(
        blacklist: Set<String> = [],
        favoriteCuisines: [Cuisine] = [],
        favoriteTags: [String] = [],
        fortune: DailyFortune? = nil,
        fortuneEnabled: Bool = true
    ) {
        // 1) 筛选
        filteredFoods = allFoods.filter { food in
            // 基础筛选（菜系/类别/场景/价格/黑名单）
            guard food.matches(
                cuisines: selectedCuisines.isEmpty ? nil : selectedCuisines,
                categories: selectedCategories.isEmpty ? nil : selectedCategories,
                scenes: selectedScenes.isEmpty ? nil : selectedScenes,
                priceRanges: selectedPriceRanges.isEmpty ? nil : selectedPriceRanges,
                blacklist: blacklist
            ) else { return false }

            // 临时排除标签
            if !sessionExcludedTags.isEmpty {
                let hasExcluded = food.tags.contains { tag in
                    sessionExcludedTags.contains { excluded in tag.contains(excluded) }
                }
                if hasExcluded { return false }
            }

            // 本轮已抽过的不再出现（除非池子太小）
            if drawnFoodIds.count < allFoods.count / 2 {
                if drawnFoodIds.contains(food.id) { return false }
            }

            return true
        }

        guard !filteredFoods.isEmpty else { return }

        // 2) 加权随机
        let fortuneAttrs = fortuneEnabled ? (fortune?.luckyAttributes ?? []) : []
        let fortuneLuckyCuisines = fortuneEnabled ? (fortune?.luckyCuisines ?? []) : []
        let combinedFavCuisines = Array(Set(favoriteCuisines + fortuneLuckyCuisines))

        currentFood = WeightedRandom.selectFood(
            from: filteredFoods,
            recentFoods: recentFoodNames,
            favoriteCuisines: combinedFavCuisines,
            favoriteTags: favoriteTags,
            fortuneAttributes: fortuneAttrs,
            fortuneEnabled: fortuneEnabled
        )

        // 3) 状态更新
        if let food = currentFood {
            drawnFoodIds.insert(food.id)
        }
        drawCount += 1
        isCardFlipped = false
        isConfirmed = false
        isAnimating = false
    }

    /// 翻转卡牌
    func flipCard() {
        guard !isAnimating, currentFood != nil else { return }
        isAnimating = true
        isCardFlipped = true
        // 动画结束后重置 isAnimating（由 View 层 onAnimationCompleted 调用）
    }

    /// 动画完成回调
    func onFlipAnimationCompleted() {
        isAnimating = false
    }

    /// 确认选择 — 返回选中的食物
    func confirmSelection() -> Food? {
        guard let food = currentFood else { return nil }
        isConfirmed = true

        // 加入近期记录（内存缓存，用于后续抽卡去重）
        recentFoodNames.insert(food.name, at: 0)
        if recentFoodNames.count > 30 {
            recentFoodNames.removeLast()
        }

        return food
    }

    /// 拒绝当前卡牌并自动抽下一张
    func rejectAndDrawNext(
        blacklist: Set<String> = [],
        favoriteCuisines: [Cuisine] = [],
        favoriteTags: [String] = [],
        fortune: DailyFortune? = nil,
        fortuneEnabled: Bool = true
    ) {
        rejectedFood = currentFood
        drawCard(
            blacklist: blacklist,
            favoriteCuisines: favoriteCuisines,
            favoriteTags: favoriteTags,
            fortune: fortune,
            fortuneEnabled: fortuneEnabled
        )
    }

    // MARK: - 筛选管理

    /// 重置所有筛选条件
    func resetFilters() {
        selectedCuisines.removeAll()
        selectedCategories.removeAll()
        selectedScenes.removeAll()
        selectedPriceRanges.removeAll()
        sessionExcludedTags.removeAll()
    }

    /// 添加临时排除标签（如 "今天不想吃辣" → 排除 "辣"）
    func addSessionExclusion(_ tag: String) {
        sessionExcludedTags.insert(tag)
    }

    /// 移除临时排除标签
    func removeSessionExclusion(_ tag: String) {
        sessionExcludedTags.remove(tag)
    }

    /// 重置抽卡轮次（开始新一轮抽卡）
    func resetRound() {
        drawCount = 0
        drawnFoodIds.removeAll()
        currentFood = nil
        rejectedFood = nil
        isCardFlipped = false
        isConfirmed = false
    }

    /// 当前筛选条件是否有任何设置
    var hasActiveFilters: Bool {
        !selectedCuisines.isEmpty ||
        !selectedCategories.isEmpty ||
        !selectedScenes.isEmpty ||
        !selectedPriceRanges.isEmpty ||
        !sessionExcludedTags.isEmpty
    }

    /// 筛选条件摘要文本
    var filterSummary: String {
        var parts: [String] = []
        if !selectedCuisines.isEmpty {
            parts.append(selectedCuisines.map(\.rawValue).joined(separator: "/"))
        }
        if !selectedScenes.isEmpty {
            parts.append(selectedScenes.map(\.rawValue).joined(separator: "/"))
        }
        if !selectedPriceRanges.isEmpty {
            parts.append(selectedPriceRanges.map(\.displayName).joined(separator: "/"))
        }
        if !sessionExcludedTags.isEmpty {
            parts.append("排除: \(sessionExcludedTags.joined(separator: ","))")
        }
        return parts.isEmpty ? "全部随机" : parts.joined(separator: " · ")
    }
}
