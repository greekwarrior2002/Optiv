import Foundation

struct PerformanceCorrelationEngine {
    func makeFindings(sessions: [WorkoutSession], responses: [PerformanceQuestionnaireResponse]) -> [String] {
        let linked = sessions.compactMap { session -> (WorkoutSession, PerformanceQuestionnaireResponse)? in
            guard let response = responses.first(where: { $0.session?.id == session.id }), !response.isSkipped else { return nil }
            return (session, response)
        }

        guard linked.count >= 4 else { return [] }
        var findings: [String] = []

        let highSleep = linked.filter { ($0.1.sleepQuality?.scoreValue ?? 0) >= 3 }
        let lowSleep = linked.filter { ($0.1.sleepQuality?.scoreValue ?? 0) <= 2 }
        if highSleep.count >= 2 && lowSleep.count >= 2 {
            let high = highSleep.map { $0.0.totalVolume }.reduce(0, +) / Double(highSleep.count)
            let low = lowSleep.map { $0.0.totalVolume }.reduce(0, +) / Double(lowSleep.count)
            if high > low * 1.08 { findings.append("Sleep quality is positively correlating with session volume.") }
        }

        if linked.filter({ $0.1.stress == .high }).count >= 2 {
            findings.append("High stress days show weaker output. Consider a lighter top set plan.")
        }

        if linked.filter({ $0.1.soreness == .severe }).count >= 2 {
            findings.append("Severe soreness is linked to lower session completion consistency.")
        }

        return findings
    }
}
