import SwiftUI

/// 食物卡牌正面
struct FoodCardView: View {
    let food: Food

    var body: some View {
        VStack(spacing: 14) {
            // ── 顶部：稀有度星星 + 菜系标签 ──
            HStack {
                HStack(spacing: 3) {
                    ForEach(0..<food.rarity.starCount, id: \.self) { _ in
                        Image(systemName: "star.fill")
                            .font(.caption2)
                            .foregroundStyle(rarityStarColor)
                    }
                    if food.rarity != .common {
                        Text(food.rarity.displayName)
                            .font(AppFonts.tiny)
                            .foregroundStyle(rarityStarColor)
                    }
                }
                Spacer()
                Text(food.cuisine.rawValue)
                    .font(AppFonts.captionBold)
                    .foregroundStyle(.white)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(
                        Capsule().fill(AppColors.cuisineColor(food.cuisine))
                    )
            }

            Spacer().frame(height: 4)

            // ── 大 Emoji ──
            Text(food.emoji)
                .font(.system(size: 80))
                .shadow(color: .black.opacity(0.1), radius: 4, y: 2)

            // ── 食物名称 ──
            Text(food.name)
                .font(AppFonts.foodName)

            // ── 趣味文案 ──
            Text(food.funText)
                .font(AppFonts.funText)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .lineLimit(2)
                .fixedSize(horizontal: false, vertical: true)

            Spacer().frame(height: 2)

            // ── 标签 ──
            HStack(spacing: 6) {
                ForEach(food.tags.prefix(4), id: \.self) { tag in
                    Text(tag)
                        .font(AppFonts.tiny)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(
                            Capsule()
                                .fill(AppColors.warmOrange.opacity(0.1))
                        )
                        .foregroundStyle(AppColors.warmBrown)
                }
            }

            // ── 价格 ──
            HStack(spacing: 4) {
                Text(food.priceRange.emoji)
                Text(food.priceRange.displayText)
                    .font(AppFonts.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(24)
        .frame(maxWidth: .infinity, minHeight: 380)
        .background(
            ZStack {
                RoundedRectangle(cornerRadius: AppLayout.cardCorner, style: .continuous)
                    .fill(Color(.systemBackground))

                // 稀有度边框光晕
                if food.rarity != .common {
                    RoundedRectangle(cornerRadius: AppLayout.cardCorner, style: .continuous)
                        .stroke(
                            LinearGradient(
                                colors: food.rarity == .legendary
                                    ? [.yellow, .orange, .yellow]
                                    : [.blue.opacity(0.4), .purple.opacity(0.4), .blue.opacity(0.4)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: food.rarity == .legendary ? 2.5 : 1.5
                        )
                }
            }
        )
        .cardShadow(radius: food.rarity == .legendary ? 16 : 8)
    }

    private var rarityStarColor: Color {
        switch food.rarity {
        case .common:    return .gray
        case .rare:      return .blue
        case .legendary: return .orange
        }
    }
}
