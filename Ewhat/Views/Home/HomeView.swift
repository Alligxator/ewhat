import SwiftUI
import SwiftData

struct HomeView: View {
    @State private var cardVM = CardViewModel()
    @State private var fortuneVM = FortuneViewModel()
    @State private var recordVM = RecordViewModel()
    @State private var selectedTab = 0
    @State private var showFilter = false
    @State private var showCardResult = false
    @Environment(\.modelContext) private var modelContext
    @Query private var preferences: [UserPreference]

    // matchedGeometryEffect namespace
    @Namespace private var cardNamespace

    private var pref: UserPreference { preferences.first ?? UserPreference() }

    var body: some View {
        TabView(selection: $selectedTab) {
            // ── 首页 ──
            NavigationStack {
                mainPage
                    .navigationTitle("")
                    .navigationBarTitleDisplayMode(.inline)
                    .toolbar {
                        ToolbarItem(placement: .principal) {
                            Text("Ewhat")
                                .font(AppFonts.pageTitle)
                                .foregroundStyle(AppColors.warmOrange)
                        }
                    }
                    .sheet(isPresented: $showFilter) {
                        NavigationStack {
                            FilterView(cardVM: cardVM) {
                                showFilter = false
                                startDraw()
                            }
                        }
                        .presentationDetents([.large])
                    }
                    .fullScreenCover(isPresented: $showCardResult) {
                        cardResultSheet
                    }
            }
            .tabItem { Label("首页", systemImage: "house.fill") }
            .tag(0)

            // ── 记录 ──
            NavigationStack {
                RecordView()
            }
            .tabItem { Label("记录", systemImage: "calendar") }
            .tag(1)

            // ── 设置 ──
            NavigationStack {
                SettingsView()
            }
            .tabItem { Label("设置", systemImage: "gearshape.fill") }
            .tag(2)
        }
        .tint(AppColors.warmOrange)
        .onAppear {
            HapticsManager.prepare()
            recordVM.modelContext = modelContext
            recordVM.refreshAll()
            cardVM.setRecentFoods(recordVM.recentFoodNames())
        }
    }

    // MARK: - 首页内容

