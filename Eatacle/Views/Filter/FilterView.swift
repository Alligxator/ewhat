import SwiftUI

/// 筛选条件页面 — 标签流多选
struct FilterView: View {
    @Bindable var cardVM: CardViewModel
    var hapticsEnabled: Bool = true
    let onStartDraw: () -> Void
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: AppLayout.sectionSpacing) {

                // ── 菜系 ──
                filterSection(
                    title: "菜系",
                    icon: "fork.knife",
                    items: Cuisine.allCases
                ) { c in
                    toggle(c, in: &cardVM.selectedCuisines)
                } isSelected: { c in
                    cardVM.selectedCuisines.contains(c)
                } label: { c in
                    "\(c.emoji) \(c.rawValue)"
                } color: { c in
                    AppColors.cuisineColor(c)
                }

                // ── 类别 ──
                filterSection(
                    title: "类别",
                    icon: "square.grid.2x2",
                    items: FoodType.allCases
                ) { t in
                    toggle(t, in: &cardVM.selectedCategories)
                } isSelected: { t in
                    cardVM.selectedCategories.contains(t)
                } label: { t in
                    t.rawValue
                } color: { _ in
                    AppColors.warmAmber
                }

                // ── 场景 ──
                filterSection(
                    title: "场景",
                    icon: "person.2",
                    items: DiningScene.allCases
                ) { s in
                    toggle(s, in: &cardVM.selectedScenes)
                } isSelected: { s in
                    cardVM.selectedScenes.contains(s)
                } label: { s in
                    "\(s.emoji) \(s.rawValue)"
                } color: { _ in
                    AppColors.fortune
                }

                // ── 预算 ──
                filterSection(
                    title: "预算",
                    icon: "yensign.circle",
                    items: PriceRange.allCases
                ) { p in
                    toggle(p, in: &cardVM.selectedPriceRanges)
                } isSelected: { p in
                    cardVM.selectedPriceRanges.contains(p)
                } label: { p in
                    "\(p.emoji) \(p.displayName)"
                } color: { _ in
                    AppColors.warmCoral
                }

                // ── 临时排除 ──
                VStack(alignment: .leading, spacing: 8) {
                    Label("今天不想吃…", systemImage: "xmark.circle")
                        .font(AppFonts.sectionTitle)
                        .foregroundStyle(AppColors.reject)

                    let quickTags = ["辣", "油炸", "甜", "生冷", "重口"]
                    TagFlowLayout(items: quickTags.map { TagItem(label: $0) }) { item in
                        let isExcluded = cardVM.sessionExcludedTags.contains(item.label)
                        Button {
                            withAnimation(AppAnimations.tagSelect) {
                                if isExcluded {
                                    cardVM.removeSessionExclusion(item.label)
                                } else {
                                    cardVM.addSessionExclusion(item.label)
                                }
                            }
                        } label: {
                            Text(item.label)
                                .font(AppFonts.tagFont)
                                .padding(.horizontal, 14)
                                .padding(.vertical, 8)
                                .background(
                                    Capsule()
                                        .fill(isExcluded ? AppColors.reject : Color(.tertiarySystemFill))
                                )
                                .foregroundStyle(isExcluded ? .white : .primary)
                        }
                    }
                }

                // ── 开始抽卡 ──
                DrawCardButton(action: onStartDraw)
                    .padding(.top, 8)

                // ── 重置 ──
                if cardVM.hasActiveFilters {
                    Button {
                        withAnimation { cardVM.resetFilters() }
                    } label: {
                        Text("重置所有筛选")
                            .font(AppFonts.caption)
                            .foregroundStyle(.secondary)
                            .frame(maxWidth: .infinity)
                    }
                }
            }
            .padding(AppLayout.pagePadding)
        }
        .background(AppColors.pageBg.ignoresSafeArea())
        .navigationTitle("选择偏好")
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("关闭") { dismiss() }
            }
        }
    }

    // MARK: - 通用筛选 Section

    private func filterSection<T: Identifiable & Hashable>(
        title: String,
        icon: String,
        items: [T],
        action: @escaping (T) -> Void,
        isSelected: @escaping (T) -> Bool,
        label: @escaping (T) -> String,
        color: @escaping (T) -> Color
    ) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Label(title, systemImage: icon)
                .font(AppFonts.sectionTitle)

            TagFlowLayout(items: items) { item in
                let selected = isSelected(item)
                Button {
                    withAnimation(AppAnimations.tagSelect) {
                        if hapticsEnabled { HapticsManager.selectionChanged() }
                        action(item)
                    }
                } label: {
                    Text(label(item))
                        .font(AppFonts.tagFont)
                        .padding(.horizontal, 14)
                        .padding(.vertical, 8)
                        .background(
                            Capsule()
                                .fill(selected ? color(item) : Color(.tertiarySystemFill))
                        )
                        .foregroundStyle(selected ? .white : .primary)
                        .scaleEffect(selected ? 1.05 : 1.0)
                }
            }
        }
    }

    private func toggle<T: Hashable>(_ item: T, in set: inout Set<T>) {
        if set.contains(item) {
            set.remove(item)
        } else {
            set.insert(item)
        }
    }
}

/// 简单 Identifiable wrapper for strings
private struct TagItem: Identifiable {
    let label: String
    var id: String { label }
}
