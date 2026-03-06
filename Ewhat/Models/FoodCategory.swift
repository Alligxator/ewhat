import Foundation

// MARK: - 菜系 Cuisine

enum Cuisine: String, Codable, CaseIterable, Identifiable {
    case sichuan    = "川菜"
    case cantonese  = "粤菜"
    case hunan      = "湘菜"
    case northeastern = "东北菜"
    case jiangzhe   = "江浙菜"
    case northwestern = "西北菜"
    case japanese   = "日料"
    case korean     = "韩餐"
    case southeastAsian = "东南亚"
    case western    = "西餐"
    case fastFood   = "快餐"

    var id: String { rawValue }

    var emoji: String {
        switch self {
        case .sichuan:       return "🌶️"
        case .cantonese:     return "🥘"
        case .hunan:         return "🔥"
        case .northeastern:  return "🥟"
        case .jiangzhe:      return "🦀"
        case .northwestern:  return "🐑"
        case .japanese:      return "🍣"
        case .korean:        return "🥩"
        case .southeastAsian: return "🍜"
        case .western:       return "🥩"
        case .fastFood:      return "🍔"
        }
    }

    /// 菜系对应的主题色名称
    var themeColorName: String {
        switch self {
        case .sichuan:       return "sichuanRed"
        case .cantonese:     return "cantoneseGold"
        case .hunan:         return "hunanOrange"
        case .northeastern:  return "northeasternBrown"
        case .jiangzhe:      return "jiangzheGreen"
        case .northwestern:  return "northwesternAmber"
        case .japanese:      return "japaneseRed"
        case .korean:        return "koreanPink"
        case .southeastAsian: return "seaGreen"
        case .western:       return "westernNavy"
        case .fastFood:      return "fastFoodYellow"
        }
    }
}

// MARK: - 食物类别 FoodType

enum FoodType: String, Codable, CaseIterable, Identifiable {
    case hotpot      = "火锅"
    case noodles     = "面条"
    case rice        = "米饭"
    case dumplings   = "饺子包子"
    case bbq         = "烧烤"
    case stirFry     = "炒菜"
    case soup        = "汤/粥"
    case snack       = "小吃"
    case dessert     = "甜品"
    case salad       = "沙拉"
    case seafood     = "海鲜"
    case fastMeal    = "快餐简餐"
    case setMeal     = "定食套餐"

    var id: String { rawValue }
}

// MARK: - 用餐场景 Scene

enum DiningScene: String, Codable, CaseIterable, Identifiable {
    case solo       = "一个人随便吃"
    case friends    = "朋友聚餐"
    case date       = "约会"
    case lateNight  = "夜宵"
    case afternoon  = "下午茶"

    var id: String { rawValue }

    var emoji: String {
        switch self {
        case .solo:      return "🧑"
        case .friends:   return "👯"
        case .date:      return "💑"
        case .lateNight: return "🌙"
        case .afternoon: return "☕"
        }
    }
}

// MARK: - 价格区间 PriceRange

enum PriceRange: String, Codable, CaseIterable, Identifiable {
    case budget   = "穷鬼模式"     // < ¥20
    case normal   = "正常"         // ¥20-50
    case premium  = "小奢侈"       // ¥50-100
    case luxury   = "随便花"        // > ¥100

    var id: String { rawValue }

    var emoji: String {
        switch self {
        case .budget:  return "💰"
        case .normal:  return "💵"
        case .premium: return "💎"
        case .luxury:  return "👑"
        }
    }

    var displayText: String {
        switch self {
        case .budget:  return "< ¥20"
        case .normal:  return "¥20-50"
        case .premium: return "¥50-100"
        case .luxury:  return "随便花"
        }
    }
}

// MARK: - 卡牌稀有度 CardRarity

enum CardRarity: String, Codable, CaseIterable {
    case common    = "普通"
    case rare      = "稀有"
    case legendary = "传说"

    var starCount: Int {
        switch self {
        case .common:    return 1
        case .rare:      return 2
        case .legendary: return 3
        }
    }

    var glowColor: String {
        switch self {
        case .common:    return "commonGlow"
        case .rare:      return "rareGlow"
        case .legendary: return "legendaryGlow"
        }
    }
}

// MARK: - 五行属性 (用于食运系统)

enum FiveElement: String, Codable, CaseIterable {
    case metal = "金"
    case wood  = "木"
    case water = "水"
    case fire  = "火"
    case earth = "土"

    var emoji: String {
        switch self {
        case .metal: return "⚔️"
        case .wood:  return "🌿"
        case .water: return "💧"
        case .fire:  return "🔥"
        case .earth: return "🏔️"
        }
    }

    /// 五行对应的推荐食物属性
    var foodAttributes: [String] {
        switch self {
        case .metal: return ["清淡", "爽口", "凉菜"]
        case .wood:  return ["清新", "蔬菜", "素食"]
        case .water: return ["汤类", "海鲜", "水煮"]
        case .fire:  return ["烧烤", "火锅", "辣味"]
        case .earth: return ["主食", "炖菜", "家常"]
        }
    }
}
