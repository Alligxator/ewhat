import SwiftUI

/// 食物卡牌正面
struct FoodCardView: View {
    let food: Food

    var body: some View {
        VStack(spacing: 16) {
            // 稀有度标识
            HStack {
                ForEach(0..<food.rarity.starCount, id: \.self) { _ in
                    Image(systemName: "star.fill")
                        .foregroundStyle(.yellow)
                }
                Spacer()
                Text(food.cuisine.rawValue)
                    .font(.caption)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(.ultraThinMaterial)
                    .clipShape(Capsule())
            }

            // Emoji 大图
            Text(food.emoji)
                .font(.system(size: 80))

            // 食物名称
            Text(food.name)
                .font(.title2.bold())

            // 趣味文案
            Text(food.funText)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)

            // 标签
            HStack {
                ForEach(food.tags.prefix(3), id: \.self) { tag in
                    Text(tag)
                        .font(.caption2)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 3)
                        .background(.orange.opacity(0.1))
                        .clipShape(Capsule())
                }
            }

            // 价格区间
            Text(food.priceRange.emoji + " " + food.priceRange.displayText)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding(24)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 24)
                .fill(.background)
                .shadow(color: .black.opacity(0.1), radius: 10, y: 5)
        )
    }
}
