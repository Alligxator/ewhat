import SwiftUI

struct DrawCardButton: View {
    let action: () -> Void
    @State private var isPressed = false

    var body: some View {
        Button {
            action()
        } label: {
            HStack(spacing: 8) {
                Image(systemName: "sparkles")
                Text("抽一张")
                    .font(AppFonts.bodyMedium)
            }
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .background(
                RoundedRectangle(cornerRadius: AppLayout.smallCorner, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [AppColors.warmOrange, AppColors.warmCoral],
                            startPoint: .leading, endPoint: .trailing
                        )
                    )
            )
            .scaleEffect(isPressed ? 0.96 : 1.0)
            .animation(AppAnimations.bouncy, value: isPressed)
        }
        .buttonStyle(.plain)
        .accessibilityLabel("抽一张卡牌")
        .accessibilityHint("随机推荐一道美食")
        .simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in isPressed = true }
                .onEnded { _ in isPressed = false }
        )
    }
}
