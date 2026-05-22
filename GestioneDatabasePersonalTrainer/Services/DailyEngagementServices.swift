import Foundation

@MainActor
final class DailyCheckInService {
    private let database: MockDatabase
    private let supabase: SupabaseManager
    private var localCheckIns: [DailyCheckIn] = []

    init(database: MockDatabase, supabase: SupabaseManager) {
        self.database = database
        self.supabase = supabase
    }

    func fetchTodayCheckIn(clientId: UUID) async -> DailyCheckIn? {
        await fetchCheckInsForClient(clientId: clientId, from: Date(), to: Date()).first
    }

    func createOrUpdateTodayCheckIn(_ checkIn: DailyCheckIn) async throws -> DailyCheckIn {
        if AppConfiguration.isSupabaseConfigured {
            let existing = await fetchTodayCheckIn(clientId: checkIn.clientID)
            if let existing {
                var updateValue = checkIn
                updateValue.id = existing.id
                let rows: [DailyCheckInDTO] = try await supabase.update("daily_checkins", filters: [
                    URLQueryItem(name: "id", value: "eq.\(existing.id.uuidString)")
                ], value: SupabaseMapper.dailyCheckInDTO(from: updateValue))
                return rows.first.map(SupabaseMapper.dailyCheckIn) ?? updateValue
            }

            let rows: [DailyCheckInDTO] = try await supabase.insert("daily_checkins", value: SupabaseMapper.dailyCheckInDTO(from: checkIn))
            return rows.first.map(SupabaseMapper.dailyCheckIn) ?? checkIn
        }

        localCheckIns.removeAll {
            $0.clientID == checkIn.clientID && Calendar.current.isDate($0.checkinDate, inSameDayAs: checkIn.checkinDate)
        }
        localCheckIns.append(checkIn)
        return checkIn
    }

    func fetchCheckInsForClient(clientId: UUID, from startDate: Date? = nil, to endDate: Date? = nil) async -> [DailyCheckIn] {
        guard AppConfiguration.isSupabaseConfigured else {
            return localCheckIns
                .filter { $0.clientID == clientId && matches($0.checkinDate, from: startDate, to: endDate) }
                .sorted { $0.checkinDate > $1.checkinDate }
        }

        var queryItems = [
            URLQueryItem(name: "select", value: "*"),
            URLQueryItem(name: "client_id", value: "eq.\(clientId.uuidString)"),
            URLQueryItem(name: "order", value: "checkin_date.desc")
        ]
        if let startDate {
            queryItems.append(URLQueryItem(name: "checkin_date", value: "gte.\(SupabaseMapper.formatDate(startDate))"))
        }
        if let endDate {
            queryItems.append(URLQueryItem(name: "checkin_date", value: "lte.\(SupabaseMapper.formatDate(endDate))"))
        }

        let rows: [DailyCheckInDTO] = (try? await supabase.select("daily_checkins", queryItems: queryItems)) ?? []
        return rows.map(SupabaseMapper.dailyCheckIn)
    }

    func fetchMissingCheckInsForTrainer(trainerID: UUID, clients: [Client]) async -> [Client] {
        let today = SupabaseMapper.formatDate(Date())
        guard AppConfiguration.isSupabaseConfigured else {
            return clients.filter { client in
                !localCheckIns.contains { $0.clientID == client.id && Calendar.current.isDateInToday($0.checkinDate) }
            }
        }

        let rows: [DailyCheckInDTO] = (try? await supabase.select("daily_checkins", queryItems: [
            URLQueryItem(name: "select", value: "*"),
            URLQueryItem(name: "trainer_id", value: "eq.\(trainerID.uuidString)"),
            URLQueryItem(name: "checkin_date", value: "eq.\(today)")
        ])) ?? []
        let completedIDs = Set(rows.map(\.clientId))
        return clients.filter { !completedIDs.contains($0.id) }
    }

    private func matches(_ date: Date, from startDate: Date?, to endDate: Date?) -> Bool {
        if let startDate, date < Calendar.current.startOfDay(for: startDate) { return false }
        if let endDate {
            let end = Calendar.current.date(byAdding: .day, value: 1, to: Calendar.current.startOfDay(for: endDate)) ?? endDate
            if date >= end { return false }
        }
        return true
    }
}

@MainActor
final class DailyGoalsService {
    private let supabase: SupabaseManager
    private var localGoals: [DailyGoal] = []

    init(supabase: SupabaseManager) {
        self.supabase = supabase
    }

