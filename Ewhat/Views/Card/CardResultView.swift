import SwiftUI

/// 抽卡结果页 — 确认/拒绝操作
struct CardResultView: View {
    let food: Food
    let drawCount: Int
    let onConfirm: () -> Void
    let onReject: () -> Void

    var body: some View {
        VStack(spacing: 24) {
            // 抽卡次数
            if drawCount > 1 {
                Text("第 \(drawCount) 次翻牌")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            // 食物卡牌
            FoodCardView(food: food)

            // 操作按钮
            HStack(spacing: 16) {
                // 拒绝
                Button(action: onReject) {
                    Label("换一个", systemImage: "hand.thumbsdown")
                        .font(.headline)
                        .foregroundStyle(.red)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(
                            RoundedRectangle(cornerRadius: 14)
                                .stroke(.red.opacity(0.5), lineWidth: 1.5)
                        )
                }

                // 确认
                Button(action: onConfirm) {
                    Label("就吃这个！", systemImage: "checkmark.circle.fill")
                        .font(.headline)
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(
                            RoundedRectangle(cornerRadius: 14)
                                .fill(.green.gradient)
                        )
                }
            }
        }
        .padding()
    }
}
