import SwiftUI

struct HomeView: View {
    @State private var cardVM = CardViewModel()
    @State private var fortuneVM = FortuneViewModel()
    @State private var selectedTab = 0

    var body: some View {
        TabView(selection: $selectedTab) {
            // 首页 — 今日食运 + 抽卡入口
            NavigationStack {
                VStack {
                    Text("今天吃什么")
                        .font(.largeTitle.bold())
                    Spacer()
                }
                .navigationTitle("Ewhat")
            }
            .tabItem {
                Label("首页", systemImage: "house.fill")
            }
            .tag(0)

            // 记录页
            NavigationStack {
                RecordView()
            }
            .tabItem {
                Label("记录", systemImage: "calendar")
            }
            .tag(1)

            // 设置页
            NavigationStack {
                SettingsView()
            }
            .tabItem {
                Label("设置", systemImage: "gearshape.fill")
            }
            .tag(2)
        }
    }
}

#Preview {
    HomeView()
}