    func fetchTodayGoals(clientId: UUID) async -> [DailyGoal] {
        guard AppConfiguration.isSupabaseConfigured else {
            return localGoals.filter { $0.clientID == clientId && Calendar.current.isDateInToday($0.goalDate) }
        }

        let rows: [DailyGoalDTO] = (try? await supabase.select("daily_goals", queryItems: [
            URLQueryItem(name: "select", value: "*"),
            URLQueryItem(name: "client_id", value: "eq.\(clientId.uuidString)"),
            URLQueryItem(name: "goal_date", value: "eq.\(SupabaseMapper.formatDate(Date()))"),
            URLQueryItem(name: "order", value: "created_at.asc")
        ])) ?? []
        return rows.map(SupabaseMapper.dailyGoal)
    }

    func updateGoalProgress(_ goal: DailyGoal, currentValue: Double) async -> DailyGoal {
        var updated = goal
        updated.currentValue = currentValue
        if let target = goal.targetValue {
            updated.isCompleted = currentValue >= target
        }
        return await save(updated)
    }

    func markGoalCompleted(_ goal: DailyGoal) async -> DailyGoal {
        var updated = goal
        updated.isCompleted = true
        if updated.currentValue == nil {
            updated.currentValue = updated.targetValue
        }
        return await save(updated)
    }

    func createGoalForClient(_ goal: DailyGoal) async -> DailyGoal {
        await save(goal)
    }

    private func save(_ goal: DailyGoal) async -> DailyGoal {
        guard AppConfiguration.isSupabaseConfigured else {
            localGoals.removeAll { $0.id == goal.id }
            localGoals.append(goal)
            return goal
        }

        do {
            let dto = SupabaseMapper.dailyGoalDTO(from: goal)
            let existing: [DailyGoalDTO] = try await supabase.select("daily_goals", queryItems: [
                URLQueryItem(name: "select", value: "*"),
                URLQueryItem(name: "id", value: "eq.\(goal.id.uuidString)")
            ])
            if existing.first != nil {
                let rows: [DailyGoalDTO] = try await supabase.update("daily_goals", filters: [
                    URLQueryItem(name: "id", value: "eq.\(goal.id.uuidString)")
                ], value: dto)
                return rows.first.map(SupabaseMapper.dailyGoal) ?? goal
            }

            let rows: [DailyGoalDTO] = try await supabase.insert("daily_goals", value: dto)
            return rows.first.map(SupabaseMapper.dailyGoal) ?? goal
        } catch {
            return goal
        }
    }
}

@MainActor
final class ActivitySummaryService {
    private let supabase: SupabaseManager
    private var localSummaries: [DailyStepSummary] = []

    init(supabase: SupabaseManager) {
        self.supabase = supabase
    }

    func upsertTodayStepSummary(_ summary: DailyStepSummary) async -> DailyStepSummary {
        guard AppConfiguration.isSupabaseConfigured else {
            localSummaries.removeAll {
                $0.clientID == summary.clientID && Calendar.current.isDate($0.summaryDate, inSameDayAs: summary.summaryDate)
            }
            localSummaries.append(summary)
            return summary
        }

        do {
            let today = SupabaseMapper.formatDate(summary.summaryDate)
            let existing: [ActivitySummaryDTO] = try await supabase.select("client_activity_summaries", queryItems: [
                URLQueryItem(name: "select", value: "*"),
                URLQueryItem(name: "client_id", value: "eq.\(summary.clientID.uuidString)"),
                URLQueryItem(name: "summary_date", value: "eq.\(today)")
            ])
            let dto = SupabaseMapper.activitySummaryDTO(from: summary)
            if let row = existing.first, let id = row.id {
                let rows: [ActivitySummaryDTO] = try await supabase.update("client_activity_summaries", filters: [
                    URLQueryItem(name: "id", value: "eq.\(id.uuidString)")
                ], value: dto)
                return rows.first.map(SupabaseMapper.activitySummary) ?? summary
            }

            let rows: [ActivitySummaryDTO] = try await supabase.insert("client_activity_summaries", value: dto)
            return rows.first.map(SupabaseMapper.activitySummary) ?? summary
        } catch {
            return summary
        }
    }

    func fetchLast7DaysActivity(clientId: UUID) async -> [DailyStepSummary] {
        let start = Calendar.current.date(byAdding: .day, value: -6, to: Calendar.current.startOfDay(for: Date())) ?? Date()
        guard AppConfiguration.isSupabaseConfigured else {
            return localSummaries
                .filter { $0.clientID == clientId && $0.summaryDate >= start }
                .sorted { $0.summaryDate < $1.summaryDate }
        }

        let rows: [ActivitySummaryDTO] = (try? await supabase.select("client_activity_summaries", queryItems: [
            URLQueryItem(name: "select", value: "*"),
            URLQueryItem(name: "client_id", value: "eq.\(clientId.uuidString)"),
            URLQueryItem(name: "summary_date", value: "gte.\(SupabaseMapper.formatDate(start))"),
            URLQueryItem(name: "order", value: "summary_date.asc")
        ])) ?? []
        return rows.map(SupabaseMapper.activitySummary)
    }

