import Foundation
import HealthKit

@MainActor
final class HealthKitPerformanceService: ObservableObject {
    static let shared = HealthKitPerformanceService()

    private let store = HKHealthStore()

    private init() {}

    var isAvailable: Bool { HKHealthStore.isHealthDataAvailable() }

    func requestAuthorization() async throws {
        guard isAvailable else { return }

        var readTypes = Set<HKObjectType>()
        if let sleep = HKObjectType.categoryType(forIdentifier: .sleepAnalysis) { readTypes.insert(sleep) }
        if let hrv = HKObjectType.quantityType(forIdentifier: .heartRateVariabilitySDNN) { readTypes.insert(hrv) }
        if let hr = HKObjectType.quantityType(forIdentifier: .restingHeartRate) { readTypes.insert(hr) }
        if let steps = HKObjectType.quantityType(forIdentifier: .stepCount) { readTypes.insert(steps) }

        try await store.requestAuthorization(toShare: [], read: readTypes)
    }
}
