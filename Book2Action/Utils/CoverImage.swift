import Foundation

enum CoverImage {
    /// Primary cover URL, mirroring the original mobile app's behavior
    /// (ISBN preferred, title fallback).
    static func primaryURL(isbn: String?, title: String?) -> URL? {
        if let isbn, isbn.count >= 10 {
            return URL(string: "https://covers.openlibrary.org/b/isbn/\(isbn)-L.jpg")
        }
        if let title, !title.isEmpty,
           let encoded = title.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) {
            return URL(string: "https://covers.openlibrary.org/b/title/\(encoded)-L.jpg")
        }
        return nil
    }

    /// Ordered list of fallback URLs to try if the primary fails.
    static func fallbackURLs(isbn: String?, title: String?) -> [URL] {
        var out: [URL] = []
        if let isbn, !isbn.isEmpty {
            if let u = URL(string: "https://covers.openlibrary.org/b/isbn/\(isbn)-L.jpg") {
                out.append(u)
            }
            if let u = URL(string: "https://books.google.com/books/content?id=ISBN:\(isbn)&printsec=frontcover&img=1&zoom=1&source=gbs_api") {
                out.append(u)
            }
        }
        if let title,
           let encoded = title.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) {
            if let u = URL(string: "https://covers.openlibrary.org/b/title/\(encoded)-L.jpg") {
                out.append(u)
            }
        }
        return out
    }
}
