import SwiftUI

/// 抽卡按钮
struct DrawCardButton: View {
    let action: () -> Void

    @State private var isPressed = false

    var body: some View {
        Button(action: action) {
            Text("开始抽卡 🎴")
                .font(.title3.bold())
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(.orange.gradient)
                )
                .scaleEffect(isPressed ? 0.95 : 1.0)
        }
        .buttonStyle(.plain)
        .sensoryFeedback(.impact(flexibility: .solid), trigger: isPressed)
    }
}