    func fetchClientActivityForTrainer(trainerID: UUID) async -> [DailyStepSummary] {
        guard AppConfiguration.isSupabaseConfigured else {
            return localSummaries.filter { $0.trainerID == trainerID }
        }

        let rows: [ActivitySummaryDTO] = (try? await supabase.select("client_activity_summaries", queryItems: [
            URLQueryItem(name: "select", value: "*"),
            URLQueryItem(name: "trainer_id", value: "eq.\(trainerID.uuidString)"),
            URLQueryItem(name: "summary_date", value: "gte.\(SupabaseMapper.formatDate(Date.daysFromNow(-7)))"),
            URLQueryItem(name: "order", value: "summary_date.desc")
        ])) ?? []
        return rows.map(SupabaseMapper.activitySummary)
    }
}

@MainActor
final class StreakService {
    private let supabase: SupabaseManager
    private var localStreaks: [Streak] = []

    init(supabase: SupabaseManager) {
        self.supabase = supabase
    }

    func fetchClientStreaks(clientId: UUID) async -> [Streak] {
        guard AppConfiguration.isSupabaseConfigured else {
            return localStreaks.filter { $0.clientID == clientId }
        }

        let rows: [StreakDTO] = (try? await supabase.select("client_streaks", queryItems: [
            URLQueryItem(name: "select", value: "*"),
            URLQueryItem(name: "client_id", value: "eq.\(clientId.uuidString)")
        ])) ?? []
        return rows.map(SupabaseMapper.streak)
    }

    func updateCheckInStreak(trainerID: UUID, clientID: UUID, completedAt: Date = Date()) async -> Streak {
        await updateStreak(trainerID: trainerID, clientID: clientID, type: .checkIn, completedAt: completedAt)
    }

    func updateStepsStreak(trainerID: UUID, clientID: UUID, completedAt: Date = Date()) async -> Streak {
        await updateStreak(trainerID: trainerID, clientID: clientID, type: .steps, completedAt: completedAt)
    }

    private func updateStreak(trainerID: UUID, clientID: UUID, type: StreakType, completedAt: Date) async -> Streak {
        let current = await fetchClientStreaks(clientId: clientID).first { $0.streakType == type }
        let updated = nextStreak(from: current, trainerID: trainerID, clientID: clientID, type: type, completedAt: completedAt)

        guard AppConfiguration.isSupabaseConfigured else {
            localStreaks.removeAll { $0.id == updated.id || ($0.clientID == clientID && $0.streakType == type) }
            localStreaks.append(updated)
            return updated
        }

        do {
            let dto = SupabaseMapper.streakDTO(from: updated)
            if current != nil {
                let rows: [StreakDTO] = try await supabase.update("client_streaks", filters: [
                    URLQueryItem(name: "id", value: "eq.\(updated.id.uuidString)")
                ], value: dto)
                return rows.first.map(SupabaseMapper.streak) ?? updated
            }

            let rows: [StreakDTO] = try await supabase.insert("client_streaks", value: dto)
            return rows.first.map(SupabaseMapper.streak) ?? updated
        } catch {
            return updated
        }
    }

    private func nextStreak(from current: Streak?, trainerID: UUID, clientID: UUID, type: StreakType, completedAt: Date) -> Streak {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: completedAt)
        let yesterday = calendar.date(byAdding: .day, value: -1, to: today) ?? today

        if var current {
            let last = current.lastCompletedAt.map { calendar.startOfDay(for: $0) }
            if last == today {
                return current
            }

            let nextCount = last == yesterday ? current.currentCount + 1 : 1
            current.currentCount = nextCount
            current.bestCount = max(current.bestCount, nextCount)
            current.lastCompletedAt = today
            return current
        }

        return Streak(
            id: UUID(),
            trainerID: trainerID,
            clientID: clientID,
            streakType: type,
            currentCount: 1,
            bestCount: 1,
            lastCompletedAt: today,
            createdAt: nil,
            updatedAt: nil
        )
    }
}

@MainActor
final class TrainerInsightsService {
    private let dailyCheckInService: DailyCheckInService
    private let activitySummaryService: ActivitySummaryService
    private let streakService: StreakService

