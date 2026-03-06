import SwiftUI

/// App 字体
enum AppFonts {
    /// 标题字体 — 圆体
    static func title(_ size: CGFloat) -> Font {
        .system(size: size, weight: .bold, design: .rounded)
    }

    /// 正文字体 — 系统默认
    static func body(_ size: CGFloat) -> Font {
        .system(size: size)
    }

    /// 趣味文案字体
    static func funText(_ size: CGFloat) -> Font {
        .system(size: size, weight: .medium, design: .rounded)
    }

    /// 签文字体
    static func fortune(_ size: CGFloat) -> Font {
        .system(size: size, weight: .light, design: .serif)
    }
}
