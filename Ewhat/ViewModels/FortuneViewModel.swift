import SwiftUI

/// 食运计算 ViewModel
@Observable
final class FortuneViewModel {
    var todayFortune: DailyFortune?

    init() {
        generateFortune(for: .now)
    }

    /// 根据日期生成食运
    func generateFortune(for date: Date) {
        let calendar = Calendar.current
        let weekday = calendar.component(.weekday, from: date)
        let lunarDateStr = LunarCalendar.lunarDateString(for: date)
        let solarTerm = LunarCalendar.solarTerm(for: date)
        let element = LunarCalendar.fiveElement(for: date)

        let fortuneText = FortuneTemplate.generate(
            element: element,
            weekday: weekday,
            solarTerm: solarTerm
        )

        let luckyAttrs = element.foodAttributes
        let avoidElement: FiveElement = avoidingElement(for: element)
        let avoidAttrs = avoidElement.foodAttributes

        let luckyCuisines = cuisinesForElement(element)
        let theme = FortuneTemplate.dailyTheme(element: element, weekday: weekday)

        todayFortune = DailyFortune(
            date: date,
            lunarDateString: lunarDateStr,
            solarTerm: solarTerm,
            weekday: weekday,
            element: element,
            fortuneText: fortuneText,
            luckyAttributes: luckyAttrs,
            avoidAttributes: avoidAttrs,
            luckyCuisines: luckyCuisines,
            dailyTheme: theme
        )
    }

    // MARK: - Private

    /// 五行相克：金克木、木克土、土克水、水克火、火克金
    private func avoidingElement(for element: FiveElement) -> FiveElement {
        switch element {
        case .metal: return .wood
        case .wood:  return .earth
        case .water: return .fire
        case .fire:  return .metal
        case .earth: return .water
        }
    }

    /// 根据五行推荐菜系
    private func cuisinesForElement(_ element: FiveElement) -> [Cuisine] {
        switch element {
        case .fire:  return [.sichuan, .hunan]
        case .water: return [.cantonese, .japanese]
        case .wood:  return [.southeastAsian, .jiangzhe]
        case .metal: return [.korean, .western]
        case .earth: return [.northeastern, .northwestern]
        }
    }
}
