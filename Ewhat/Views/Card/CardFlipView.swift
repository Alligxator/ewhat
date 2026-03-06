import SwiftUI

/// 卡牌翻转动画容器
struct CardFlipView: View {
    let food: Food?
    @Binding var isFlipped: Bool

    var body: some View {
        ZStack {
            // 卡牌背面
            CardBackView()
                .opacity(isFlipped ? 0 : 1)
                .rotation3DEffect(
                    .degrees(isFlipped ? 180 : 0),
                    axis: (x: 0, y: 1, z: 0)
                )

            // 卡牌正面
            if let food {
                FoodCardView(food: food)
                    .opacity(isFlipped ? 1 : 0)
                    .rotation3DEffect(
                        .degrees(isFlipped ? 0 : -180),
                        axis: (x: 0, y: 1, z: 0)
                    )
            }
        }
        .animation(.spring(duration: 0.6, bounce: 0.2), value: isFlipped)
    }
}

/// 卡牌背面
struct CardBackView: View {
    @State private var breatheScale: CGFloat = 1.0

    var body: some View {
        VStack {
            Text("🎴")
                .font(.system(size: 60))
            Text("长按翻牌")
                .font(.headline)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, minHeight: 400)
        .background(
            RoundedRectangle(cornerRadius: 24)
                .fill(.orange.gradient.opacity(0.3))
                .shadow(color: .orange.opacity(0.2), radius: breatheScale * 10)
        )
        .scaleEffect(breatheScale)
        .onAppear {
            withAnimation(.easeInOut(duration: 2).repeatForever(autoreverses: true)) {
                breatheScale = 1.03
            }
        }
    }
}
