import XCTest
@testable import Book2Action

final class AmazonLinksTests: XCTestCase {
    func testUsesISBNWhenPresent() {
        let url = AmazonLinks.searchURL(title: "Atomic Habits", author: "James Clear", isbn: "9780735211292")
        XCTAssertNotNil(url)
        XCTAssertTrue(url!.absoluteString.contains("9780735211292"))
    }

    func testFallsBackToTitleAndAuthor() {
        let url = AmazonLinks.searchURL(title: "Atomic Habits", author: "James Clear", isbn: nil)
        XCTAssertNotNil(url)
        XCTAssertTrue(url!.absoluteString.lowercased().contains("atomic%20habits") ||
                      url!.absoluteString.lowercased().contains("atomic+habits"))
    }
}
