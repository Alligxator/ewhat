import SwiftUI

/// 触觉反馈管理器
enum HapticsManager {

    /// 抽卡翻转 — 中等冲击
    static func cardFlip() {
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()
    }

    /// 确认选择 — 成功通知
    static func confirmSelection() {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
    }

    /// 拒绝 — 轻微冲击
    static func rejectCard() {
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.impactOccurred()
    }

    /// 长按触发 — 重度冲击
    static func longPress() {
        let generator = UIImpactFeedbackGenerator(style: .heavy)
        generator.impactOccurred()
    }

    /// 滑动选择 — 选择变化
    static func selectionChanged() {
        let generator = UISelectionFeedbackGenerator()
        generator.selectionChanged()
    }
}
