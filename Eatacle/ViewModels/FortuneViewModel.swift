import SwiftUI

/// 食运计算 ViewModel — 确定性伪随机：同一天 + 同一配置 = 同一食运
@MainActor
@Observable
final class FortuneViewModel {

    // MARK: - Published State

    var todayFortune: DailyFortune?

    /// 上一次生成日期的 key（用于判断是否需要刷新）
    private var lastDateKey: String = ""

    // MARK: - Init

    init() {
        refreshIfNeeded()
    }

    // MARK: - Public

    /// 如果日期变了则重新生成（可在 scenePhase 变化时调用）
    func refreshIfNeeded() {
        let key = Self.dateKey(for: .now)
        if key != lastDateKey {
            generateFortune(for: .now)
            lastDateKey = key
        }
    }

    /// 根据指定日期生成食运（确定性）
    func generateFortune(for date: Date) {
        let calendar = Calendar.current
        let weekday = calendar.component(.weekday, from: date)
        let lunarDateStr = LunarCalendar.lunarDateString(for: date)
        let solarTerm = LunarCalendar.solarTerm(for: date)
        let element = LunarCalendar.fiveElement(for: date)

        // 确定性种子 — 同一天永远返回同一结果
        let dateSeed = FortuneTemplate.seed(for: date)

        let fortuneText = FortuneTemplate.generate(
            element: element,
            weekday: weekday,
            solarTerm: solarTerm,
            dateSeed: dateSeed
        )

        let luckyAttrs = luckyAttributes(for: element, solarTerm: solarTerm)
        let avoidElement = avoidingElement(for: element)
        let avoidAttrs = avoidElement.foodAttributes

        let luckyCuisines = cuisinesForElement(element, weekday: weekday)
        let theme = FortuneTemplate.dailyTheme(weekday: weekday, dateSeed: dateSeed)
        let luckyAct = FortuneTemplate.luckyAction(dateSeed: dateSeed)
        let avoidAct = FortuneTemplate.avoidAction(dateSeed: dateSeed)

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
            dailyTheme: theme,
            luckyAction: luckyAct,
            avoidAction: avoidAct
        )
    }

    // MARK: - 属性系统

    /// 根据五行 + 节气计算推荐属性（合并五行本身属性和节气加成）
    private func luckyAttributes(for element: FiveElement, solarTerm: String?) -> [String] {
        var attrs = element.foodAttributes

        // 节气额外加成
        if let term = solarTerm {
            attrs.append(contentsOf: solarTermAttributes(term))
        }

        return Array(Set(attrs)) // 去重
    }

    /// 节气对应的额外推荐属性
    private func solarTermAttributes(_ term: String) -> [String] {
        switch term {
        case "立春", "雨水":          return ["芽菜", "春饼", "清淡"]
        case "惊蛰", "春分":          return ["清新", "蔬菜"]
        case "清明":                  return ["青团", "素食"]
        case "谷雨":                  return ["茶点", "清淡"]
        case "立夏", "小满":          return ["凉面", "清爽"]
        case "芒种", "夏至":          return ["凉面", "冷饮"]
        case "小暑", "大暑":          return ["冰饮", "清淡", "海鲜"]
        case "立秋":                  return ["肉食", "烧烤", "大餐"]
        case "处暑", "白露":          return ["滋补", "汤类"]
        case "秋分":                  return ["蟹", "海鲜"]
        case "寒露", "霜降":          return ["炖菜", "羊肉"]
        case "立冬", "小雪", "大雪":   return ["火锅", "炖菜", "辣味"]
        case "冬至":                  return ["饺子", "汤圆", "家常"]
        case "小寒", "大寒":          return ["火锅", "辣味", "炖菜"]
        default:                      return []
        }
    }

    // MARK: - 五行相生相克

    /// 五行相克：金克木 → 木克土 → 土克水 → 水克火 → 火克金
    private func avoidingElement(for element: FiveElement) -> FiveElement {
        switch element {
        case .metal: return .wood
        case .wood:  return .earth
        case .earth: return .water
        case .water: return .fire
        case .fire:  return .metal
        }
    }

    /// 根据五行 + 星期推荐菜系
    private func cuisinesForElement(_ element: FiveElement, weekday: Int) -> [Cuisine] {
        var cuisines: [Cuisine]
        switch element {
        case .fire:  cuisines = [.sichuan, .hunan]
        case .water: cuisines = [.cantonese, .japanese]
        case .wood:  cuisines = [.southeastAsian, .jiangzhe]
        case .metal: cuisines = [.korean, .western]
        case .earth: cuisines = [.northeastern, .northwestern]
        }

        // 周五/周六额外推荐聚餐类菜系
        if weekday == 6 || weekday == 7 {
            if !cuisines.contains(.sichuan) { cuisines.append(.sichuan) }
        }

        return cuisines
    }

    // MARK: - Helpers

    /// 日期 key，用于判断是否需要刷新
    private static func dateKey(for date: Date) -> String {
        let cal = Calendar.current
        let y = cal.component(.year, from: date)
        let m = cal.component(.month, from: date)
        let d = cal.component(.day, from: date)
        return "\(y)-\(m)-\(d)"
    }
}
