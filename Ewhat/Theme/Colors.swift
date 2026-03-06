import SwiftUI

// MARK: - 新中式暖色调配色系统

enum AppColors {

    // ── 主色调 ──
    static let primary     = Color("PrimaryOrange", bundle: nil)  // fallback below
    static let secondary   = Color("WarmAmber", bundle: nil)

    // 编程色 fallback（无 Asset Catalog 时也可运行）
    static let warmOrange  = Color(red: 0.96, green: 0.55, blue: 0.20)   // #F58D33
    static let warmAmber   = Color(red: 0.92, green: 0.72, blue: 0.35)   // #EBB859
    static let warmCoral   = Color(red: 0.93, green: 0.42, blue: 0.35)   // #ED6B59
    static let warmCream   = Color(red: 0.99, green: 0.96, blue: 0.91)   // #FDF5E8
    static let warmBrown   = Color(red: 0.45, green: 0.30, blue: 0.20)   // #734D33

    // ── 新中式点缀色 ──
    static let inkBlack    = Color(red: 0.15, green: 0.13, blue: 0.12)   // 墨色
    static let jadeGreen   = Color(red: 0.36, green: 0.64, blue: 0.52)   // 翡翠
    static let cinnabar    = Color(red: 0.80, green: 0.18, blue: 0.18)   // 朱砂
    static let porcelain   = Color(red: 0.94, green: 0.95, blue: 0.96)   // 瓷白

    // ── 卡牌稀有度 ──
    static let commonGlow    = Color.gray.opacity(0.25)
    static let rareGlow      = Color(red: 0.35, green: 0.55, blue: 0.90).opacity(0.5)
    static let legendaryGlow = Color(red: 1.0, green: 0.82, blue: 0.25).opacity(0.7)

    // ── 菜系主题色 ──
    static let sichuanRed    = Color(red: 0.80, green: 0.12, blue: 0.12)
    static let cantoneseGold = Color(red: 0.85, green: 0.65, blue: 0.22)
    static let hunanOrange   = Color(red: 0.90, green: 0.40, blue: 0.12)
    static let northeastBrown = Color(red: 0.55, green: 0.38, blue: 0.24)
    static let jiangzheGreen = Color(red: 0.40, green: 0.65, blue: 0.45)
    static let northwestAmber = Color(red: 0.78, green: 0.58, blue: 0.25)
    static let japaneseRed   = Color(red: 0.75, green: 0.22, blue: 0.22)
    static let koreanPink    = Color(red: 0.88, green: 0.42, blue: 0.52)
    static let seaGreen      = Color(red: 0.30, green: 0.68, blue: 0.55)
    static let westernNavy   = Color(red: 0.20, green: 0.30, blue: 0.52)
    static let fastFoodYellow = Color(red: 0.95, green: 0.75, blue: 0.20)

    // ── 功能色 ──
    static let confirm     = Color(red: 0.30, green: 0.72, blue: 0.45)
    static let reject      = Color(red: 0.88, green: 0.30, blue: 0.30)
    static let fortune     = Color(red: 0.55, green: 0.35, blue: 0.75)

    // ── 背景 ──
    static let cardBg      = Color(.systemBackground)
    static let pageBg      = Color(.secondarySystemBackground)

    // ── 五行色 ──
    static func elementColor(_ element: FiveElement) -> Color {
        switch element {
        case .fire:  return cinnabar
        case .water: return Color(red: 0.25, green: 0.55, blue: 0.78)
        case .wood:  return jadeGreen
        case .metal: return warmAmber
        case .earth: return warmBrown
        }
    }

    /// 菜系 → 颜色
    static func cuisineColor(_ cuisine: Cuisine) -> Color {
        switch cuisine {
        case .sichuan:       return sichuanRed
        case .cantonese:     return cantoneseGold
        case .hunan:         return hunanOrange
        case .northeastern:  return northeastBrown
        case .jiangzhe:      return jiangzheGreen
        case .northwestern:  return northwestAmber
        case .japanese:      return japaneseRed
        case .korean:        return koreanPink
        case .southeastAsian: return seaGreen
        case .western:       return westernNavy
        case .fastFood:      return fastFoodYellow
        }
    }

    /// 稀有度 → 颜色
    static func rarityColor(_ rarity: CardRarity) -> Color {
        switch rarity {
        case .common:    return .gray
        case .rare:      return rareGlow
        case .legendary: return legendaryGlow
        }
    }
}

// MARK: - 设计 Token

enum AppLayout {
    static let cardCorner: CGFloat      = 20
    static let smallCorner: CGFloat     = 12
    static let tinyCorner: CGFloat      = 8

    static let cardShadowRadius: CGFloat = 8
    static let cardShadowY: CGFloat      = 4

    static let pagePadding: CGFloat     = 20
    static let cardPadding: CGFloat     = 16
    static let sectionSpacing: CGFloat  = 24
    static let itemSpacing: CGFloat     = 12
    static let tagSpacing: CGFloat      = 8
}
