import XCTest
@testable import Book2Action

final class CoverImageTests: XCTestCase {
    func testPrimaryUsesISBN() {
        let url = CoverImage.primaryURL(isbn: "9780735211292", title: "Atomic Habits")
        XCTAssertEqual(url?.absoluteString, "https://covers.openlibrary.org/b/isbn/9780735211292-L.jpg?default=false")
    }

    func testPrimaryFallsBackToTitle() {
        let url = CoverImage.primaryURL(isbn: nil, title: "Atomic Habits")
        XCTAssertNotNil(url)
        XCTAssertTrue(url!.absoluteString.contains("/b/title/"))
    }

    func testFallbackOrder() {
        let urls = CoverImage.fallbackURLs(isbn: "9780735211292", title: "Atomic Habits")
        XCTAssertEqual(urls.count, 3)
        XCTAssertTrue(urls[0].absoluteString.contains("covers.openlibrary.org"))
        XCTAssertTrue(urls[1].absoluteString.contains("books.google.com"))
        XCTAssertTrue(urls[2].absoluteString.contains("/b/title/"))
    }
}
