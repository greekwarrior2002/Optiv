import SwiftUI
import SwiftData

struct QuickPerformanceQuestionnaireView: View {
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss

    let existingResponse: PerformanceQuestionnaireResponse?
    let session: WorkoutSession?
    let onSaved: () -> Void

    @State private var sleepQuality: SleepQualityOption?
    @State private var energyLevel: EnergyLevelOption?
    @State private var soreness: MuscleSorenessOption?
    @State private var stress: StressLevelOption?
    @State private var nutrition: NutritionStatusOption?
    @State private var caffeine: CaffeineIntakeOption?

    init(existingResponse: PerformanceQuestionnaireResponse?, session: WorkoutSession?, onSaved: @escaping () -> Void) {
        self.existingResponse = existingResponse
        self.session = session
        self.onSaved = onSaved
        _sleepQuality = State(initialValue: existingResponse?.sleepQuality)
        _energyLevel = State(initialValue: existingResponse?.energyLevel)
        _soreness = State(initialValue: existingResponse?.soreness)
        _stress = State(initialValue: existingResponse?.stress)
        _nutrition = State(initialValue: existingResponse?.nutrition)
        _caffeine = State(initialValue: existingResponse?.caffeine)
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 10) {
                section("1. Sleep Quality 😴", options: SleepQualityOption.allCases, selection: $sleepQuality)
                section("2. Energy Level ⚡️", options: EnergyLevelOption.allCases, selection: $energyLevel)
                section("3. Muscle Soreness 💪", options: MuscleSorenessOption.allCases, selection: $soreness)
                section("4. Stress Level 🧠", options: StressLevelOption.allCases, selection: $stress)
                section("5. Nutrition Status 🍽️", options: NutritionStatusOption.allCases, selection: $nutrition)
                section("6. Caffeine Intake ☕️", options: CaffeineIntakeOption.allCases, selection: $caffeine)
            }
            .padding(12)
            .background(OptivTheme.background.ignoresSafeArea())
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Skip") { save(skip: true) }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Submit") { save(skip: false) }
                }
            }
        }
    }

    private func section<T: QuestionnaireOption>(_ title: String, options: [T], selection: Binding<T?>) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(OptivTheme.textPrimary)
            FlowLayout(spacing: 8) {
                ForEach(options) { option in
                    BubbleButton(
                        title: "\(option.title) \(option.emoji)",
                        isSelected: Binding(
                            get: { selection.wrappedValue?.id == option.id },
                            set: { isSelected in selection.wrappedValue = isSelected ? option : nil }
                        )
                    )
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(10)
        .background(RoundedRectangle(cornerRadius: 14).fill(OptivTheme.card))
    }

    private func save(skip: Bool) {
        let repo = PerformanceQuestionnaireRepository(context: context)
        do {
            _ = try repo.saveResponse(existing: existingResponse, session: session, isSkipped: skip, sleepQuality: sleepQuality, energyLevel: energyLevel, soreness: soreness, stress: stress, nutrition: nutrition, caffeine: caffeine)
            onSaved()
            dismiss()
        } catch {
            dismiss()
        }
    }
}
