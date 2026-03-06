import SwiftUI
import SwiftData

/// 抽卡逻辑 ViewModel
@Observable
final class CardViewModel {
    // MARK: - State

    var currentFood: Food?
    var isCardFlipped = false
    var isAnimating = false
    var drawCount = 0

    private var allFoods: [Food] = []
    private var filteredFoods: [Food] = []
    private var recentFoodNames: [String] = []

    // MARK: - Filters

    var selectedCuisines: Set<Cuisine> = []
    var selectedCategories: Set<FoodType> = []
    var selectedScenes: Set<DiningScene> = []
    var selectedPriceRanges: Set<PriceRange> = []

    // MARK: - Init

    init() {
        allFoods = FoodDatabase.loadAll()
    }

    // MARK: - Actions

    /// 抽取下一张卡牌
    func drawCard(
        blacklist: Set<String> = [],
        favoriteCuisines: [Cuisine] = [],
        fortune: DailyFortune? = nil,
        fortuneEnabled: Bool = true
    ) {
        filteredFoods = allFoods.filter { food in
            food.matches(
                cuisines: selectedCuisines.isEmpty ? nil : selectedCuisines,
                categories: selectedCategories.isEmpty ? nil : selectedCategories,
                scenes: selectedScenes.isEmpty ? nil : selectedScenes,
                priceRanges: selectedPriceRanges.isEmpty ? nil : selectedPriceRanges,
                blacklist: blacklist
            )
        }

        guard !filteredFoods.isEmpty else { return }

        let fortuneAttrs = fortuneEnabled ? (fortune?.luckyAttributes ?? []) : []

        currentFood = WeightedRandom.selectFood(
            from: filteredFoods,
            recentFoods: recentFoodNames,
            favoriteCuisines: favoriteCuisines,
            fortuneAttributes: fortuneAttrs,
            fortuneEnabled: fortuneEnabled
        )

        drawCount += 1
        isCardFlipped = false
    }

    /// 翻转卡牌
    func flipCard() {
        guard !isAnimating else { return }
        isAnimating = true
        isCardFlipped = true
    }

    /// 确认选择当前食物
    func confirmSelection() -> Food? {
        guard let food = currentFood else { return nil }
        recentFoodNames.append(food.name)
        if recentFoodNames.count > 20 {
            recentFoodNames.removeFirst()
        }
        return food
    }

    /// 拒绝当前食物，抽下一张
    func rejectAndDrawNext(
        blacklist: Set<String> = [],
        favoriteCuisines: [Cuisine] = [],
        fortune: DailyFortune? = nil,
        fortuneEnabled: Bool = true
    ) {
        drawCard(
            blacklist: blacklist,
            favoriteCuisines: favoriteCuisines,
            fortune: fortune,
            fortuneEnabled: fortuneEnabled
        )
    }

    /// 重置筛选条件
    func resetFilters() {
        selectedCuisines.removeAll()
        selectedCategories.removeAll()
        selectedScenes.removeAll()
        selectedPriceRanges.removeAll()
    }
}
