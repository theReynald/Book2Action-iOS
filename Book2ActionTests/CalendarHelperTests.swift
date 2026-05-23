import XCTest
@testable import Book2Action

final class CalendarHelperTests: XCTestCase {
    func testNextOccurrenceIsInFuture() {
        let next = CalendarHelper.nextOccurrence(of: "Monday")
        XCTAssertGreaterThanOrEqual(next.timeIntervalSinceNow, -60) // within tolerance for same-minute boundary
        let comps = Calendar.current.dateComponents([.weekday, .hour], from: next)
        XCTAssertEqual(comps.weekday, 2)         // Monday = 2
        XCTAssertEqual(comps.hour, 9)
    }

    func testNextOccurrenceForFriday() {
        let next = CalendarHelper.nextOccurrence(of: "Friday")
        let comps = Calendar.current.dateComponents([.weekday], from: next)
        XCTAssertEqual(comps.weekday, 6)         // Friday = 6
    }
}
