import Foundation
import Combine
import HealthKit

enum HealthKitServiceError: LocalizedError {
    case notAvailable
    case stepCountUnavailable
    case authorizationDenied

    var errorDescription: String? {
        switch self {
        case .notAvailable:
            return "HealthKit non e disponibile su questo dispositivo."
        case .stepCountUnavailable:
            return "Il dato passi non e disponibile in Apple Salute."
        case .authorizationDenied:
            return "Permesso HealthKit non concesso."
        }
    }
}

enum HealthKitAuthorizationState: Equatable {
    case unknown
    case unavailable
    case requesting
    case authorized
    case denied(String)
}

final class HealthKitService: ObservableObject {
    @Published private(set) var authorizationState: HealthKitAuthorizationState = .unknown

    private let healthStore = HKHealthStore()
    private let calendar = Calendar.current
    private let defaultStepsGoal = 10_000
    private let localID = UUID(uuidString: "00000000-0000-0000-0000-000000000000")!

    func isHealthKitAvailable() -> Bool {
        HKHealthStore.isHealthDataAvailable()
    }

    @MainActor
    func requestAuthorization() async throws {
        guard isHealthKitAvailable() else {
            authorizationState = .unavailable
            throw HealthKitServiceError.notAvailable
        }
        guard let stepType = HKObjectType.quantityType(forIdentifier: .stepCount) else {
            authorizationState = .denied(HealthKitServiceError.stepCountUnavailable.localizedDescription)
            throw HealthKitServiceError.stepCountUnavailable
        }

        authorizationState = .requesting

        do {
            try await healthStore.requestAuthorization(toShare: Set<HKSampleType>(), read: Set<HKObjectType>([stepType]))
            authorizationState = .authorized
        } catch {
            authorizationState = .denied(error.localizedDescription)
            throw HealthKitServiceError.authorizationDenied
        }
    }

    func fetchTodaySteps() async throws -> Int {
        guard isHealthKitAvailable() else { throw HealthKitServiceError.notAvailable }
        let startOfDay = calendar.startOfDay(for: Date())
        return try await fetchSteps(from: startOfDay, to: Date())
    }

    func fetchStepsLast7Days() async throws -> [DailyStepSummary] {
        guard isHealthKitAvailable() else { throw HealthKitServiceError.notAvailable }
        let today = calendar.startOfDay(for: Date())
        let dates = (0..<7).compactMap { offset in
            calendar.date(byAdding: .day, value: -offset, to: today)
        }.reversed()

        var summaries: [DailyStepSummary] = []
        for date in dates {
            let nextDay = calendar.date(byAdding: .day, value: 1, to: date) ?? date
            let steps = try await fetchSteps(from: date, to: nextDay)
            summaries.append(
                DailyStepSummary(
                    id: UUID(),
                    trainerID: localID,
                    clientID: localID,
                    summaryDate: date,
                    steps: steps,
                    stepsGoal: defaultStepsGoal,
                    source: "healthkit",
                    createdAt: nil,
                    updatedAt: nil
                )
            )
        }
        return summaries
    }

    func fetchWeeklyAverageSteps() async throws -> Double {
        let summaries = try await fetchStepsLast7Days()
        guard !summaries.isEmpty else { return 0 }
        let total = summaries.reduce(0) { $0 + $1.steps }
        return Double(total) / Double(summaries.count)
    }

    private func fetchSteps(from startDate: Date, to endDate: Date) async throws -> Int {
        guard let stepType = HKQuantityType.quantityType(forIdentifier: .stepCount) else {
            throw HealthKitServiceError.stepCountUnavailable
        }

        let predicate = HKQuery.predicateForSamples(withStart: startDate, end: endDate, options: .strictStartDate)

        return try await withCheckedThrowingContinuation { continuation in
            let query = HKStatisticsQuery(quantityType: stepType, quantitySamplePredicate: predicate, options: .cumulativeSum) { _, result, error in
                if let error {
                    continuation.resume(throwing: error)
                    return
                }

                let steps = result?.sumQuantity()?.doubleValue(for: HKUnit.count()) ?? 0
                continuation.resume(returning: Int(steps.rounded()))
            }
            healthStore.execute(query)
        }
    }
}
