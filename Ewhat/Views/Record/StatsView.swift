import SwiftUI
import SwiftData

/// 饮食统计页面
struct StatsView: View {
    let records: [MealRecord]

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // 菜系分布
                Text("菜系分布")
                    .font(.headline)

                if cuisineDistribution.isEmpty {
                    Text("暂无数据")
                        .foregroundStyle(.secondary)
                } else {
                    ForEach(cuisineDistribution, id: \.cuisine) { item in
                        HStack {
                            Text(item.cuisine)
                                .frame(width: 60, alignment: .leading)
                            GeometryReader { geo in
                                RoundedRectangle(cornerRadius: 4)
                                    .fill(.orange.gradient)
                                    .frame(width: geo.size.width * item.ratio)
                            }
                            .frame(height: 20)
                            Text("\(item.count)")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                }

                Divider()

                // 最爱 Top 5
                Text("最爱 Top 5")
                    .font(.headline)

                ForEach(topFoods, id: \.name) { item in
                    HStack {
                        Text(item.name)
                        Spacer()
                        Text("\(item.count) 次")
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .padding()
        }
        .navigationTitle("统计")
    }

    // MARK: - Computed

    private var cuisineDistribution: [(cuisine: String, count: Int, ratio: CGFloat)] {
        let grouped = Dictionary(grouping: records, by: \.cuisine)
        let sorted = grouped.map { ($0.key, $0.value.count) }
            .sorted { $0.1 > $1.1 }
        let maxCount = sorted.first?.1 ?? 1
        return sorted.map { ($0.0, $0.1, CGFloat($0.1) / CGFloat(maxCount)) }
    }

    private var topFoods: [(name: String, count: Int)] {
        let grouped = Dictionary(grouping: records, by: \.foodName)
        return grouped.map { ($0.key, $0.value.count) }
            .sorted { $0.1 > $1.1 }
            .prefix(5)
            .map { ($0.0, $0.1) }
    }
}
