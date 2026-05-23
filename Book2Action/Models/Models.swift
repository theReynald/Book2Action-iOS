import Foundation

struct DetailedStepInfo: Codable, Hashable, Sendable {
    var sentences: [String]
    var keyTakeaway: String
}

struct ActionableStep: Codable, Hashable, Identifiable, Sendable {
    var step: String
    var chapter: String
    var day: String?
    var details: DetailedStepInfo?

    var id: String { (day ?? "") + "|" + step }
}

struct Book: Codable, Hashable, Identifiable, Sendable {
    var title: String
    var author: String
    var summary: String
    var actionableSteps: [ActionableStep]
    var coverImageUrl: String?
    var publishedYear: Int?
    var genre: String?
    var isbn: String?

    var id: String { (isbn ?? title) + "|" + author }
}

struct BookSearchResult: Sendable {
    var success: Bool
    var book: Book?
    var error: String?
}