    init(dailyCheckInService: DailyCheckInService, activitySummaryService: ActivitySummaryService, streakService: StreakService) {
        self.dailyCheckInService = dailyCheckInService
        self.activitySummaryService = activitySummaryService
        self.streakService = streakService
    }

    func fetchClientsNeedingAttention(trainerID: UUID, clients: [Client], progressEntries: [ProgressEntry]) async -> [TrainerClientInsight] {
        var insights: [TrainerClientInsight] = []
        let missing = await fetchMissingCheckIns(trainerID: trainerID, clients: clients)
        if !missing.isEmpty {
            insights.append(TrainerClientInsight(
                id: UUID(),
                clientID: nil,
                clientName: "Clienti",
                title: "\(missing.count) check-in mancanti",
                message: "Clienti senza check-in oggi: \(missing.prefix(3).map(\.firstName).joined(separator: ", "))",
                type: .missingCheckIn,
                severity: .warning,
                iconName: "checklist.unchecked"
            ))
        }

        let summaries = await activitySummaryService.fetchClientActivityForTrainer(trainerID: trainerID)
        let todaySummaries = summaries.filter { Calendar.current.isDateInToday($0.summaryDate) }
        let reached = todaySummaries.filter { $0.steps >= $0.stepsGoal }
        for summary in reached.prefix(3) {
            if let client = clients.first(where: { $0.id == summary.clientID }) {
                insights.append(TrainerClientInsight(
                    id: UUID(),
                    clientID: client.id,
                    clientName: client.fullName,
                    title: "\(client.firstName) ha raggiunto \(summary.stepsGoal) passi",
                    message: "\(summary.steps) passi registrati oggi.",
                    type: .stepsReached,
                    severity: .success,
                    iconName: "figure.walk.circle.fill"
                ))
            }
        }

        for client in clients.prefix(8) {
            let clientSummaries = summaries.filter { $0.clientID == client.id }
            let average = clientSummaries.isEmpty ? 0 : clientSummaries.reduce(0) { $0 + $1.steps } / clientSummaries.count
            if average > 0 && average < 4_000 {
                insights.append(TrainerClientInsight(
                    id: UUID(),
                    clientID: client.id,
                    clientName: client.fullName,
                    title: "\(client.firstName) poco attivo",
                    message: "Media recente circa \(average) passi al giorno.",
                    type: .lowActivity,
                    severity: .alert,
                    iconName: "exclamationmark.triangle"
                ))
            }

            if let lastProgress = progressEntries.filter({ $0.clientID == client.id }).sorted(by: { $0.date > $1.date }).first {
                let days = Calendar.current.dateComponents([.day], from: lastProgress.date, to: Date()).day ?? 0
                if days >= 10 {
                    insights.append(TrainerClientInsight(
                        id: UUID(),
                        clientID: client.id,
                        clientName: client.fullName,
                        title: "\(client.firstName) non aggiorna il peso da \(days) giorni",
                        message: "Ultimo progresso: \(lastProgress.date.formattedDay()).",
                        type: .staleProgress,
                        severity: .warning,
                        iconName: "scalemass"
                    ))
                }
            }

            let streaks = await streakService.fetchClientStreaks(clientId: client.id)
            if let best = streaks.max(by: { $0.currentCount < $1.currentCount }), best.currentCount >= 5 {
                insights.append(TrainerClientInsight(
                    id: UUID(),
                    clientID: client.id,
                    clientName: client.fullName,
                    title: "\(client.firstName) ha \(best.currentCount) giorni consecutivi",
                    message: "Serie \(best.streakType.title.lowercased()) attiva.",
                    type: .streak,
                    severity: .success,
                    iconName: "flame.fill"
                ))
            }
        }

        return Array(insights.prefix(8))
    }

    func fetchMissingCheckIns(trainerID: UUID, clients: [Client]) async -> [Client] {
        await dailyCheckInService.fetchMissingCheckInsForTrainer(trainerID: trainerID, clients: clients)
    }

    func fetchActiveClientsSummary(trainerID: UUID, clients: [Client]) async -> [TrainerClientInsight] {
        let summaries = await activitySummaryService.fetchClientActivityForTrainer(trainerID: trainerID)
        let activeIDs = Set(summaries.filter { Calendar.current.isDateInToday($0.summaryDate) || $0.steps > 0 }.map(\.clientID))
        let count = clients.filter { activeIDs.contains($0.id) }.count
        return [
            TrainerClientInsight(
                id: UUID(),
                clientID: nil,
                clientName: "Clienti",
                title: "\(count) clienti attivi",
                message: "Clienti con riepiloghi recenti disponibili.",
                type: .checkInCompleted,
                severity: .info,
                iconName: "person.2.fill"
            )
        ]
    }
}
