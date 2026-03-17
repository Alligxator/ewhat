import SwiftUI

/// 今日食运卡片 — 呼吸浮动 + 透明度微变
struct FortuneCardView: View {
    let fortune: DailyFortune

    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var floatOffset: CGFloat = 0
    @State private var glowOpacity: Double = 0.2
    @State private var contentOpacity: Double = 0.85
    @State private var shadowRadius: CGFloat = 6

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // ── 顶部行：农历日期 + 五行 ──
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text(fortune.weekdayString)
                        .font(AppFonts.captionBold)
                        .foregroundStyle(.secondary)
                    Text(fortune.fullLunarDisplay)
                        .font(AppFonts.fortuneTitle)
                        .foregroundStyle(AppColors.warmBrown)
                }

                Spacer()

                // 五行徽章
                VStack(spacing: 2) {
                    Text(fortune.element.emoji)
                        .font(.title2)
                    Text(fortune.element.rawValue + "属性")
                        .font(AppFonts.tiny)
                        .foregroundStyle(AppColors.elementColor(fortune.element))
                }
                .padding(.horizontal, 10)
                .padding(.vertical, 6)
                .background(
                    RoundedRectangle(cornerRadius: AppLayout.tinyCorner, style: .continuous)
                        .fill(AppColors.elementColor(fortune.element).opacity(0.1))
                )
            }

            // ── 分隔线 ──
            Rectangle()
                .fill(
                    LinearGradient(
                        colors: [.clear, AppColors.warmAmber.opacity(0.4), .clear],
                        startPoint: .leading, endPoint: .trailing
                    )
                )
                .frame(height: 1)

            // ── 主题 + 签文 ──
            Text(fortune.dailyTheme)
                .font(AppFonts.sectionTitle)
                .foregroundStyle(AppColors.warmOrange)

            Text(fortune.fortuneText.components(separatedBy: "；").first ?? "")
                .font(AppFonts.fortune)
                .foregroundStyle(.primary.opacity(contentOpacity))
                .lineLimit(2)

            // ── 宜 / 忌 ──
            HStack(spacing: 16) {
                HStack(spacing: 4) {
                    Text("宜")
                        .font(AppFonts.captionBold)
                        .foregroundStyle(.white)
                        .frame(width: 22, height: 22)
                        .background(AppColors.confirm, in: RoundedRectangle(cornerRadius: 4))
                    Text(fortune.luckyAction)
                        .font(AppFonts.caption)
                }

                HStack(spacing: 4) {
                    Text("忌")
                        .font(AppFonts.captionBold)
                        .foregroundStyle(.white)
                        .frame(width: 22, height: 22)
                        .background(AppColors.reject, in: RoundedRectangle(cornerRadius: 4))
                    Text(fortune.avoidAction)
                        .font(AppFonts.caption)
                }
            }

            // ── 推荐属性标签 ──
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 6) {
                    ForEach(fortune.luckyAttributes.prefix(5), id: \.self) { attr in
                        Text(attr)
                            .font(AppFonts.tiny)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(
                                Capsule()
                                    .fill(AppColors.elementColor(fortune.element).opacity(0.12))
                            )
                    }
                }
            }
        }
        .padding(AppLayout.cardPadding)
        .background(
            ZStack {
                RoundedRectangle(cornerRadius: AppLayout.cardCorner, style: .continuous)
                    .fill(.ultraThinMaterial)

                // 呼吸光晕边框
                RoundedRectangle(cornerRadius: AppLayout.cardCorner, style: .continuous)
                    .stroke(
                        AppColors.elementColor(fortune.element).opacity(glowOpacity),
                        lineWidth: 1.5
                    )
            }
        )
        .shadow(
            color: AppColors.elementColor(fortune.element).opacity(glowOpacity * 0.5),
            radius: shadowRadius,
            y: 2
        )
        .offset(y: floatOffset)
        .onAppear {
            guard !reduceMotion else { return }
            // 缓慢上下浮动
            withAnimation(AppAnimations.fortuneFloat) {
                floatOffset = -5
            }
            // 光晕 + 透明度微变
            withAnimation(AppAnimations.breathe) {
                glowOpacity = 0.55
                contentOpacity = 1.0
                shadowRadius = 12
            }
        }
    }
}
