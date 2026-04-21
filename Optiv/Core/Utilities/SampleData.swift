import Foundation

enum SampleData {
    static func response() -> PerformanceQuestionnaireResponse {
        let r = PerformanceQuestionnaireResponse(timestamp: Date(), isSkipped: false)
        r.sleepQuality = .good
        r.energyLevel = .high
        r.soreness = .mild
        r.stress = .medium
        r.nutrition = .lightMeal
        r.caffeine = .low
        return r
    }
}
