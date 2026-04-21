import SwiftUI

struct WorkoutsTabView: View {
    let sessions: [WorkoutSession]
    let onStartWorkout: () -> Void
    let onRepeatLastWorkout: () -> Void

    var body: some View {
        NavigationStack {
            VStack(spacing: 10) {
                HStack {
                    Button("Start Workout ▶️") { onStartWorkout() }
                        .buttonStyle(.borderedProminent)
                    Button("Repeat Last") { onRepeatLastWorkout() }
                        .buttonStyle(.bordered)
                }
                .padding(.top, 8)

                List {
                    ForEach(sessions) { session in
                        VStack(alignment: .leading, spacing: 2) {
                            Text(session.sessionType.label)
                            Text("\(session.exercises.count) exercises • \(Int(session.totalVolume)) kg")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
            }
            .padding(.horizontal, 12)
            .background(OptivTheme.background.ignoresSafeArea())
            .toolbar { ToolbarItem(placement: .principal) { Text("Workouts") } }
        }
    }
}
