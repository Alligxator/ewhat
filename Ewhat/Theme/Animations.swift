import SwiftUI

/// App 动画预设
enum AppAnimations {
    /// 卡牌翻转动画
    static let cardFlip: Animation = .spring(duration: 0.6, bounce: 0.2)

    /// 卡牌飞出（拒绝）
    static let cardDismiss: Animation = .easeInOut(duration: 0.35)

    /// 卡牌滑入（新卡）
    static let cardEnter: Animation = .spring(duration: 0.5, bounce: 0.15)

    /// 确认撒花
    static let celebration: Animation = .easeOut(duration: 1.0)

    /// 呼吸光效
    static let breathe: Animation = .easeInOut(duration: 2.0).repeatForever(autoreverses: true)

    /// 食运卡片浮动
    static let fortuneFloat: Animation = .easeInOut(duration: 3.0).repeatForever(autoreverses: true)

    /// 页面转场
    static let pageTransition: Animation = .spring(duration: 0.4, bounce: 0.1)
}
