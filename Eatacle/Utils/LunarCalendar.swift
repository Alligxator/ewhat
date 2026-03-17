import Foundation

/// 农历日历工具 — 封装 Foundation 中国历法 + 节气计算
enum LunarCalendar {

    private static let chineseCalendar: Calendar = {
        var cal = Calendar(identifier: .chinese)
        cal.locale = Locale(identifier: "zh_CN")
        return cal
    }()

    // MARK: - 农历日期

    /// 获取指定公历日期对应的农历月和日
    static func lunarComponents(for date: Date) -> (month: Int, day: Int, isLeapMonth: Bool) {
        let comps = chineseCalendar.dateComponents([.month, .day], from: date)
        let isLeap = chineseCalendar.dateComponents([.month], from: date).isLeapMonth ?? false
        return (comps.month ?? 1, comps.day ?? 1, isLeap)
    }

    /// 获取农历日期的中文字符串，如 "二月初八"
    static func lunarDateString(for date: Date) -> String {
        let (month, day, isLeap) = lunarComponents(for: date)
        let prefix = isLeap ? "闰" : ""
        return "\(prefix)\(monthName(month))\(dayName(day))"
    }

    /// 获取农历年份的天干地支
    static func lunarYearName(for date: Date) -> String {
        let year = chineseCalendar.component(.year, from: date)

        let heavenlyStems = ["甲", "乙", "丙", "丁", "戊", "己", "庚", "辛", "壬", "癸"]
        let earthlyBranches = ["子", "丑", "寅", "卯", "辰", "巳", "午", "未", "申", "酉", "戌", "亥"]
        let zodiacAnimals = ["鼠", "牛", "虎", "兔", "龙", "蛇", "马", "羊", "猴", "鸡", "狗", "猪"]

        let stemIdx = (year - 1) % 10
        let branchIdx = (year - 1) % 12

        return "\(heavenlyStems[stemIdx])\(earthlyBranches[branchIdx])\(zodiacAnimals[branchIdx])年"
    }

    // MARK: - 节气

    /// 24 节气名称（按月序排列，每月 2 个）
    static let solarTerms: [(name: String, month: Int, approximateDay: Int)] = [
        ("小寒", 1, 6),   ("大寒", 1, 20),
        ("立春", 2, 4),   ("雨水", 2, 19),
        ("惊蛰", 3, 6),   ("春分", 3, 21),
        ("清明", 4, 5),   ("谷雨", 4, 20),
        ("立夏", 5, 6),   ("小满", 5, 21),
        ("芒种", 6, 6),   ("夏至", 6, 21),
        ("小暑", 7, 7),   ("大暑", 7, 23),
        ("立秋", 8, 7),   ("处暑", 8, 23),
        ("白露", 9, 8),   ("秋分", 9, 23),
        ("寒露", 10, 8),  ("霜降", 10, 23),
        ("立冬", 11, 7),  ("小雪", 11, 22),
        ("大雪", 12, 7),  ("冬至", 12, 22),
    ]

    /// 获取当日节气（如果有的话）
    /// 节气判断容差 ±1 天，因为节气日期每年略有浮动
    static func solarTerm(for date: Date) -> String? {
        let calendar = Calendar.current
        let month = calendar.component(.month, from: date)
        let day = calendar.component(.day, from: date)

        for term in solarTerms where term.month == month {
            if abs(day - term.approximateDay) <= 1 {
                return term.name
            }
        }
        return nil
    }

    /// 获取最近的下一个节气
    static func nextSolarTerm(after date: Date) -> (name: String, daysAway: Int)? {
        let calendar = Calendar.current
        let month = calendar.component(.month, from: date)
        let day = calendar.component(.day, from: date)

        // 在当年节气列表中查找下一个
        for term in solarTerms {
            if term.month > month || (term.month == month && term.approximateDay > day) {
                var comps = DateComponents()
                comps.year = calendar.component(.year, from: date)
                comps.month = term.month
                comps.day = term.approximateDay
                if let termDate = calendar.date(from: comps) {
                    let days = calendar.dateComponents([.day], from: date, to: termDate).day ?? 0
                    return (term.name, days)
                }
            }
        }

        // 如果当前已过大雪/冬至，下一个节气是明年小寒
        if let firstTerm = solarTerms.first {
            var comps = DateComponents()
            comps.year = calendar.component(.year, from: date) + 1
            comps.month = firstTerm.month
            comps.day = firstTerm.approximateDay
            if let termDate = calendar.date(from: comps) {
                let days = calendar.dateComponents([.day], from: date, to: termDate).day ?? 0
                return (firstTerm.name, days)
            }
        }

        return nil
    }

    // MARK: - 五行计算

    /// 根据日期计算五行属性
    /// 基于农历日期的确定性计算，同一天返回同一结果
    static func fiveElement(for date: Date) -> FiveElement {
        let (month, day, _) = lunarComponents(for: date)
        let calendar = Calendar.current
        let weekday = calendar.component(.weekday, from: date)

        // 综合农历月、日、星期计算五行
        let hash = (month * 31 + day * 7 + weekday * 3) % 5
        let elements: [FiveElement] = [.metal, .wood, .water, .fire, .earth]
        return elements[hash]
    }

    // MARK: - Private Helpers

    private static func monthName(_ month: Int) -> String {
        let names = ["", "正月", "二月", "三月", "四月", "五月",
                     "六月", "七月", "八月", "九月", "十月", "冬月", "腊月"]
        guard month >= 1, month <= 12 else { return "" }
        return names[month]
    }

    private static func dayName(_ day: Int) -> String {
        let digits = ["", "一", "二", "三", "四", "五", "六", "七", "八", "九", "十"]

        switch day {
        case 1...10:
            return "初\(digits[day])"
        case 11...20:
            if day == 20 { return "二十" }
            return "十\(digits[day - 10])"
        case 21...30:
            if day == 30 { return "三十" }
            return "廿\(digits[day - 20])"
        default:
            return ""
        }
    }
}
