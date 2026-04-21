import SwiftUI

struct InsightsTabView: View {
    let sessions: [WorkoutSession]
    let responses: [PerformanceQuestionnaireResponse]
    let readiness: [ReadinessSnapshot]

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 12) {
                    card {
                        Text("Performance insights")
                            .font(.headline)
                        if findings.isEmpty {
                            Text("Log more training days to unlock stronger correlations.")
                                .font(.subheadline)
                                .foregroundStyle(OptivTheme.textSecondary)
                        } else {
                            ForEach(findings, id: \.self) { finding in
                                Text("• \(finding)")
                                    .font(.subheadline)
                            }
                        }
                    }

                    card {
                        Text("Readiness Trend")
                            .font(.headline)
                        ForEach(Array(readiness.prefix(7))) { snap in
                            HStack {
                                Text(snap.date.formatted(date: .abbreviated, time: .omitted))
                                Spacer()
                                Text("\(snap.score)")
                                    .foregroundStyle(OptivTheme.accent)
                            }
                            .font(.subheadline)
                        }
                    }
                }
                .padding(12)
            }
            .background(OptivTheme.background.ignoresSafeArea())
            .toolbar { ToolbarItem(placement: .principal) { Text("Insights 🧠") } }
        }
    }

    private var findings: [String] {
        PerformanceCorrelationEngine().makeFindings(sessions: sessions, responses: responses)
    }

    private func card<Content: View>(@ViewBuilder _ content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 8) { content() }
            .padding(12)
            .frame(maxWidth: .infinity, alignment: .leading)
            .foregroundStyle(OptivTheme.textPrimary)
            .background(RoundedRectangle(cornerRadius: 14).fill(OptivTheme.card))
    }
}
