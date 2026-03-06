import SwiftUI
import SwiftData

/// 黑名单管理页面
struct BlacklistView: View {
    @Query private var preferences: [UserPreference]
    @Environment(\.modelContext) private var modelContext
    @State private var searchText = ""
    @State private var allFoods: [Food] = []

    private var pref: UserPreference {
        preferences.first ?? UserPreference()
    }

    var body: some View {
        List {
            // ── 已拉黑列表 ──
            if !pref.blacklistedFoods.isEmpty {
                Section("已排除 (\(pref.blacklistedFoods.count))") {
                    ForEach(pref.blacklistedFoods, id: \.self) { name in
                        HStack {
                            if let food = allFoods.first(where: { $0.name == name }) {
                                Text(food.emoji)
                            }
                            Text(name)
                            Spacer()
                        }
                        .swipeActions(edge: .trailing) {
                            Button("移除", role: .destructive) {
                                withAnimation { pref.removeFromBlacklist(name) }
                            }
                        }
                    }
                }
            }

            // ── 添加区 ──
            Section("点击添加到黑名单") {
                ForEach(filteredFoods) { food in
                    let isBlocked = pref.isBlacklisted(food.name)
                    Button {
                        withAnimation(AppAnimations.tagSelect) {
                            if isBlocked {
                                pref.removeFromBlacklist(food.name)
                            } else {
                                pref.addToBlacklist(food.name)
                            }
                        }
                    } label: {
                        HStack(spacing: 10) {
                            Text(food.emoji)
                                .font(.title3)
                            VStack(alignment: .leading, spacing: 2) {
                                Text(food.name)
                                    .font(AppFonts.bodyMedium)
                                    .foregroundStyle(.primary)
                                Text(food.cuisine.rawValue)
                                    .font(AppFonts.tiny)
                                    .foregroundStyle(.secondary)
                            }
                            Spacer()
                            if isBlocked {
                                Image(systemName: "xmark.circle.fill")
                                    .foregroundStyle(AppColors.reject)
                                    .transition(.scale)
                            }
                        }
                    }
                }
            }
        }
        .searchable(text: $searchText, prompt: "搜索食物")
        .navigationTitle("食物黑名单")
        .onAppear {
            allFoods = FoodDatabase.loadAll()
        }
    }

    private var filteredFoods: [Food] {
        if searchText.isEmpty { return allFoods }
        let query = searchText.lowercased()
        return allFoods.filter {
            $0.name.lowercased().contains(query) ||
            $0.cuisine.rawValue.contains(query) ||
            $0.tags.contains { $0.contains(query) }
        }
    }
}
