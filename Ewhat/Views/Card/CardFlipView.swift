import SwiftUI

/// 3D 卡牌翻转动画容器
struct CardFlipView: View {
    let food: Food?
    @Binding var isFlipped: Bool
    var hapticsEnabled: Bool = true

    var body: some View {
        ZStack {
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
        .onTapGesture {
            if !isFlipped {
                if hapticsEnabled { HapticsManager.cardFlip() }
                isFlipped = true
            }
        }
    }
}

/// 卡牌背面 — 精美图案 + 呼吸光效
struct CardBackView: View {
    @State private var breatheScale: CGFloat = 1.0
    @State private var shimmerOffset: CGFloat = -200

    var body: some View {
        ZStack {
            // 背景
            RoundedRectangle(cornerRadius: AppLayout.cardCorner, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [
                            AppColors.warmOrange.opacity(0.85),
                            AppColors.warmCoral.opacity(0.75),
                            AppColors.warmAmber.opacity(0.85),
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )

            // 装饰纹样
            VStack(spacing: 8) {
                // 花纹边框
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .stroke(.white.opacity(0.25), lineWidth: 1.5)
                    .padding(12)

                // 中间内容
            }

            VStack(spacing: 16) {
                // 中式花纹
                Text("🎴")
                    .font(.system(size: 56))
                    .shadow(color: .black.opacity(0.15), radius: 4, y: 2)

                Text("今天吃什么？")
                    .font(AppFonts.sectionTitle)
                    .foregroundStyle(.white)

                Text("长按或点击翻牌")
                    .font(AppFonts.caption)
                    .foregroundStyle(.white.opacity(0.7))
            }

            // 光泽扫过效果
            RoundedRectangle(cornerRadius: AppLayout.cardCorner, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [.clear, .white.opacity(0.15), .clear],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
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
            }
            withAnimation(.easeInOut(duration: 2.5).repeatForever(autoreverses: false)) {
                shimmerOffset = 400
            }
        }
    }
}
