import XCTest
@testable import Book2Action

final class BundledBooksTests: XCTestCase {
    func testMatchesAtomicHabits() {
        let b = BundledBooks.match("Atomic Habits")
        XCTAssertNotNil(b)
        XCTAssertEqual(b?.title, "Atomic Habits")
        XCTAssertEqual(b?.actionableSteps.count, 7)
        XCTAssertEqual(b?.actionableSteps.first?.day, "Monday")
    }

    func testMatchesIsCaseInsensitiveAndPartial() {
        XCTAssertNotNil(BundledBooks.match("atomic"))
        XCTAssertNotNil(BundledBooks.match("THINK and grow rich"))
    }

    func testReturnsNilForUnknown() {
        XCTAssertNil(BundledBooks.match("zzz unknown book zzz"))
    }
}
