import Foundation

struct ReadinessService {
    func calculate(date: Date, sessions: [WorkoutSession], response: PerformanceQuestionnaireResponse?, previous: ReadinessSnapshot?) -> ReadinessSnapshot {
        let sleepContribution = weighted(value: response?.sleepQuality?.scoreValue, max: 4, weight: 30)
        let recoveryContribution = weighted(value: response?.energyLevel?.scoreValue, max: 3, weight: 25)

        let recent = Array(sessions.filter { $0.isCompleted }.prefix(5))
        let avgVolume = recent.isEmpty ? 0 : recent.reduce(0) { $0 + $1.totalVolume } / Double(recent.count)
        let normalized = min(1.0, avgVolume / 5000.0)
        let workloadContribution = Int((1.0 - abs(0.65 - normalized)) * 25)

        let questionnaireValues = [response?.sleepQuality?.scoreValue, response?.energyLevel?.scoreValue, response?.soreness?.scoreValue, response?.stress?.scoreValue, response?.nutrition?.scoreValue, response?.caffeine?.scoreValue].compactMap { $0 }
        let questionnaireContribution = questionnaireValues.isEmpty ? 0 : Int((Double(questionnaireValues.reduce(0, +)) / 21.0) * 20)

        let score = min(100, max(0, sleepContribution + recoveryContribution + workloadContribution + questionnaireContribution))
        let trend: ReadinessTrend
        if let previous {
            trend = score > previous.score + 3 ? .improving : (score < previous.score - 3 ? .declining : .stable)
        } else {
            trend = .stable
        }

        let notes: String
        switch score {
        case 75...: notes = "High readiness. Push quality top sets."
        case 55..<75: notes = "Moderate readiness. Train hard with controlled volume."
        default: notes = "Lower readiness. Focus technique and recovery."
        }

        return ReadinessSnapshot(date: date, score: score, trend: trend, sleepContribution: sleepContribution, recoveryContribution: recoveryContribution, workloadContribution: workloadContribution, questionnaireContribution: questionnaireContribution, notes: notes)
    }

    private func weighted(value: Int?, max: Int, weight: Int) -> Int {
        guard let value else { return 0 }
        return Int((Double(value) / Double(max)) * Double(weight))
    }
}
