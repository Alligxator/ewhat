import SwiftUI
import SwiftData

/// 黑名单管理页面
struct BlacklistView: View {
    @Query private var preferences: [UserPreference]
    @Environment(\.modelContext) private var modelContext

    @State private var searchText = ""
    @State private var allFoods: [Food] = []

    private var preference: UserPreference {
        preferences.first ?? UserPreference()
    }

    var body: some View {
        List {
            // 已拉黑的食物
            Section("已排除的食物") {
                if preference.blacklistedFoods.isEmpty {
                    Text("还没有排除任何食物")
                        .foregroundStyle(.secondary)
                } else {
                    ForEach(preference.blacklistedFoods, id: \.self) { name in
                        HStack {
                            Text(name)
                            Spacer()
                            Button("移除") {
                                preference.blacklistedFoods.removeAll { $0 == name }
                            }
                            .foregroundStyle(.red)
                        }
                    }
                }
            }

            // 添加到黑名单
            Section("添加排除项") {
                ForEach(filteredFoods) { food in
                    HStack {
                        Text(food.emoji)
                        Text(food.name)
                        Spacer()
                        if preference.blacklistedFoods.contains(food.name) {
                            Image(systemName: "checkmark")
                                .foregroundStyle(.red)
                        }
                    }
                    .contentShape(Rectangle())
                    .onTapGesture {
                        toggleBlacklist(food.name)
                    }
                }
            }
        }
        .searchable(text: $searchText, prompt: "搜索食物")
        .navigationTitle("黑名单")
        .onAppear {
            allFoods = FoodDatabase.loadAll()
        }
    }

    private var filteredFoods: [Food] {
        if searchText.isEmpty { return allFoods }
        return allFoods.filter { $0.name.contains(searchText) }
    }

    private func toggleBlacklist(_ name: String) {
        if preference.blacklistedFoods.contains(name) {
            preference.blacklistedFoods.removeAll { $0 == name }
        } else {
            preference.blacklistedFoods.append(name)
        }
    }
}
