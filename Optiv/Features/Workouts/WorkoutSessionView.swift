import SwiftUI
import SwiftData

struct WorkoutSessionView: View {
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss

    let session: WorkoutSession
    let onFinished: () -> Void

    @State private var selectedExercise = "Bench Press"
    @State private var restSeconds = 0
    @State private var timer: Timer?

    private let commonExercises = ["Bench Press", "Squat", "Deadlift", "Overhead Press", "Barbell Row", "Pull-up"]

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 12) {
                    sessionHeader
                    strengthCard
                    cardioCard
                    timerCard
                }
                .padding(12)
            }
            .background(OptivTheme.background.ignoresSafeArea())
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Finish") { finishWorkout() }
                }
            }
        }
    }

    private var sessionHeader: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Workout")
                .font(.title3.weight(.bold))
                .foregroundStyle(OptivTheme.textPrimary)
            HStack {
                Text(session.sessionType.label)
                    .foregroundStyle(OptivTheme.textSecondary)
                Spacer()
                Text(session.startedAt.formatted(date: .abbreviated, time: .shortened))
                    .foregroundStyle(OptivTheme.textTertiary)
            }
            Text(session.questionnaireResponse == nil ? "Questionnaire skipped" : "Questionnaire linked")
                .font(.caption)
                .foregroundStyle(session.questionnaireResponse == nil ? .orange : .green)
        }
        .padding(12)
        .background(RoundedRectangle(cornerRadius: 14).fill(OptivTheme.card))
    }

    private var strengthCard: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Strength 💪")
                .font(.headline)
                .foregroundStyle(OptivTheme.textPrimary)

            Picker("Exercise", selection: $selectedExercise) {
                ForEach(commonExercises, id: \.self) { exercise in
                    Text(exercise).tag(exercise)
                }
            }
            .pickerStyle(.menu)

            HStack {
                Button("Add Exercise ➕") { addExercise() }
                Spacer()
                Button("Complete Set ✅") { completeSet() }
            }

            ForEach(session.exercises.sorted(by: { $0.orderIndex < $1.orderIndex })) { exercise in
                VStack(alignment: .leading, spacing: 2) {
                    Text(exercise.name).foregroundStyle(OptivTheme.textPrimary)
                    Text("\(exercise.completedSetCount)/\(exercise.sets.count) sets")
                        .font(.caption)
                        .foregroundStyle(OptivTheme.textTertiary)
                }
            }
        }
        .padding(12)
        .background(RoundedRectangle(cornerRadius: 14).fill(OptivTheme.card))
    }

    private var cardioCard: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Cardio 🏃‍♂️")
                .font(.headline)
                .foregroundStyle(OptivTheme.textPrimary)
            Button("Add 20-minute run") {
                let entry = CardioEntry(modality: .run, durationMinutes: 20, distanceKm: 3.2, calories: 180, averageHeartRate: 142)
                entry.session = session
                session.cardioEntries.append(entry)
                try? context.save()
            }
            ForEach(session.cardioEntries) { entry in
                Text("\(entry.modality.label) • \(entry.durationMinutes) min")
                    .font(.caption)
                    .foregroundStyle(OptivTheme.textSecondary)
            }
        }
        .padding(12)
        .background(RoundedRectangle(cornerRadius: 14).fill(OptivTheme.card))
    }

    private var timerCard: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Timer ⏱️")
                .font(.headline)
                .foregroundStyle(OptivTheme.textPrimary)
            Text("\(restSeconds)s")
                .font(.title.bold())
                .monospacedDigit()
                .foregroundStyle(OptivTheme.textPrimary)
            HStack {
                Button("Start 90s") { startRestTimer() }
                Button("Stop") { stopRestTimer() }
            }
        }
        .padding(12)
        .background(RoundedRectangle(cornerRadius: 14).fill(OptivTheme.card))
    }

    private func addExercise() {
        let exercise = WorkoutExercise(name: selectedExercise, category: "Strength", orderIndex: session.exercises.count)
        let templateSet = session.exercises.last?.sets.last
        let reps = templateSet?.reps ?? 8
        let weight = templateSet?.weightKg ?? 40
        let rest = templateSet?.restSeconds ?? 90
        exercise.sets = [WorkoutSet(reps: reps, weightKg: weight, restSeconds: rest), WorkoutSet(reps: reps, weightKg: weight, restSeconds: rest), WorkoutSet(reps: reps, weightKg: weight, restSeconds: rest)]
        exercise.session = session
        session.exercises.append(exercise)
        try? context.save()
    }

    private func completeSet() {
        for exercise in session.exercises {
            if let set = exercise.sets.first(where: { !$0.isCompleted }) {
                set.isCompleted = true
                set.completedAt = Date()
                let best = exercise.sets.filter { $0.id != set.id && $0.reps == set.reps }.map(\.weightKg).max() ?? 0
                set.isPersonalRecord = set.weightKg > best
                if set.isPersonalRecord { session.notes = "PR Achieved 🏆" }
                startRestTimer(seconds: set.restSeconds)
                try? context.save()
                return
            }
        }
    }

    private func startRestTimer(seconds: Int = 90) {
        stopRestTimer()
        restSeconds = seconds
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { timer in
            if restSeconds > 0 {
                restSeconds -= 1
            } else {
                timer.invalidate()
            }
        }
    }

    private func stopRestTimer() {
        timer?.invalidate()
        timer = nil
    }

    private func finishWorkout() {
        stopRestTimer()
        session.endedAt = Date()
        session.isCompleted = true
        session.updatedAt = Date()
        try? context.save()
        onFinished()
        dismiss()
    }
}
