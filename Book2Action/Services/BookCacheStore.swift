import Foundation
import SwiftData

/// Thin wrapper around a `ModelContext` that handles the cache + recently-viewed
/// operations Book2Action needs. Kept `@MainActor` because all callers are
/// SwiftUI views or view-driven tasks; this avoids context-isolation friction.
@MainActor
struct BookCacheStore {
    let context: ModelContext

    /// Returns the cached `Book` for the given title/author if present, and
    /// (importantly) bumps `lastViewedAt` so it shows up first in "Recent".
    func lookup(title: String, author: String?) -> Book? {
        let key = CachedBook.makeKey(title: title, author: author)
        guard let entry = fetch(key: key) else { return nil }
        guard let decoded = try? JSONDecoder().decode(Book.self, from: entry.bookData) else {
            // Stale/incompatible payload — drop it so the next call re-caches.
            context.delete(entry)
            try? context.save()
            return nil
        }
        entry.lastViewedAt = .now
        try? context.save()
        return decoded
    }

    /// Insert-or-update the cache entry for `book`. Called after a successful
    /// OpenAI analysis (or a tap that re-opens a bundled/cached book).
    func save(_ book: Book) {
        let key = CachedBook.makeKey(title: book.title, author: book.author)
        guard let data = try? JSONEncoder().encode(book) else { return }
        if let existing = fetch(key: key) {
            existing.title = book.title
            existing.author = book.author
            existing.coverImageURL = book.coverImageUrl
            existing.bookData = data
            existing.lastViewedAt = .now
        } else {
            context.insert(CachedBook(
                key: key,
                title: book.title,
                author: book.author,
                coverImageURL: book.coverImageUrl,
                bookData: data
            ))
        }
        try? context.save()
    }

    /// Remove a single cached book (used by swipe-to-delete on the recent list).
    func remove(_ cached: CachedBook) {
        context.delete(cached)
        try? context.save()
    }

    /// Wipe the cache entirely (exposed in Settings later if desired).
    func clearAll() {
        try? context.delete(model: CachedBook.self)
        try? context.save()
    }

    // MARK: - Private

    private func fetch(key: String) -> CachedBook? {
        var descriptor = FetchDescriptor<CachedBook>(
            predicate: #Predicate { $0.key == key }
        )
        descriptor.fetchLimit = 1
        return (try? context.fetch(descriptor))?.first
    }
}
