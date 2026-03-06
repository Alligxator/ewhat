import SwiftUI
import SwiftData

/// 设置页面
struct SettingsView: View {
    @Query private var preferences: [UserPreference]
    @Environment(\.modelContext) private var modelContext

    private var preference: UserPreference {
        if let existing = preferences.first {
            return existing
        }
        let newPref = UserPreference()
        modelContext.insert(newPref)
        return newPref
    }

    var body: some View {
        List {
            // 食运设置
            Section("食运") {
                Toggle("食运影响推荐", isOn: Binding(
                    get: { preference.fortuneEnabled },
                    set: { preference.fortuneEnabled = $0 }
                ))
            }

            // 反馈设置
            Section("反馈") {
                Toggle("触觉反馈", isOn: Binding(
                    get: { preference.hapticsEnabled },
                    set: { preference.hapticsEnabled = $0 }
                ))
                Toggle("音效", isOn: Binding(
                    get: { preference.soundEnabled },
                    set: { preference.soundEnabled = $0 }
                ))
            }

            // 黑名单
            Section("饮食偏好") {
                NavigationLink("黑名单管理") {
                    BlacklistView()
                }
            }

            // 关于
            Section("关于") {
                HStack {
                    Text("版本")
                    Spacer()
                    Text("1.0.0")
                        .foregroundStyle(.secondary)
                }
            }
        }
        .navigationTitle("设置")
    }
}
