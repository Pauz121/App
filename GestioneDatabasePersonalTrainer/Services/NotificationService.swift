import UserNotifications
import UIKit

final class NotificationService {
    static let shared = NotificationService()
    private init() {}

    func requestPermission() async -> Bool {
        let center = UNUserNotificationCenter.current()
        let settings = await center.notificationSettings()
        if settings.authorizationStatus == .authorized { return true }
        if settings.authorizationStatus == .denied { return false }
        return (try? await center.requestAuthorization(options: [.alert, .badge, .sound])) ?? false
    }

    func scheduleWorkoutPlanExpiry(clientName: String, endDate: Date, daysBefore: Int) {
        guard let triggerDate = Calendar.current.date(byAdding: .day, value: -daysBefore, to: endDate),
              triggerDate > Date() else { return }
        let center = UNUserNotificationCenter.current()
        let safeClientName = clientName.replacingOccurrences(of: " ", with: "_")
        let id = "plan_expiry_\(safeClientName)_\(daysBefore)"
        center.removePendingNotificationRequests(withIdentifiers: [id])
        let content = UNMutableNotificationContent()
        content.title = "Scheda in scadenza"
        content.body = "La scheda di \(clientName) terminerà tra \(daysBefore == 1 ? "1 giorno" : "\(daysBefore) giorni")."
        content.sound = .default
        var components = Calendar.current.dateComponents([.year, .month, .day], from: triggerDate)
        components.hour = 9
        components.minute = 0
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
        center.add(UNNotificationRequest(identifier: id, content: content, trigger: trigger))
    }

    func scheduleClientPlanExpiry(planID: UUID, endDate: Date, daysBefore: Int = 3) {
        guard let triggerDate = Calendar.current.date(byAdding: .day, value: -daysBefore, to: endDate),
              triggerDate > Date() else { return }
        let center = UNUserNotificationCenter.current()
        let id = "client_plan_expiry_\(planID.uuidString)"
        center.removePendingNotificationRequests(withIdentifiers: [id])
        let content = UNMutableNotificationContent()
        content.title = "La tua scheda sta per terminare"
        content.body = "La tua scheda terminerà tra \(daysBefore == 1 ? "1 giorno" : "\(daysBefore) giorni"). Contatta il trainer per aggiornarla."
        content.sound = .default
        var components = Calendar.current.dateComponents([.year, .month, .day], from: triggerDate)
        components.hour = 9
        components.minute = 0
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
        center.add(UNNotificationRequest(identifier: id, content: content, trigger: trigger))
    }

    func cancelPlanNotifications(planID: UUID, clientName: String) {
        let center = UNUserNotificationCenter.current()
        let safeClientName = clientName.replacingOccurrences(of: " ", with: "_")
        let trainerIds = [1, 3, 5, 7].map { "plan_expiry_\(safeClientName)_\($0)" }
        let clientId = "client_plan_expiry_\(planID.uuidString)"
        center.removePendingNotificationRequests(withIdentifiers: trainerIds + [clientId])
    }
}
