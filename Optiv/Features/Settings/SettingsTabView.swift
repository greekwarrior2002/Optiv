import SwiftUI

struct SettingsTabView: View {
    var body: some View {
        NavigationStack {
            List {
                Text("Apple Health (Read-only)")
                Text("Cloud Sync: SwiftData + iCloud")
                Text("Questionnaire: one-tap bubbles with haptics")
            }
            .scrollContentBackground(.hidden)
            .background(OptivTheme.background)
            .toolbar { ToolbarItem(placement: .principal) { Text("Settings") } }
        }
    }
}
