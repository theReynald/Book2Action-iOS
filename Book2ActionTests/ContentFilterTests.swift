import XCTest
@testable import Book2Action

final class ContentFilterTests: XCTestCase {
    func testAllowsCleanTitle() {
        XCTAssertTrue(ContentFilter.isAppropriate("Atomic Habits"))
        XCTAssertTrue(ContentFilter.isAppropriate("The Power of Now"))
    }

    func testBlocksProfanity() {
        XCTAssertFalse(ContentFilter.isAppropriate("The Subtle Art of not giving a fuck"))
        XCTAssertFalse(ContentFilter.isAppropriate("BITCH planet"))
    }

    func testIsCaseInsensitive() {
        XCTAssertFalse(ContentFilter.isAppropriate("Fuck Yeah"))
    }
}
