import Foundation
import SwiftData

@MainActor
final class WorkoutSessionRepository {
    private let context: ModelContext

    init(context: ModelContext) { self.context = context }

    func createSession(type: WorkoutSessionType) throws -> WorkoutSession {
        let session = WorkoutSession(startedAt: Date(), type: type)
        context.insert(session)
        try context.save()
        return session
    }

    func fetchRecent(limit: Int = 30) throws -> [WorkoutSession] {
        var descriptor = FetchDescriptor<WorkoutSession>(sortBy: [SortDescriptor(\.startedAt, order: .reverse)])
        descriptor.fetchLimit = limit
        return try context.fetch(descriptor)
    }
}

@MainActor
final class PerformanceQuestionnaireRepository {
    private let context: ModelContext

    init(context: ModelContext) { self.context = context }

    func latest() throws -> PerformanceQuestionnaireResponse? {
        var descriptor = FetchDescriptor<PerformanceQuestionnaireResponse>(sortBy: [SortDescriptor(\.timestamp, order: .reverse)])
        descriptor.fetchLimit = 1
        return try context.fetch(descriptor).first
    }

    func saveResponse(existing: PerformanceQuestionnaireResponse?, session: WorkoutSession?, isSkipped: Bool, sleepQuality: SleepQualityOption?, energyLevel: EnergyLevelOption?, soreness: MuscleSorenessOption?, stress: StressLevelOption?, nutrition: NutritionStatusOption?, caffeine: CaffeineIntakeOption?) throws -> PerformanceQuestionnaireResponse {
        let response = existing ?? PerformanceQuestionnaireResponse(timestamp: Date(), isSkipped: isSkipped)
        response.timestamp = Date()
        response.isSkipped = isSkipped
        response.sleepQuality = sleepQuality
        response.energyLevel = energyLevel
        response.soreness = soreness
        response.stress = stress
        response.nutrition = nutrition
        response.caffeine = caffeine

        if let session {
            response.session = session
            session.questionnaireResponse = response
        }

        if existing == nil { context.insert(response) }
        try context.save()
        return response
    }
}

@MainActor
final class ReadinessRepository {
    private let context: ModelContext

    init(context: ModelContext) { self.context = context }

    func saveOrUpdate(_ snapshot: ReadinessSnapshot) throws {
        let dayStart = Calendar.current.startOfDay(for: snapshot.date)
        let dayEnd = Calendar.current.date(byAdding: .day, value: 1, to: dayStart) ?? dayStart
        let predicate = #Predicate<ReadinessSnapshot> { $0.date >= dayStart && $0.date < dayEnd }
        let descriptor = FetchDescriptor<ReadinessSnapshot>(predicate: predicate)

        if let existing = try context.fetch(descriptor).first {
            existing.score = snapshot.score
            existing.trend = snapshot.trend
            existing.sleepContribution = snapshot.sleepContribution
            existing.recoveryContribution = snapshot.recoveryContribution
            existing.workloadContribution = snapshot.workloadContribution
            existing.questionnaireContribution = snapshot.questionnaireContribution
            existing.notes = snapshot.notes
        } else {
            context.insert(snapshot)
        }
        try context.save()
    }
}
