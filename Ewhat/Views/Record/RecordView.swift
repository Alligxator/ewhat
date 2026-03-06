import SwiftUI
import SwiftData

/// 饮食记录页面
struct RecordView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \MealRecord.date, order: .reverse) private var records: [MealRecord]

    var body: some View {
        List {
            if records.isEmpty {
                ContentUnavailableView(
                    "还没有记录",
                    systemImage: "fork.knife.circle",
                    description: Text("去抽卡选一个今天吃什么吧！")
                )
            } else {
                ForEach(records) { record in
                    HStack {
                        Text(record.emoji)
                            .font(.title2)
                        VStack(alignment: .leading) {
                            Text(record.foodName)
                                .font(.headline)
                            Text(record.cuisine)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        Spacer()
                        Text(record.date, style: .date)
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                    }
                }
            }
        }
        .navigationTitle("饮食记录")
    }
}
