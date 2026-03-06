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

    /// 星期几 (1=周日 ... 7=周六)
    let weekday: Int

    /// 五行属性
    let element: FiveElement

    /// 食运签文主文
    let fortuneText: String

    /// 推荐属性标签
    let luckyAttributes: [String]

    /// 忌讳属性标签
    let avoidAttributes: [String]

    /// 推荐菜系
    let luckyCuisines: [Cuisine]

    /// 今日主题词
    let dailyTheme: String

    /// "宜" 文案
    let luckyAction: String

    /// "忌" 文案
    let avoidAction: String

    // MARK: - 显示用

    var weekdayString: String {
        let weekdays = ["周日", "周一", "周二", "周三", "周四", "周五", "周六"]
        guard weekday >= 1, weekday <= 7 else { return "" }
        return weekdays[weekday - 1]
    }

    var fullLunarDisplay: String {
        if let term = solarTerm {
            return "\(lunarDateString) · \(term)"
        }
        return lunarDateString
    }

    var shortFortune: String {
        "今日\(element.emoji)\(element.rawValue)属性旺"
    }
}

// MARK: - 食运签文模板库（30+ 条）

enum FortuneTemplate {

    // MARK: - 确定性种子

    /// 根据日期生成确定性伪随机种子，同一天同一结果
    static func seed(for date: Date) -> UInt64 {
        let cal = Calendar.current
        let y = UInt64(cal.component(.year, from: date))
        let m = UInt64(cal.component(.month, from: date))
        let d = UInt64(cal.component(.day, from: date))
        // FNV-1a 风格的简单哈希
        var hash: UInt64 = 14695981039346656037
        for v in [y, m, d] {
            hash ^= v
            hash &*= 1099511628211
        }
        return hash
    }

    /// 用种子从数组中确定性选取
    static func pick<T>(_ array: [T], seed: UInt64, salt: UInt64 = 0) -> T {
        let idx = Int((seed &+ salt) % UInt64(array.count))
        return array[idx]
    }

    // MARK: - 五行签文库 (每个元素 7 条 = 35 条)

    static let fireTexts: [String] = [
        "火属性旺盛，宜食热辣，让味蕾燃烧起来",
        "今日火元素爆棚，是吃火锅的天选之日",
        "热情如火的一天，配一顿热气腾腾的美食",
        "烈火烹油，今日适合重口味的刺激",
        "火力全开！辣椒和花椒是你今日的守护神",
        "今日宜以火克金，大胆尝试烧烤串串",
        "燃烧吧味蕾！今天不吃辣等于白过",
    ]

    static let waterTexts: [String] = [
        "水属性流动，宜食汤水，滋润身心",
        "今日水元素充沛，来碗热汤暖暖胃",
        "如水般柔和的一天，适合清淡鲜美之味",
        "水润万物，今日宜喝汤、吃海鲜",
        "今日五行水旺，一碗好汤胜过万千",
        "波澜不惊的日子，配一份水煮的温柔",
        "上善若水，今日适合日料和粤菜的鲜",
    ]

    static let woodTexts: [String] = [
        "木属性生发，宜食清新蔬果，拥抱自然",
        "今日木元素茂盛，绿色食物是你的幸运色",
        "生机勃勃的一天，适合轻食沙拉、蔬菜",
        "木气上升，今日宜食清淡，远离油腻",
        "春风化雨般的日子，来份东南亚的清新",
        "木属性让你渴望新鲜感，试试没吃过的",
        "今日木旺，绿叶蔬菜和清爽口味是王道",
    ]

    static let metalTexts: [String] = [
        "金属性收敛，宜食爽口凉菜，精致优雅",
        "今日金元素闪耀，适合精致有格调的美食",
        "锋利如金的味觉，今日适合酸辣爽口之味",
        "金气肃杀，来份凉拌或沙拉清清爽爽",
        "今日五行金旺，西餐的精致恰好匹配",
        "金属性加持下，韩餐的爽脆是最佳选择",
        "以金入味，今日适合追求口感与层次",
    ]

    static let earthTexts: [String] = [
        "土属性厚重，宜食家常主食，稳稳的幸福",
        "今日土元素沉稳，一碗实在的盖浇饭最治愈",
        "脚踏实地的一天，吃顿扎实的家常菜",
        "土生万物，今日适合东北菜的豪迈朴实",
        "土属性让人想念妈妈的味道，吃顿家常吧",
        "敦厚如土的日子，面条饺子管饱又暖心",
        "五行土旺，炖菜、卤味、大碗主食是归宿",
    ]

    // MARK: - 星期签文库 (每天 5 条 = 35 条)

    static let weekdayTexts: [[String]] = [
        // 周日 (weekday == 1)
        ["周日慵懒，来点 comfort food 治愈自己",
         "难得周日，点个外卖躺平吃",
         "周日是合法赖床日，早午餐合一吧",
         "周末余额不足，今天吃点好的补偿",
         "周日适合在家做饭，或者点个好吃的外卖"],
        // 周一
        ["周一需要能量补给，来顿硬菜充电",
         "打工人周一续命餐，必须吃点好的",
         "新的一周从一顿好饭开始",
         "周一暴击！用美食对抗上班的恐惧",
         "周一不吃好，这周都没力气"],
        // 周二
        ["周二平稳过渡，适合尝试新口味",
         "周二了，换个没吃过的菜系冒个险",
         "味蕾需要刺激，周二来点不一样的",
         "周二是最适合美食探索的日子",
         "趁周二还有精力，吃点有意思的"],
        // 周三
        ["周三过半，该犒劳自己一下了",
         "半周节点，来顿小确幸犒赏自己",
         "周三是加油站，吃顿好的继续冲",
         "一周过半，不吃点好的对不起自己",
         "周三适合吃点甜的，补充多巴胺"],
        // 周四
        ["周四倒计时，提前进入周末模式",
         "再坚持一天就周末了，吃顿解馋的",
         "周四是最接近胜利的日子，以美食庆祝",
         "周四适合约朋友周末吃什么，先自己吃好",
         "快到周末了，今天可以奢侈一点"],
        // 周五
        ["周五解放日！推荐聚餐大餐",
         "TGIF！今天必须吃好喝好",
         "周五下班即自由，今晚吃点隆重的",
         "周末前奏曲，从一顿好饭开始嗨",
         "周五配啤酒配烧烤配火锅配一切"],
        // 周六
        ["周六探索日，去吃那家一直想去的店",
         "美食猎人出动！今天要吃没吃过的",
         "周六的快乐是无限的，胃口也是",
         "周末狂欢餐，今天不看热量",
         "周六适合慢悠悠吃一顿好的"],
    ]

