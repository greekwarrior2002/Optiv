import Foundation
import SwiftData

@Model
final class PerformanceQuestionnaireResponse {
    var id: UUID
    var timestamp: Date
    var isSkipped: Bool
    var sleepQualityRaw: String?
    var energyLevelRaw: String?
    var sorenessRaw: String?
    var stressRaw: String?
    var nutritionRaw: String?
    var caffeineRaw: String?

    @Relationship(deleteRule: .nullify) var session: WorkoutSession?

    init(timestamp: Date = Date(), isSkipped: Bool = false) {
        self.id = UUID()
        self.timestamp = timestamp
        self.isSkipped = isSkipped
    }

    var sleepQuality: SleepQualityOption? {
        get { sleepQualityRaw.flatMap(SleepQualityOption.init(rawValue:)) }
        set { sleepQualityRaw = newValue?.rawValue }
    }

    var energyLevel: EnergyLevelOption? {
        get { energyLevelRaw.flatMap(EnergyLevelOption.init(rawValue:)) }
        set { energyLevelRaw = newValue?.rawValue }
    }

    var soreness: MuscleSorenessOption? {
        get { sorenessRaw.flatMap(MuscleSorenessOption.init(rawValue:)) }
        set { sorenessRaw = newValue?.rawValue }
    }

    var stress: StressLevelOption? {
        get { stressRaw.flatMap(StressLevelOption.init(rawValue:)) }
        set { stressRaw = newValue?.rawValue }
    }

    var nutrition: NutritionStatusOption? {
        get { nutritionRaw.flatMap(NutritionStatusOption.init(rawValue:)) }
        set { nutritionRaw = newValue?.rawValue }
    }

    var caffeine: CaffeineIntakeOption? {
        get { caffeineRaw.flatMap(CaffeineIntakeOption.init(rawValue:)) }
        set { caffeineRaw = newValue?.rawValue }
    }

    var completionRatio: Double {
        let values: [String?] = [sleepQualityRaw, energyLevelRaw, sorenessRaw, stressRaw, nutritionRaw, caffeineRaw]
        let completed = values.compactMap { $0 }.count
        return Double(completed) / Double(values.count)
    }
}

@Model
final class ReadinessSnapshot {
    var id: UUID
    var date: Date
    var score: Int
    var trendRaw: String
    var sleepContribution: Int
    var recoveryContribution: Int
    var workloadContribution: Int
    var questionnaireContribution: Int
    var notes: String

    init(date: Date = Date(), score: Int, trend: ReadinessTrend, sleepContribution: Int, recoveryContribution: Int, workloadContribution: Int, questionnaireContribution: Int, notes: String = "") {
        self.id = UUID()
        self.date = Calendar.current.startOfDay(for: date)
        self.score = score
        self.trendRaw = trend.rawValue
        self.sleepContribution = sleepContribution
        self.recoveryContribution = recoveryContribution
        self.workloadContribution = workloadContribution
        self.questionnaireContribution = questionnaireContribution
        self.notes = notes
    }

    var trend: ReadinessTrend {
        get { ReadinessTrend(rawValue: trendRaw) ?? .stable }
        set { trendRaw = newValue.rawValue }
    }
}

enum ReadinessTrend: String, Codable {
    case improving
    case stable
    case declining

    var label: String {
        switch self {
        case .improving: return "Up"
        case .stable: return "Stable"
        case .declining: return "Down"
        }
    }
}

protocol QuestionnaireOption: CaseIterable, Identifiable {
    var title: String { get }
    var emoji: String { get }
    var scoreValue: Int { get }
}

enum SleepQualityOption: String, Codable, QuestionnaireOption {
    case poor, okay, good, great

    var id: String { rawValue }

    var title: String {
        switch self {
        case .poor: return "Poor"
        case .okay: return "Okay"
        case .good: return "Good"
        case .great: return "Great"
        }
    }

    var emoji: String {
        switch self {
        case .poor: return "😵‍💫"
        case .okay: return "😐"
        case .good: return "🙂"
        case .great: return "🔥"
        }
    }

    var scoreValue: Int { [.poor: 1, .okay: 2, .good: 3, .great: 4][self] ?? 1 }
}

enum EnergyLevelOption: String, Codable, QuestionnaireOption {
    case low, medium, high

    var id: String { rawValue }
    var title: String { rawValue.capitalized }

    var emoji: String {
        switch self {
        case .low: return "🪫"
        case .medium: return "🙂"
        case .high: return "🚀"
        }
    }

    var scoreValue: Int { [.low: 1, .medium: 2, .high: 3][self] ?? 1 }
}

enum MuscleSorenessOption: String, Codable, QuestionnaireOption {
    case none, mild, moderate, severe

    var id: String { rawValue }
    var title: String { rawValue.capitalized }

    var emoji: String {
        switch self {
        case .none: return "😄"
        case .mild: return "🙂"
        case .moderate: return "😬"
        case .severe: return "🥵"
        }
    }

    var scoreValue: Int { [.none: 4, .mild: 3, .moderate: 2, .severe: 1][self] ?? 1 }
}

enum StressLevelOption: String, Codable, QuestionnaireOption {
    case low, medium, high

    var id: String { rawValue }
    var title: String { rawValue.capitalized }

    var emoji: String {
        switch self {
        case .low: return "😌"
        case .medium: return "😐"
        case .high: return "😰"
        }
    }

    var scoreValue: Int { [.low: 3, .medium: 2, .high: 1][self] ?? 1 }
}

enum NutritionStatusOption: String, Codable, QuestionnaireOption {
    case fasted
    case lightMeal
    case fullMeal

    var id: String { rawValue }

    var title: String {
        switch self {
        case .fasted: return "Fasted"
        case .lightMeal: return "Light Meal"
        case .fullMeal: return "Full Meal"
        }
    }

    var emoji: String {
        switch self {
        case .fasted: return "🕒"
        case .lightMeal: return "🥪"
        case .fullMeal: return "🍗"
        }
    }

    var scoreValue: Int { [.fasted: 1, .lightMeal: 2, .fullMeal: 3][self] ?? 1 }
}

enum CaffeineIntakeOption: String, Codable, QuestionnaireOption {
    case none, low, moderate, high

    var id: String { rawValue }
    var title: String { rawValue.capitalized }

    var emoji: String {
        switch self {
        case .none: return "❌"
        case .low: return "☕️"
        case .moderate: return "⚡️"
        case .high: return "🚨"
        }
    }

    var scoreValue: Int { [.none: 3, .low: 3, .moderate: 2, .high: 1][self] ?? 1 }
}
