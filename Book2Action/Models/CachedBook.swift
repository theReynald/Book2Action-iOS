import Foundation
import SwiftData

/// A persisted, previously-analyzed `Book`. Used both as a cache (to skip
/// repeat OpenAI calls for the same title) and as the data source for the
/// "Recently viewed" list on Home.
///
/// The encoded `Book` JSON is stored in `bookData` so the model remains
/// stable even if the `Book` struct gains new optional fields.
@Model
final class CachedBook {
    /// Normalized lookup key: lowercased + trimmed `"title|author"`.
    /// Unique so upserts replace by identity.
    @Attribute(.unique) var key: String

    /// Display title, in original casing.
    var title: String
    /// Display author, in original casing.
    var author: String
    /// Optional remote cover URL for quick rendering in lists.
    var coverImageURL: String?
    /// JSON-encoded `Book` payload, decoded on read.
    var bookData: Data
    /// Last time the user opened this book in the app. Drives "Recent" order.
    var lastViewedAt: Date
    /// First time this book was cached.
    var firstCachedAt: Date

    init(
        key: String,
        title: String,
        author: String,
        coverImageURL: String?,
        bookData: Data,
        lastViewedAt: Date = .now,
        firstCachedAt: Date = .now
    ) {
        self.key = key
        self.title = title
        self.author = author
        self.coverImageURL = coverImageURL
        self.bookData = bookData
        self.lastViewedAt = lastViewedAt
        self.firstCachedAt = firstCachedAt
    }

    /// Normalize a title+author pair into a stable cache key.
    static func makeKey(title: String, author: String?) -> String {
        func normalize(_ s: String) -> String {
            s.lowercased()
                .trimmingCharacters(in: .whitespacesAndNewlines)
                .split(whereSeparator: { $0.isWhitespace })
                .joined(separator: " ")
        }
        return "\(normalize(title))|\(normalize(author ?? ""))"
    }
}
