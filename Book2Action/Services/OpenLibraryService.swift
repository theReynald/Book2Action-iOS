import Foundation

struct OpenLibraryBook: Identifiable, Hashable, Sendable {
    var id: String        // OL key
    var title: String
    var author: String
    var coverImageUrl: URL?
}

enum OpenLibraryService {
    private static let endpoint = URL(string: "https://openlibrary.org/search.json")!

    /// Typeahead-style search. Returns up to 8 results.
    static func search(query rawQuery: String) async -> [OpenLibraryBook] {
        let query = rawQuery.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !query.isEmpty else { return [] }

        var components = URLComponents(url: endpoint, resolvingAgainstBaseURL: false)!
        if let match = try? /^author:\s*(.+)$/.wholeMatch(in: query) {
            components.queryItems = [URLQueryItem(name: "author", value: String(match.output.1))]
        } else {
            components.queryItems = [URLQueryItem(name: "q", value: query)]
        }
        components.queryItems?.append(contentsOf: [
            URLQueryItem(name: "limit", value: "8"),
            URLQueryItem(name: "fields", value: "key,title,author_name,cover_i")
        ])
        guard let url = components.url else { return [] }

        var request = URLRequest(url: url)
        request.timeoutInterval = 15
        request.setValue("Book2Action/1.0", forHTTPHeaderField: "User-Agent")

        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            guard (response as? HTTPURLResponse)?.statusCode == 200 else { return [] }
            let decoded = try JSONDecoder().decode(SearchResponse.self, from: data)
            return decoded.docs.map { doc in
                let cover = doc.cover_i.flatMap { id in
                    URL(string: "https://covers.openlibrary.org/b/id/\(id)-M.jpg")
                }
                return OpenLibraryBook(
                    id: doc.key,
                    title: doc.title ?? "Untitled",
                    author: (doc.author_name ?? []).joined(separator: ", ").isEmpty
                        ? "Unknown Author"
                        : (doc.author_name ?? []).joined(separator: ", "),
                    coverImageUrl: cover
                )
            }
        } catch {
            return []
        }
    }

    private struct SearchResponse: Decodable {
        var docs: [Doc]
    }
    private struct Doc: Decodable {
        var key: String
        var title: String?
        var author_name: [String]?
        var cover_i: Int?
    }
}
