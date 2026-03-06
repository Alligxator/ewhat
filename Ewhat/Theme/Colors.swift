import SwiftUI

/// App 主题色
enum AppColors {
    // 主色调
    static let primary = Color.orange
    static let secondary = Color("AccentColor")

    // 卡牌稀有度颜色
    static let commonGlow = Color.gray.opacity(0.3)
    static let rareGlow = Color.blue.opacity(0.5)
    static let legendaryGlow = Color.yellow.opacity(0.6)

    // 菜系主题色
    static let sichuanRed = Color(red: 0.8, green: 0.1, blue: 0.1)
    static let cantoneseGold = Color(red: 0.85, green: 0.65, blue: 0.2)
    static let hunanOrange = Color(red: 0.9, green: 0.4, blue: 0.1)

    // 功能色
    static let confirm = Color.green
    static let reject = Color.red
    static let fortune = Color.purple

    // 背景色
    static let cardBackground = Color(.systemBackground)
    static let pageBackground = Color(.secondarySystemBackground)
}
