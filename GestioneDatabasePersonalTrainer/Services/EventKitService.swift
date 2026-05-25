import EventKit
import UIKit

@MainActor
final class EventKitService {
    static let shared = EventKitService()
    private let store = EKEventStore()
    private init() {}

    private var isAuthorized: Bool {
        if #available(iOS 17, *) {
            return EKEventStore.authorizationStatus(for: .event) == .fullAccess
        } else {
            return EKEventStore.authorizationStatus(for: .event) == .authorized
        }
    }

    func requestAccess() async -> Bool {
        if isAuthorized { return true }
        let status = EKEventStore.authorizationStatus(for: .event)
        guard status == .notDetermined else { return false }
        if #available(iOS 17, *) {
            return (try? await store.requestFullAccessToEvents()) ?? false
        } else {
            return await withCheckedContinuation { continuation in
                store.requestAccess(to: .event) { granted, _ in
                    continuation.resume(returning: granted)
                }
            }
        }
    }

    func addAppointment(_ appointment: Appointment, clientName: String) async -> Bool {
        guard await requestAccess() else { return false }
        let event = EKEvent(eventStore: store)
        event.title = "\(appointment.sessionType.displayName) — \(clientName)"
        event.startDate = appointment.startTime
        event.endDate = appointment.endTime
        event.calendar = store.defaultCalendarForNewEvents
        if !appointment.notes.isEmpty { event.notes = appointment.notes }
        return (try? store.save(event, span: .thisEvent)) != nil
    }
}
