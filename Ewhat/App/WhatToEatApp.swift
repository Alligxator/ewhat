import SwiftUI
import SwiftData

@main
struct WhatToEatApp: App {
    @AppStorage("colorSchemePreference") private var colorSchemePreference = 0

    var body: some Scene {
        WindowGroup {
            HomeView()
                .preferredColorScheme(
                    colorSchemePreference == 1 ? .light :
                    colorSchemePreference == 2 ? .dark : nil
                )
        }
        .modelContainer(for: [MealRecord.self, UserPreference.self])
    }
}