    // MARK: - "宜/忌" 签文库

    static let luckyActions: [String] = [
        "宜大快朵颐", "宜呼朋唤友干饭", "宜独享美味",
        "宜探索新菜系", "宜重温经典味道", "宜犒劳自己",
        "宜吃到扶墙出", "宜与好友分享", "宜尝试传说级美食",
        "宜堂食细品", "宜加辣加麻", "宜多点一个菜",
        "宜饭后甜品", "宜慢慢享用", "宜光盘行动",
    ]

    static let avoidActions: [String] = [
        "忌随便应付一餐", "忌吃太撑", "忌只吃泡面",
        "忌纠结超过10分钟", "忌空腹逛街", "忌饿着肚子加班",
        "忌连续吃同一家", "忌跳过正餐", "忌深夜暴饮暴食",
        "忌只喝奶茶不吃饭", "忌边走边吃", "忌外卖凑单太多",
        "忌饿到发脾气", "忌减肥第一天就放弃", "忌浪费粮食",
    ]

    // MARK: - 每日主题库

    static let dailyThemes: [[String]] = [
        // 周日
        ["懒人美食日", "沙发配外卖", "周末收尾餐", "慵懒brunch日"],
        // 周一
        ["元气充电日", "打工人能量站", "周一暴击餐", "开工加油日"],
        // 周二
        ["味蕾冒险日", "尝鲜小分队", "随机挑战日", "美食探索日"],
        // 周三
        ["半周犒劳日", "加油站补给", "小确幸时刻", "周三甜蜜日"],
        // 周四
        ["倒计时聚餐", "提前过周末", "解馋时刻", "胜利前夜餐"],
        // 周五
        ["解放日大餐", "TGIF干饭局", "周末前奏曲", "自由夜宵日"],
        // 周六
        ["探店冒险日", "美食猎人日", "周末狂欢餐", "味觉旅行日"],
    ]

    // MARK: - 节气签文 (24 节气)

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
        case "芒种": return "芒种忙碌，快餐简食充能"
        case "夏至": return "夏至面长，来碗凉面"
        case "小暑": return "小暑炎热，冰饮解暑"
        case "大暑": return "大暑酷热，绿豆汤续命"
        case "立秋": return "立秋贴秋膘，大肉推荐权重UP"
        case "处暑": return "处暑渐凉，滋补正当时"
        case "白露": return "白露秋燥，银耳润肺"
        case "秋分": return "秋分丰收，蟹肥菊黄"
        case "寒露": return "寒露凝霜，来锅暖炖"
        case "霜降": return "霜降进补，牛羊正肥"
        case "立冬": return "立冬来了，火锅安排上！"
        case "小雪": return "小雪飘飘，涮羊肉走起"
        case "大雪": return "大雪纷飞，热汤暖身"
        case "冬至": return "冬至大如年，北方饺子南方汤圆"
        case "小寒": return "小寒冻骨，麻辣火锅暖全身"
        case "大寒": return "大寒极冷，来顿硬菜压压惊"
        default:    return "\(term)时节，顺应天时而食"
        }
    }

    // MARK: - 生成器

    /// 根据五行 + 星期 + 节气，确定性地生成完整签文
    static func generate(element: FiveElement, weekday: Int, solarTerm: String?, dateSeed: UInt64) -> String {
        // 从对应五行签文库确定性选取
        let elementTexts: [String]
        switch element {
        case .fire:  elementTexts = fireTexts
        case .water: elementTexts = waterTexts
        case .wood:  elementTexts = woodTexts
        case .metal: elementTexts = metalTexts
        case .earth: elementTexts = earthTexts
        }
        let elementPart = pick(elementTexts, seed: dateSeed, salt: 1)

        // 从星期签文库确定性选取
        let dayIdx = max(0, min(weekday - 1, 6))
        let weekdayPart = pick(weekdayTexts[dayIdx], seed: dateSeed, salt: 2)

        // 节气部分
        if let term = solarTerm {
            return "\(elementPart)；\(weekdayPart)；\(solarTermFortune(term))"
        }
        return "\(elementPart)；\(weekdayPart)"
    }

    /// 确定性生成每日主题
    static func dailyTheme(weekday: Int, dateSeed: UInt64) -> String {
        let dayIdx = max(0, min(weekday - 1, 6))
        return pick(dailyThemes[dayIdx], seed: dateSeed, salt: 3)
    }

    /// 确定性生成"宜"
    static func luckyAction(dateSeed: UInt64) -> String {
        pick(luckyActions, seed: dateSeed, salt: 4)
    }

    /// 确定性生成"忌"
    static func avoidAction(dateSeed: UInt64) -> String {
        pick(avoidActions, seed: dateSeed, salt: 5)
    }
}
