import SwiftUI

/// 筛选条件页面
struct FilterView: View {
    @Bindable var cardVM: CardViewModel
    let onStartDraw: () -> Void

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                // 菜系筛选
                filterSection(title: "菜系", items: Cuisine.allCases) { cuisine in
                    toggleSelection(cuisine, in: &cardVM.selectedCuisines)
                } isSelected: { cuisine in
                    cardVM.selectedCuisines.contains(cuisine)
                } label: { cuisine in
                    "\(cuisine.emoji) \(cuisine.rawValue)"
                }

                // 场景筛选
                filterSection(title: "场景", items: DiningScene.allCases) { scene in
                    toggleSelection(scene, in: &cardVM.selectedScenes)
                } isSelected: { scene in
                    cardVM.selectedScenes.contains(scene)
                } label: { scene in
                    "\(scene.emoji) \(scene.rawValue)"
                }

                // 预算筛选
                filterSection(title: "预算", items: PriceRange.allCases) { price in
                    toggleSelection(price, in: &cardVM.selectedPriceRanges)
                } isSelected: { price in
                    cardVM.selectedPriceRanges.contains(price)
                } label: { price in
                    "\(price.emoji) \(price.rawValue)"
                }

                // 开始抽卡按钮
                DrawCardButton(action: onStartDraw)
                    .padding(.top, 8)
            }
            .padding()
        }
        .navigationTitle("选择偏好")
    }

    // MARK: - Helpers

    private func filterSection<T: Identifiable & Hashable>(
        title: String,
        items: [T],
        action: @escaping (T) -> Void,
        isSelected: @escaping (T) -> Bool,
        label: @escaping (T) -> String
    ) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.headline)

            TagFlowLayout(items: items) { item in
                Button { action(item) } label: {
                    Text(label(item))
                        .font(.subheadline)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(
                            isSelected(item)
                                ? AnyShapeStyle(.orange)
                                : AnyShapeStyle(.gray.opacity(0.15))
                        )
                        .foregroundStyle(isSelected(item) ? .white : .primary)
                        .clipShape(Capsule())
                }
            }
        }
    }

    private func toggleSelection<T: Hashable>(_ item: T, in set: inout Set<T>) {
        if set.contains(item) {
            set.remove(item)
        } else {
            set.insert(item)
        }
    }
}
