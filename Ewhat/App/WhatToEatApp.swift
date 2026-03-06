import SwiftUI
import SwiftData

@main
struct WhatToEatApp: App {
    var body: some Scene {
        WindowGroup {
            HomeView()
        }
        .modelContainer(for: [MealRecord.self, UserPreference.self])
    }
}
