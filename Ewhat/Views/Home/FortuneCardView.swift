import SwiftUI

/// 今日食运卡片
struct FortuneCardView: View {
    let fortune: DailyFortune

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // 农历日期
            HStack {
                Text(fortune.fullLunarDisplay)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Spacer()
                Text(fortune.element.emoji)
            }

            // 食运签文
            Text(fortune.fortuneText)
                .font(.subheadline)
                .lineLimit(2)

            // 推荐标签
            HStack {
                ForEach(fortune.luckyAttributes, id: \.self) { attr in
                    Text(attr)
                        .font(.caption2)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(.green.opacity(0.1))
                        .clipShape(Capsule())
                }
            }
        }
        .padding()
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}
