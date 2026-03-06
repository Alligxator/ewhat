import Foundation

/// 今日食运模型
struct DailyFortune: Identifiable {
    let id = UUID()

    /// 公历日期
    let date: Date

    /// 农历日期字符串，如 "二月初八"
    let lunarDateString: String

    /// 节气名称（当日有节气时非 nil）
    let solarTerm: String?

    /// 星期几
    let weekday: Int

    /// 五行属性
    let element: FiveElement

    /// 食运签文，如 "宜辣忌甜，火属性旺"
    let fortuneText: String

    /// 推荐属性标签
    let luckyAttributes: [String]

    /// 忌讳属性标签
    let avoidAttributes: [String]

    /// 推荐菜系
    let luckyCuisines: [Cuisine]

    /// 今日主题词
    let dailyTheme: String

    // MARK: - 显示用

    /// 格式化的星期字符串
    var weekdayString: String {
        let weekdays = ["周日", "周一", "周二", "周三", "周四", "周五", "周六"]
        guard weekday >= 1, weekday <= 7 else { return "" }
        return weekdays[weekday - 1]
    }

    /// 完整的农历显示
    var fullLunarDisplay: String {
        if let term = solarTerm {
            return "\(lunarDateString) · \(term)"
        }
        return lunarDateString
    }

    /// 五行签文（简短版）
    var shortFortune: String {
        "今日\(element.emoji)\(element.rawValue)属性旺"
    }
}

// MARK: - 食运签文模板

enum FortuneTemplate {
    /// 根据五行和星期生成签文
    static func generate(element: FiveElement, weekday: Int, solarTerm: String?) -> String {
        var parts: [String] = []

        // 五行签文
        switch element {
        case .fire:
            parts.append("火属性旺盛，宜食热辣")
        case .water:
            parts.append("水属性流动，宜食汤水")
        case .wood:
            parts.append("木属性生发，宜食清新")
        case .metal:
            parts.append("金属性收敛，宜食爽口")
        case .earth:
            parts.append("土属性厚重，宜食家常")
        }

        // 星期特色
        switch weekday {
        case 1: // 周日
            parts.append("周日慵懒，来点comfort food")
        case 2: // 周一
            parts.append("周一需要能量，吃点硬菜")
        case 3: // 周二
            parts.append("周二平稳，尝试新口味")
        case 4: // 周三
            parts.append("周三过半，犒劳自己")
        case 5: // 周四
            parts.append("周四快了，提前庆祝")
        case 6: // 周五
            parts.append("周五解放日，推荐聚餐大餐")
        case 7: // 周六
            parts.append("周六探索日，尝试没吃过的")
        default:
            break
        }

        // 节气特色
        if let term = solarTerm {
            parts.append(solarTermFortune(term))
        }

        return parts.joined(separator: "；")
    }

    /// 节气特色签文
    static func solarTermFortune(_ term: String) -> String {
        switch term {
        case "立春": return "立春万物生，宜食芽菜春饼"
        case "雨水": return "雨水润万物，来碗暖汤"
        case "惊蛰": return "惊蛰虫鸣，吃梨润燥"
        case "春分": return "春分阴阳平，饮食宜清淡"
        case "清明": return "清明时节，青团艾草香"
        case "谷雨": return "谷雨茶香，配茶点心"
        case "立夏": return "立夏来临，宜食凉面冷饮"
        case "小满": return "小满不满，来碗苦瓜降火"
        case "芒种": return "芒种忙碌，快餐简食"
        case "夏至": return "夏至面长，来碗凉面"
        case "小暑": return "小暑炎热，冰饮解暑"
        case "大暑": return "大暑酷热，绿豆汤续命"
        case "立秋": return "立秋贴秋膘，大肉推荐权重UP"
        case "处暑": return "处暑渐凉，滋补正当时"
        case "白露": return "白露秋燥，银耳润肺"
        case "秋分": return "秋分丰收，蟹肥菊黄"
        case "寒露": return "寒露凝霜，来锅暖炖"
        case "霜降": return "霜降进补，牛羊正肥"
        case "立冬": return "立冬来了，火锅安排"
        case "小雪": return "小雪飘飘，涮羊肉走起"
        case "大雪": return "大雪纷飞，热汤暖身"
        case "冬至": return "冬至大如年，北方饺子南方汤圆"
        case "小寒": return "小寒冻骨，麻辣火锅暖全身"
        case "大寒": return "大寒极冷，来顿硬菜压压惊"
        default:
            return "\(term)时节，顺应天时而食"
        }
    }

    /// 生成每日主题
    static func dailyTheme(element: FiveElement, weekday: Int) -> String {
        let themes: [[String]] = [
            // 周日
            ["懒人美食日", "沙发配外卖", "周末收尾餐"],
            // 周一
            ["元气充电日", "打工人能量站", "周一暴击餐"],
            // 周二
            ["味蕾冒险日", "尝鲜小分队", "随机挑战日"],
            // 周三
            ["半周犒劳日", "加油站补给", "小确幸时刻"],
            // 周四
            ["倒计时聚餐", "提前过周末", "解馋时刻"],
            // 周五
            ["解放日大餐", "TGIF 干饭局", "周末前奏曲"],
            // 周六
            ["探店冒险日", "美食猎人出动", "周末狂欢餐"],
        ]
        let idx = max(0, min(weekday - 1, 6))
        let dayThemes = themes[idx]
        // 用五行做确定性选择
        let pick = element.hashValue.magnitude % UInt(dayThemes.count)
        return dayThemes[Int(pick)]
    }
}
