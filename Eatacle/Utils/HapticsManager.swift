import UIKit

/// 触觉反馈管理器 — 预热 generator 避免首次延迟
enum HapticsManager {

    // 预创建 generator 实例
    private static let mediumImpact = UIImpactFeedbackGenerator(style: .medium)
    private static let lightImpact  = UIImpactFeedbackGenerator(style: .light)
    private static let heavyImpact  = UIImpactFeedbackGenerator(style: .heavy)
    private static let softImpact   = UIImpactFeedbackGenerator(style: .soft)
    private static let notification = UINotificationFeedbackGenerator()
    private static let selection    = UISelectionFeedbackGenerator()

    /// 预热所有 generator（App 启动时调用一次）
    static func prepare() {
        mediumImpact.prepare()
        lightImpact.prepare()
        notification.prepare()
        selection.prepare()
    }

    /// 翻牌 → .medium 冲击
    static func cardFlip() {
        mediumImpact.impactOccurred()
    }

    /// 确认选择 → .success 通知
    static func confirmSelection() {
        notification.notificationOccurred(.success)
    }

    /// 拒绝卡牌 → .light 冲击
    static func rejectCard() {
        lightImpact.impactOccurred()
    }

    /// 长按触发 → .heavy 冲击
    static func longPress() {
        heavyImpact.impactOccurred()
    }

    /// 筛选切换 → .selection 变化
    static func selectionChanged() {
        selection.selectionChanged()
    }

    /// 庆祝连击 — 快速三连 soft 冲击
    static func celebrationBurst() {
        let interval: TimeInterval = 0.08
        softImpact.impactOccurred(intensity: 0.6)
        DispatchQueue.main.asyncAfter(deadline: .now() + interval) {
            softImpact.impactOccurred(intensity: 0.8)
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + interval * 2) {
            notification.notificationOccurred(.success)
        }
    }

    /// 卡牌飞出 → .rigid 冲击
    static func cardDismiss() {
        lightImpact.impactOccurred(intensity: 0.5)
    }

    /// 新卡滑入 → soft 冲击
    static func cardEnter() {
        softImpact.impactOccurred(intensity: 0.4)
    }
}
