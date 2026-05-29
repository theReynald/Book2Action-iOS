import EventKit
import Foundation

enum CalendarHelper {
    /// Result of a successful calendar save. `sourceTitle` is the EKSource
    /// title (e.g. "iCloud", "Google", "Exchange", "On My iPhone"); used to
    /// tell the user which calendar account the event landed in.
    struct SaveResult {
        let eventIdentifier: String
        let sourceTitle: String
        let calendarTitle: String
        let start: Date
    }

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

    /// Adds a single event to the default calendar. Returns the saved event
    /// identifier plus the source/calendar names so callers can tell the user
    /// which account (e.g. Google vs iCloud) actually received the event.
    @discardableResult
    static func addEvent(
        title: String,
        notes: String,
        start: Date,
        durationMinutes: Int = 60
    ) async throws -> SaveResult {
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
        guard let target = store.defaultCalendarForNewEvents else {
            throw NSError(
                domain: "CalendarHelper", code: 2,
                userInfo: [NSLocalizedDescriptionKey: "No default calendar configured."]
            )
        }
        event.calendar = target
        // 30-minute reminder
        event.addAlarm(EKAlarm(relativeOffset: -30 * 60))
        try store.save(event, span: .thisEvent)
        return SaveResult(
            eventIdentifier: event.eventIdentifier,
            sourceTitle: target.source?.title ?? "Calendar",
            calendarTitle: target.title,
            start: start
        )
    }

    /// User-facing toast for a successful save, e.g.
    /// "Added to Google Calendar · Mon, Jun 1 at 9:00 AM".
    static func toastMessage(for result: SaveResult) -> String {
        let account = friendlySource(result.sourceTitle)
        let df = DateFormatter()
        df.dateFormat = "EEE, MMM d 'at' h:mm a"
        return "Added to \(account) · \(df.string(from: result.start))"
    }

    private static func friendlySource(_ raw: String) -> String {
        let lower = raw.lowercased()
        if lower.contains("google") || lower.contains("gmail") { return "Google Calendar" }
        if lower.contains("icloud") { return "iCloud Calendar" }
        if lower.contains("exchange") || lower.contains("outlook") { return "Outlook Calendar" }
        if lower.contains("yahoo") { return "Yahoo Calendar" }
        if lower == "local" || lower.contains("on my") { return "On-Device Calendar" }
        return "\(raw) Calendar"
    }
}
