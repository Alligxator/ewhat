import SwiftUI

/// Font definitions use fixed sizes for design consistency. Dynamic Type is not currently supported.
enum AppFonts {

    // ── 标题 — 圆体加粗 ──
    static let heroTitle   = Font.system(size: 28, weight: .bold, design: .rounded)
    static let pageTitle   = Font.system(size: 22, weight: .bold, design: .rounded)
    static let sectionTitle = Font.system(size: 18, weight: .semibold, design: .rounded)

    // ── 正文 ──
    static let body        = Font.system(size: 16)
    static let bodyMedium  = Font.system(size: 16, weight: .medium)
    static let caption     = Font.system(size: 13, weight: .regular)
    static let captionBold = Font.system(size: 13, weight: .semibold)
    static let tiny        = Font.system(size: 11, weight: .regular)

    // ── 特殊 ──
    static let foodName    = Font.system(size: 24, weight: .bold, design: .rounded)
    static let funText     = Font.system(size: 15, weight: .medium, design: .rounded)
    static let fortune     = Font.system(size: 14, weight: .regular, design: .serif)
    static let fortuneTitle = Font.system(size: 16, weight: .medium, design: .serif)
    static let emoji       = Font.system(size: 72)
    static let tagFont     = Font.system(size: 14, weight: .medium)

    // ── 数字 ──
    static let statNumber  = Font.system(size: 32, weight: .bold, design: .rounded)
    static let statLabel   = Font.system(size: 12, weight: .medium)
}
