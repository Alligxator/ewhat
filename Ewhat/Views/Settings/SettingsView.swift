import SwiftUI
import SwiftData

/// 设置页面
struct SettingsView: View {
    @Query private var preferences: [UserPreference]
    @Environment(\.modelContext) private var modelContext
    @AppStorage("colorSchemePreference") private var colorSchemePreference = 0 // 0=auto 1=light 2=dark

    private var pref: UserPreference {
        if let existing = preferences.first { return existing }
        let newPref = UserPreference()
        modelContext.insert(newPref)
        return newPref
    }

    var body: some View {
        List {
            // ── 食运 ──
            Section {
                Toggle(isOn: binding(\.fortuneEnabled)) {
                    Label("食运影响推荐", systemImage: "sparkles")
                }
                .tint(AppColors.warmOrange)
            } header: {
                Text("食运系统")
            } footer: {
                Text("开启后，每日食运的五行属性会影响推荐权重")
            }

            // ── 偏好菜系 ──
            Section("偏好加权") {
                NavigationLink {
                    favoriteCuisineList
                } label: {
                    Label {
                        HStack {
                            Text("偏好菜系")
                            Spacer()
                            Text("\(pref.favoriteCuisines.count) 个")
                                .foregroundStyle(.secondary)
                        }
                    } icon: {
                        Image(systemName: "heart.fill")
                            .foregroundStyle(AppColors.warmCoral)
                    }
                }

                NavigationLink {
                    favoriteTagList
                } label: {
                    Label {
                        HStack {
                            Text("偏好标签")
                            Spacer()
                            Text("\(pref.favoriteTags.count) 个")
                                .foregroundStyle(.secondary)
                        }
                    } icon: {
                        Image(systemName: "tag.fill")
                            .foregroundStyle(AppColors.warmAmber)
                    }
                }
            }

            // ── 黑名单 ──
            Section("排除设置") {
                NavigationLink {
                    BlacklistView()
                } label: {
                    Label {
                        HStack {
                            Text("食物黑名单")
                            Spacer()
                            Text("\(pref.blacklistedFoods.count) 项")
                                .foregroundStyle(.secondary)
                        }
                    } icon: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundStyle(AppColors.reject)
                    }
                }

                NavigationLink {
                    cuisineBlacklist
                } label: {
                    Label {
                        HStack {
                            Text("菜系黑名单")
                            Spacer()
                            Text("\(pref.blacklistedCuisines.count) 个")
                                .foregroundStyle(.secondary)
                        }
                    } icon: {
                        Image(systemName: "eye.slash.fill")
                            .foregroundStyle(.orange)
                    }
                }
            }

            // ── 反馈 ──
            Section("交互反馈") {
                Toggle(isOn: binding(\.hapticsEnabled)) {
                    Label("触觉反馈", systemImage: "iphone.radiowaves.left.and.right")
                }
                .tint(AppColors.warmOrange)

                Toggle(isOn: binding(\.soundEnabled)) {
                    Label("音效", systemImage: "speaker.wave.2")
                }
                .tint(AppColors.warmOrange)
            }

            // ── 外观 ──
            Section("外观") {
                Picker(selection: $colorSchemePreference) {
                    Text("跟随系统").tag(0)
                    Text("浅色模式").tag(1)
                    Text("深色模式").tag(2)
                } label: {
                    Label("主题", systemImage: "circle.lefthalf.filled")
                }
            }

            // ── 关于 ──
            Section("关于") {
                HStack {
                    Label("版本", systemImage: "info.circle")
                    Spacer()
                    Text("1.0.0")
                        .foregroundStyle(.secondary)
                }
                HStack {
                    Label("食物数据库", systemImage: "cylinder.split.1x2")
                    Spacer()
                    Text("\(FoodDatabase.loadAll().count) 条")
                        .foregroundStyle(.secondary)
                }
            }
        }
        .navigationTitle("设置")
        .preferredColorScheme(
            colorSchemePreference == 1 ? .light :
            colorSchemePreference == 2 ? .dark : nil
        )
    }

    // MARK: - 偏好菜系选择

    private var favoriteCuisineList: some View {
        List {
            ForEach(Cuisine.allCases) { cuisine in
                let isFav = pref.favoriteCuisines.contains(cuisine.rawValue)
                Button {
                    pref.toggleFavoriteCuisine(cuisine)
                } label: {
                    HStack {
                        Text(cuisine.emoji)
                        Text(cuisine.rawValue)
                            .foregroundStyle(.primary)
                        Spacer()
                        if isFav {
                            Image(systemName: "heart.fill")
                                .foregroundStyle(AppColors.warmCoral)
                        }
                    }
                }
            }
        }
        .navigationTitle("偏好菜系")
    }

    // MARK: - 偏好标签

    private var favoriteTagList: some View {
        let allTags = ["辣", "清淡", "海鲜", "肉食", "面条", "米饭", "汤", "烧烤",
                       "甜品", "凉菜", "油炸", "蔬菜", "家常", "下饭", "滋补"]
        return List {
            ForEach(allTags, id: \.self) { tag in
                let isFav = pref.favoriteTags.contains(tag)
                Button {
                    if isFav { pref.removeFavoriteTag(tag) }
                    else { pref.addFavoriteTag(tag) }
                } label: {
                    HStack {
                        Text(tag)
                            .foregroundStyle(.primary)
                        Spacer()
                        if isFav {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundStyle(AppColors.warmOrange)
                        }
                    }
                }
            }
        }
        .navigationTitle("偏好标签")
    }

    // MARK: - 菜系黑名单

    private var cuisineBlacklist: some View {
        List {
            ForEach(Cuisine.allCases) { cuisine in
                let isBlocked = pref.blacklistedCuisines.contains(cuisine.rawValue)
                Button {
                    if isBlocked { pref.unblacklistCuisine(cuisine) }
                    else { pref.blacklistCuisine(cuisine) }
                } label: {
                    HStack {
                        Text(cuisine.emoji)
                        Text(cuisine.rawValue)
                            .foregroundStyle(.primary)
                        Spacer()
                        if isBlocked {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundStyle(AppColors.reject)
                        }
                    }
                }
            }
        }
        .navigationTitle("菜系黑名单")
    }

    // MARK: - Binding helper

    private func binding(_ keyPath: ReferenceWritableKeyPath<UserPreference, Bool>) -> Binding<Bool> {
        Binding(
            get: { pref[keyPath: keyPath] },
            set: { pref[keyPath: keyPath] = $0 }
        )
    }
}
