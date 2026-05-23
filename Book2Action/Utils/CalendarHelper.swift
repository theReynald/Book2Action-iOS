import EventKit
import Foundation

enum CalendarHelper {
    /// Returns the next occurrence (1–7 days ahead) of the given weekday name.
    static func nextOccurrence(of weekdayName: String, calendar: Calendar = .current) -> Date {
        let names = ["sunday", "monday", "tuesday", "wednesday", "thursday", "friday", "saturday"]
        guard let idx = names.firstIndex(of: weekdayName.lowercased()) else { return Date() }
        let targetWeekday = idx + 1 // Calendar weekdays are 1...7 starting Sunday

        var components = DateComponents()
        components.weekday = targetWeekday
        components.hour = 9
        components.minute = 0

        let now = Date()
        // matchNextTime returns the next date at or after `now` matching components.
        // If today already matches and is past 9am, push forward a week.
        if let next = calendar.nextDate(after: now, matching: components, matchingPolicy: .nextTime) {
            return next
        }
        return now
    }

    static func requestAccess() async -> Bool {
        let store = EKEventStore()
        do {
            if #available(iOS 17.0, *) {
                return try await store.requestFullAccessToEvents()
            } else {
                return try await store.requestAccess(to: .event)
            }
        } catch {
            return false
        }
    }

    /// Adds a single event to the default calendar. Returns the saved event identifier.
    @discardableResult
    static func addEvent(
        title: String,
        notes: String,
        start: Date,
        durationMinutes: Int = 60
    ) async throws -> String {
        let store = EKEventStore()
        guard await requestAccess() else {
            throw NSError(
                domain: "CalendarHelper", code: 1,
                userInfo: [NSLocalizedDescriptionKey: "Calendar access was not granted."]
            )
        }
        let event = EKEvent(eventStore: store)
        event.title = title
        event.notes = notes
        event.startDate = start
        event.endDate = start.addingTimeInterval(TimeInterval(durationMinutes * 60))
        event.calendar = store.defaultCalendarForNewEvents
        // 30-minute reminder
        event.addAlarm(EKAlarm(relativeOffset: -30 * 60))
        try store.save(event, span: .thisEvent)
        return event.eventIdentifier
    }
}
