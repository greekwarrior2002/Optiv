import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var context
    @Query(sort: \WorkoutSession.startedAt, order: .reverse) private var sessions: [WorkoutSession]
    @Query(sort: \PerformanceQuestionnaireResponse.timestamp, order: .reverse) private var responses: [PerformanceQuestionnaireResponse]
    @Query(sort: \ReadinessSnapshot.date, order: .reverse) private var readiness: [ReadinessSnapshot]

    @State private var selectedTab: Tab = .today
    @State private var workoutSessionToPresent: WorkoutSession?
    @State private var questionnaireSession: WorkoutSession?
    @State private var showStandaloneQuestionnaire = false
    @State private var editingResponse: PerformanceQuestionnaireResponse?

    enum Tab: Hashable {
        case today
        case workouts
        case progress
        case insights
        case settings
    }

    var body: some View {
        TabView(selection: $selectedTab) {
            TodayView(readiness: readinessToday, latestResponse: responses.first, recentSessions: Array(sessions.prefix(4)), onStartWorkout: startWorkout, onQuestionnaire: {
                editingResponse = nil
                showStandaloneQuestionnaire = true
            }, onEditQuestionnaire: { response in
                editingResponse = response
                showStandaloneQuestionnaire = true
            })
            .tag(Tab.today)
            .tabItem { Label("Today", systemImage: "sun.max.fill") }

            WorkoutsTabView(sessions: sessions, onStartWorkout: startWorkout, onRepeatLastWorkout: repeatLastWorkout)
                .tag(Tab.workouts)
                .tabItem { Label("Workouts", systemImage: "dumbbell.fill") }

            ProgressTabView(sessions: sessions)
                .tag(Tab.progress)
                .tabItem { Label("Progress", systemImage: "chart.line.uptrend.xyaxis") }

            InsightsTabView(sessions: sessions, responses: responses, readiness: readiness)
                .tag(Tab.insights)
                .tabItem { Label("Insights", systemImage: "brain") }

            SettingsTabView()
                .tag(Tab.settings)
                .tabItem { Label("Settings", systemImage: "gearshape.fill") }
        }
        .tint(OptivTheme.accent)
        .sheet(item: $questionnaireSession) { session in
            QuickPerformanceQuestionnaireView(existingResponse: session.questionnaireResponse, session: session) {
                refreshReadiness()
                questionnaireSession = nil
                workoutSessionToPresent = session
            }
        }
        .sheet(isPresented: $showStandaloneQuestionnaire) {
            QuickPerformanceQuestionnaireView(existingResponse: editingResponse, session: nil) {
                refreshReadiness()
                showStandaloneQuestionnaire = false
            }
        }
        .sheet(item: $workoutSessionToPresent) { session in
            WorkoutSessionView(session: session) {
                refreshReadiness()
                workoutSessionToPresent = nil
            }
        }
    }

    private var readinessToday: ReadinessSnapshot? {
        readiness.first(where: { Calendar.current.isDateInToday($0.date) })
    }

    private func startWorkout() {
        do {
            let repo = WorkoutSessionRepository(context: context)
            let session = try repo.createSession(type: .strength)
            if needsQuestionnaire() {
                questionnaireSession = session
            } else {
                workoutSessionToPresent = session
            }
        } catch {}
    }

    private func repeatLastWorkout() {
        guard let last = sessions.first else {
            startWorkout()
            return
        }

        let session = WorkoutSession(startedAt: Date(), type: last.sessionType)
        for (idx, exercise) in last.exercises.sorted(by: { $0.orderIndex < $1.orderIndex }).enumerated() {
            let copy = WorkoutExercise(name: exercise.name, category: exercise.category, orderIndex: idx)
            copy.sets = exercise.sets.map { WorkoutSet(reps: $0.reps, weightKg: $0.weightKg, restSeconds: $0.restSeconds, rpe: $0.rpe, notes: $0.notes) }
            session.exercises.append(copy)
        }
        context.insert(session)
        try? context.save()
        questionnaireSession = session
    }

    private func needsQuestionnaire() -> Bool {
        guard let latest = responses.first else { return true }
        return Date().timeIntervalSince(latest.timestamp) > 6 * 60 * 60
    }

    private func refreshReadiness() {
        let service = ReadinessService()
        let snapshot = service.calculate(date: Date(), sessions: sessions, response: responses.first, previous: readiness.first)
        let repo = ReadinessRepository(context: context)
        try? repo.saveOrUpdate(snapshot)
    }
}
