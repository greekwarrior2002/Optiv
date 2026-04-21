import SwiftUI

struct TodayView: View {
    let readiness: ReadinessSnapshot?
    let latestResponse: PerformanceQuestionnaireResponse?
    let recentSessions: [WorkoutSession]
    let onStartWorkout: () -> Void
    let onQuestionnaire: () -> Void
    let onEditQuestionnaire: (PerformanceQuestionnaireResponse) -> Void

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 12) {
                    card {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Optiv")
                                .font(.title2.weight(.bold))
                            Text("Fast logging for real training sessions.")
                                .font(.subheadline)
                                .foregroundStyle(OptivTheme.textSecondary)
                            Button("Start Workout ▶️") { onStartWorkout() }
                                .buttonStyle(.borderedProminent)
                        }
                    }

                    card {
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Text("Readiness")
                                    .font(.headline)
                                Spacer()
                                Text(readiness.map { "\($0.score)/100" } ?? "--")
                                    .font(.headline)
                                    .foregroundStyle(OptivTheme.accent)
                            }
                            Text(readiness?.notes ?? "Complete questionnaire to generate readiness.")
                                .font(.subheadline)
                                .foregroundStyle(OptivTheme.textSecondary)
                        }
                    }

                    card {
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Text("Quick Questionnaire")
                                    .font(.headline)
                                Spacer()
                                if let latestResponse {
                                    Button("Edit") { onEditQuestionnaire(latestResponse) }
                                }
                            }
                            Text(latestResponse == nil ? "No response yet today." : "Last response: \(latestResponse!.timestamp.formatted(date: .abbreviated, time: .shortened))")
                                .font(.subheadline)
                                .foregroundStyle(OptivTheme.textSecondary)
                            Button("Open Questionnaire 🧠") { onQuestionnaire() }
                                .buttonStyle(.bordered)
                        }
                    }

                    card {
                        VStack(alignment: .leading, spacing: 6) {
                            Text("Recent Workouts")
                                .font(.headline)
                            if recentSessions.isEmpty {
                                Text("Start your first session.")
                                    .font(.subheadline)
                                    .foregroundStyle(OptivTheme.textSecondary)
                            } else {
                                ForEach(recentSessions) { session in
                                    HStack {
                                        Text(session.sessionType.label)
                                        Spacer()
                                        Text(session.startedAt.formatted(date: .abbreviated, time: .shortened))
                                            .font(.caption)
                                            .foregroundStyle(OptivTheme.textTertiary)
                                    }
                                }
                            }
                        }
                    }
                }
                .padding(12)
            }
            .background(OptivTheme.background.ignoresSafeArea())
            .toolbar {
                ToolbarItem(placement: .principal) { Text("Today").font(.headline) }
            }
        }
    }

    private func card<Content: View>(@ViewBuilder _ content: () -> Content) -> some View {
        content()
            .foregroundStyle(OptivTheme.textPrimary)
            .padding(12)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(RoundedRectangle(cornerRadius: 14).fill(OptivTheme.card))
    }
}
