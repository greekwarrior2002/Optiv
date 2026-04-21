import SwiftUI

struct ProgressTabView: View {
    let sessions: [WorkoutSession]

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 12) {
                    metric(title: "Sessions", value: "\(sessions.count)", subtitle: "tracked")
                    metric(title: "Volume", value: "\(Int(sessions.reduce(0) { $0 + $1.totalVolume })) kg", subtitle: "total")
                    metric(title: "Cardio", value: "\(sessions.flatMap(\.cardioEntries).count)", subtitle: "entries")
                }
                .padding(12)
            }
            .background(OptivTheme.background.ignoresSafeArea())
            .toolbar { ToolbarItem(placement: .principal) { Text("Progress 📈") } }
        }
    }

    private func metric(title: String, value: String, subtitle: String) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title).font(.headline)
            Text(value).font(.title3.weight(.bold))
            Text(subtitle).font(.caption).foregroundStyle(OptivTheme.textSecondary)
        }
        .padding(12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(RoundedRectangle(cornerRadius: 14).fill(OptivTheme.card))
        .foregroundStyle(OptivTheme.textPrimary)
    }
}
