import Foundation
import SwiftData

@Model
final class WorkoutSession {
    var id: UUID
    var createdAt: Date
    var updatedAt: Date
    var startedAt: Date
    var endedAt: Date?
    var notes: String
    var isCompleted: Bool
    var sessionTypeRaw: String

    @Relationship(deleteRule: .cascade) var exercises: [WorkoutExercise]
    @Relationship(deleteRule: .cascade) var cardioEntries: [CardioEntry]
    @Relationship(deleteRule: .nullify) var questionnaireResponse: PerformanceQuestionnaireResponse?

    init(startedAt: Date = Date(), type: WorkoutSessionType = .strength) {
        self.id = UUID()
        self.createdAt = Date()
        self.updatedAt = Date()
        self.startedAt = startedAt
        self.endedAt = nil
        self.notes = ""
        self.isCompleted = false
        self.sessionTypeRaw = type.rawValue
        self.exercises = []
        self.cardioEntries = []
    }

    var sessionType: WorkoutSessionType {
        get { WorkoutSessionType(rawValue: sessionTypeRaw) ?? .strength }
        set { sessionTypeRaw = newValue.rawValue }
    }

    var totalVolume: Double {
        exercises
            .flatMap(\.sets)
            .filter { $0.isCompleted }
            .reduce(0) { $0 + (Double($1.reps) * $1.weightKg) }
    }
}

@Model
final class WorkoutExercise {
    var id: UUID
    var name: String
    var category: String
    var orderIndex: Int
    var createdAt: Date
    var updatedAt: Date

    @Relationship(deleteRule: .cascade) var sets: [WorkoutSet]
    @Relationship(deleteRule: .nullify) var session: WorkoutSession?

    init(name: String, category: String = "Strength", orderIndex: Int = 0) {
        self.id = UUID()
        self.name = name
        self.category = category
        self.orderIndex = orderIndex
        self.createdAt = Date()
        self.updatedAt = Date()
        self.sets = []
    }

    var completedSetCount: Int {
        sets.filter { $0.isCompleted }.count
    }
}

@Model
final class WorkoutSet {
    var id: UUID
    var reps: Int
    var weightKg: Double
    var restSeconds: Int
    var rpe: Int?
    var notes: String
    var isCompleted: Bool
    var completedAt: Date?
    var isPersonalRecord: Bool
    var createdAt: Date

    @Relationship(deleteRule: .nullify) var exercise: WorkoutExercise?

    init(reps: Int = 8, weightKg: Double = 20, restSeconds: Int = 90, rpe: Int? = nil, notes: String = "") {
        self.id = UUID()
        self.reps = reps
        self.weightKg = weightKg
        self.restSeconds = restSeconds
        self.rpe = rpe
        self.notes = notes
        self.isCompleted = false
        self.completedAt = nil
        self.isPersonalRecord = false
        self.createdAt = Date()
    }
}

@Model
final class CardioEntry {
    var id: UUID
    var modalityRaw: String
    var durationMinutes: Int
    var distanceKm: Double?
    var calories: Int?
    var averageHeartRate: Double?
    var createdAt: Date

    @Relationship(deleteRule: .nullify) var session: WorkoutSession?

    init(modality: CardioModality, durationMinutes: Int, distanceKm: Double? = nil, calories: Int? = nil, averageHeartRate: Double? = nil) {
        self.id = UUID()
        self.modalityRaw = modality.rawValue
        self.durationMinutes = durationMinutes
        self.distanceKm = distanceKm
        self.calories = calories
        self.averageHeartRate = averageHeartRate
        self.createdAt = Date()
    }

    var modality: CardioModality {
        get { CardioModality(rawValue: modalityRaw) ?? .run }
        set { modalityRaw = newValue.rawValue }
    }
}

@Model
final class ExerciseTemplate {
    var id: UUID
    var name: String
    var defaultReps: Int
    var defaultWeightKg: Double
    var defaultRestSeconds: Int
    var isFavorite: Bool
    var lastUsedAt: Date?

    init(name: String, defaultReps: Int = 8, defaultWeightKg: Double = 20, defaultRestSeconds: Int = 90, isFavorite: Bool = false) {
        self.id = UUID()
        self.name = name
        self.defaultReps = defaultReps
        self.defaultWeightKg = defaultWeightKg
        self.defaultRestSeconds = defaultRestSeconds
        self.isFavorite = isFavorite
    }
}

@Model
final class WorkoutTemplate {
    var id: UUID
    var name: String
    @Attribute(.externalStorage) var exerciseNamesData: Data?
    var createdAt: Date
    var lastUsedAt: Date?

    init(name: String, exerciseNames: [String] = []) {
        self.id = UUID()
        self.name = name
        self.exerciseNamesData = try? JSONEncoder().encode(exerciseNames)
        self.createdAt = Date()
    }

    var exerciseNames: [String] {
        get {
            guard let exerciseNamesData else { return [] }
            return (try? JSONDecoder().decode([String].self, from: exerciseNamesData)) ?? []
        }
        set {
            exerciseNamesData = try? JSONEncoder().encode(newValue)
        }
    }
}

enum WorkoutSessionType: String, Codable, CaseIterable, Identifiable {
    case strength
    case cardio
    case hybrid

    var id: String { rawValue }

    var label: String {
        switch self {
        case .strength: return "Strength 💪"
        case .cardio: return "Cardio 🏃‍♂️"
        case .hybrid: return "Hybrid ⚙️"
        }
    }
}

enum CardioModality: String, Codable, CaseIterable, Identifiable {
    case run
    case bike
    case row
    case walk
    case hiit

    var id: String { rawValue }

    var label: String {
        switch self {
        case .run: return "Run"
        case .bike: return "Bike"
        case .row: return "Row"
        case .walk: return "Walk"
        case .hiit: return "HIIT"
        }
    }
}
