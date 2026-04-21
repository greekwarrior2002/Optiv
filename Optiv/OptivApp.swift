import SwiftUI
import SwiftData

@main
struct OptivApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .modelContainer(sharedModelContainer)
                .preferredColorScheme(.dark)
        }
    }

    private let sharedModelContainer: ModelContainer = {
        let schema = Schema([
            WorkoutSession.self,
            WorkoutExercise.self,
            WorkoutSet.self,
            CardioEntry.self,
            ExerciseTemplate.self,
            WorkoutTemplate.self,
            PerformanceQuestionnaireResponse.self,
            ReadinessSnapshot.self
        ])

        let config = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false, cloudKitDatabase: .automatic)
        do {
            return try ModelContainer(for: schema, configurations: [config])
        } catch {
            fatalError("Unable to create SwiftData container: \(error)")
        }
    }()
}
