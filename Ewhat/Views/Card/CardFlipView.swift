import SwiftUI

/// 3D 卡牌翻转动画容器 — 翻转时光晕扩散
struct CardFlipView: View {
    let food: Food?
    @Binding var isFlipped: Bool
    var hapticsEnabled: Bool = true

    /// 翻转瞬间的光晕半径
    @State private var glowRadius: CGFloat = 0
    @State private var glowOpacity: Double = 0

    var body: some View {
        ZStack {
            // ── 光晕层（翻转时向外扩散） ──
            if let food {
                RoundedRectangle(cornerRadius: AppLayout.cardCorner, style: .continuous)
                    .fill(AppColors.cuisineColor(food.cuisine).opacity(glowOpacity))
                    .blur(radius: glowRadius)
                    .scaleEffect(1.0 + glowRadius / 200)
            }

            // ── 背面 ──
            CardBackView()
                .opacity(isFlipped ? 0 : 1)
                .rotation3DEffect(
                    .degrees(isFlipped ? 180 : 0),
                    axis: (x: 0, y: 1, z: 0),
                    perspective: 0.5
                )

            // ── 正面 ──
            if let food {
                FoodCardView(food: food)
                    .opacity(isFlipped ? 1 : 0)
                    .rotation3DEffect(
                        .degrees(isFlipped ? 0 : -180),
                        axis: (x: 0, y: 1, z: 0),
                        perspective: 0.5
                    )
            }
        }
        .animation(AppAnimations.cardFlip, value: isFlipped)
        .onChange(of: isFlipped) { _, flipped in
            if flipped {
                triggerGlowBurst()
            }
        }
        .onTapGesture {
            if !isFlipped {
                if hapticsEnabled { HapticsManager.cardFlip() }
                isFlipped = true
            }
        }
    }

    /// 翻转时光晕爆发：快速扩大后衰减
    private func triggerGlowBurst() {
        glowRadius = 0
        glowOpacity = 0.5

        withAnimation(AppAnimations.glowPulse) {
            glowRadius = 30
            glowOpacity = 0
        }
    }
}

// MARK: - 卡牌背面 — 呼吸光效 + 装饰纹样 + 光泽扫过

struct CardBackView: View {
    @State private var breatheScale: CGFloat = 1.0
    @State private var breatheGlow: CGFloat = 8
    @State private var shimmerOffset: CGFloat = -300
    @State private var innerGlow: Double = 0.15

    var body: some View {
        ZStack {
            // ── 呼吸外光晕 ──
            RoundedRectangle(cornerRadius: AppLayout.cardCorner + 4, style: .continuous)
                .fill(AppColors.warmOrange.opacity(0.15))
                .blur(radius: breatheGlow)
                .scaleEffect(breatheScale + 0.01)

            // ── 主卡体 ──
            RoundedRectangle(cornerRadius: AppLayout.cardCorner, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [
                            AppColors.warmOrange.opacity(0.88),
                            AppColors.warmCoral.opacity(0.78),
                            AppColors.warmAmber.opacity(0.88),
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )

            // ── 装饰内边框 ──
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .stroke(.white.opacity(innerGlow), lineWidth: 1.5)
                .padding(14)

            // ── 角落装饰点 ──
            GeometryReader { geo in
                let inset: CGFloat = 28
                ForEach(0..<4, id: \.self) { corner in
                    let x: CGFloat = corner % 2 == 0 ? inset : geo.size.width - inset
                    let y: CGFloat = corner < 2 ? inset : geo.size.height - inset
                    Circle()
                        .fill(.white.opacity(0.25))
                        .frame(width: 6, height: 6)
                        .position(x: x, y: y)
                }
            }

            // ── 中心内容 ──
            VStack(spacing: 14) {
                Text("🎴")
                    .font(.system(size: 56))
                    .shadow(color: .black.opacity(0.15), radius: 4, y: 2)

                Text("今天吃什么？")
                    .font(AppFonts.sectionTitle)
                    .foregroundStyle(.white)

                Text("长按或点击翻牌")
                    .font(AppFonts.caption)
                    .foregroundStyle(.white.opacity(0.65))
            }

            // ── 光泽扫过 ──
            RoundedRectangle(cornerRadius: AppLayout.cardCorner, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [.clear, .white.opacity(0.18), .clear],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .frame(width: 120)
                .offset(x: shimmerOffset)
                .mask(
                    RoundedRectangle(cornerRadius: AppLayout.cardCorner, style: .continuous)
                )
        }
        .frame(maxWidth: .infinity, minHeight: 380)
        .scaleEffect(breatheScale)
        .cardShadow(radius: 12)
        .onAppear {
            withAnimation(AppAnimations.breathe) {
                breatheScale = 1.02
                breatheGlow = 14
                innerGlow = 0.3
            }
            withAnimation(AppAnimations.shimmer) {
                shimmerOffset = 300
            }
        }
    }
}
