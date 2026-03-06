import SwiftUI

enum AppAnimations {
    /// 卡牌翻转 — 3D rotation 弹性回弹 0.6s
    static let cardFlip: Animation = .spring(duration: 0.6, bounce: 0.2)

    /// 卡牌飞出（拒绝）
    static let cardDismiss: Animation = .easeInOut(duration: 0.3)

    /// 卡牌从右侧弹性滑入
    static let cardEnter: Animation = .spring(duration: 0.45, bounce: 0.18)

    /// 确认粒子爆炸
    static let celebration: Animation = .easeOut(duration: 1.2)

    /// 呼吸光效 — 缓慢循环
    static let breathe: Animation = .easeInOut(duration: 2.0).repeatForever(autoreverses: true)

    /// 食运卡片浮动 — 慢速上下
    static let fortuneFloat: Animation = .easeInOut(duration: 3.0).repeatForever(autoreverses: true)

    /// 光晕扩散
    static let glowPulse: Animation = .easeInOut(duration: 1.0)

    /// 页面转场
    static let pageTransition: Animation = .spring(duration: 0.4, bounce: 0.1)

    /// 标签选中
    static let tagSelect: Animation = .spring(duration: 0.25, bounce: 0.3)

    /// 通用弹性
    static let bouncy: Animation = .spring(duration: 0.35, bounce: 0.25)

    /// 光泽扫过
    static let shimmer: Animation = .easeInOut(duration: 2.5).repeatForever(autoreverses: false)
}

// MARK: - 通用 ViewModifier

/// 柔和卡片阴影
struct CardShadow: ViewModifier {
    var radius: CGFloat = AppLayout.cardShadowRadius
    func body(content: Content) -> some View {
        content.shadow(
            color: .black.opacity(0.08),
            radius: radius,
            x: 0,
            y: AppLayout.cardShadowY
        )
    }
}

/// 圆角卡片背景
struct CardStyle: ViewModifier {
    var padding: CGFloat = AppLayout.cardPadding
    func body(content: Content) -> some View {
        content
            .padding(padding)
            .background(
                RoundedRectangle(cornerRadius: AppLayout.cardCorner, style: .continuous)
                    .fill(Color(.systemBackground))
            )
            .modifier(CardShadow())
    }
}

extension View {
    func cardStyle(padding: CGFloat = AppLayout.cardPadding) -> some View {
        modifier(CardStyle(padding: padding))
    }
    func cardShadow(radius: CGFloat = AppLayout.cardShadowRadius) -> some View {
        modifier(CardShadow(radius: radius))
    }
}