    private var mainPage: some View {
        ScrollView {
            VStack(spacing: AppLayout.sectionSpacing) {
                // 食运卡片
                if let fortune = fortuneVM.todayFortune {
                    FortuneCardView(fortune: fortune)
                        .padding(.horizontal, AppLayout.pagePadding)
                }

                // 筛选摘要
                if cardVM.hasActiveFilters {
                    HStack {
                        Image(systemName: "line.3.horizontal.decrease.circle.fill")
                            .foregroundStyle(AppColors.warmOrange)
                        Text(cardVM.filterSummary)
                            .font(AppFonts.caption)
                            .foregroundStyle(.secondary)
                        Spacer()
                        Button("清除") {
                            withAnimation(AppAnimations.bouncy) { cardVM.resetFilters() }
                        }
                        .font(AppFonts.captionBold)
                        .foregroundStyle(AppColors.warmCoral)
                    }
                    .padding(.horizontal, AppLayout.pagePadding)
                    .transition(.opacity.combined(with: .move(edge: .top)))
                }

                // 抽卡区域
                VStack(spacing: 16) {
                    // 卡牌背面 — matchedGeometry source
                    if !showCardResult {
                        CardBackView()
                            .matchedGeometryEffect(id: "cardHero", in: cardNamespace)
                            .padding(.horizontal, AppLayout.pagePadding)
                            .onTapGesture {
                                if pref.hapticsEnabled { HapticsManager.longPress() }
                                startDraw()
                            }
                            .onLongPressGesture(minimumDuration: 0.3) {
                                if pref.hapticsEnabled { HapticsManager.longPress() }
                                startDraw()
                            }
                    } else {
                        // 占位
                        Color.clear.frame(height: 380)
                    }

                    // 按钮行
                    HStack(spacing: 12) {
                        Button {
                            showFilter = true
                        } label: {
                            Label("筛选", systemImage: "slider.horizontal.3")
                                .font(AppFonts.bodyMedium)
                                .foregroundStyle(AppColors.warmBrown)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 14)
                                .background(
                                    RoundedRectangle(cornerRadius: AppLayout.smallCorner, style: .continuous)
                                        .fill(AppColors.warmCream)
                                )
                        }

                        DrawCardButton {
                            startDraw()
                        }
                    }
                    .padding(.horizontal, AppLayout.pagePadding)
                }

                // 今日记录速览
                if !recordVM.todayRecords.isEmpty {
                    todayRecordsSection
                }

                // 上瘾警告
                if let warning = recordVM.addictionWarning() {
                    warningBanner(warning)
                }
            }
            .padding(.vertical, AppLayout.pagePadding)
        }
        .background(AppColors.pageBg.ignoresSafeArea())
        .animation(AppAnimations.pageTransition, value: cardVM.hasActiveFilters)
    }

    // MARK: - 今日记录

    private var todayRecordsSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("今日已选")
                .font(AppFonts.sectionTitle)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 10) {
                    ForEach(recordVM.todayRecords) { record in
                        VStack(spacing: 4) {
                            Text(record.emoji)
                                .font(.title2)
                            Text(record.foodName)
                                .font(AppFonts.tiny)
                                .lineLimit(1)
                        }
                        .frame(width: 64)
                        .padding(.vertical, 8)
                        .background(
                            RoundedRectangle(cornerRadius: AppLayout.tinyCorner, style: .continuous)
                                .fill(AppColors.warmCream)
                        )
                    }
                }
            }
        }
        .padding(.horizontal, AppLayout.pagePadding)
    }

    private func warningBanner(_ warning: String) -> some View {
        HStack {
            Image(systemName: "exclamationmark.triangle.fill")
                .foregroundStyle(.yellow)
            Text(warning)
                .font(AppFonts.caption)
        }
        .padding(12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: AppLayout.tinyCorner, style: .continuous)
                .fill(.yellow.opacity(0.1))
        )
        .padding(.horizontal, AppLayout.pagePadding)
    }

    // MARK: - 抽卡结果全屏

    private var cardResultSheet: some View {
        ZStack {
            AppColors.pageBg.ignoresSafeArea()

            if let food = cardVM.currentFood {
                CardResultView(
                    food: food,
                    drawCount: cardVM.drawCount,
                    isFlipped: $cardVM.isCardFlipped,
                    hapticsEnabled: pref.hapticsEnabled,
                    onConfirm: {
                        if let confirmed = cardVM.confirmSelection() {
                            recordVM.addRecord(food: confirmed)
                        }
                        showCardResult = false
                        cardVM.resetRound()
                        recordVM.refreshAll()
                    },
                    onReject: {
                        if pref.hapticsEnabled { HapticsManager.rejectCard() }
                        cardVM.rejectAndDrawNext(
                            blacklist: pref.blacklistSet,
                            favoriteCuisines: pref.favoriteCuisineEnums,
                            fortune: fortuneVM.todayFortune,
                            fortuneEnabled: pref.fortuneEnabled
                        )
                    },
                    onDismiss: {
                        showCardResult = false
                        cardVM.resetRound()
                    }
                )
                .matchedGeometryEffect(id: "cardHero", in: cardNamespace)
            }
        }
    }

    // MARK: - Actions

    private func startDraw() {
        cardVM.drawCard(
            blacklist: pref.blacklistSet,
            favoriteCuisines: pref.favoriteCuisineEnums,
            fortune: fortuneVM.todayFortune,
            fortuneEnabled: pref.fortuneEnabled
        )
        if cardVM.currentFood != nil {
            withAnimation(AppAnimations.pageTransition) {
                showCardResult = true
            }
        }
    }
}

#Preview {
    HomeView()
        .modelContainer(for: [MealRecord.self, UserPreference.self], inMemory: true)
}
