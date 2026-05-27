import Foundation

struct OpenLibraryBook: Identifiable, Hashable, Sendable {
    var id: String        // OL work key, e.g. "/works/OL12345W"
    var title: String
    var author: String
    var coverImageUrl: URL?
}

/// Verified ground-truth metadata pulled from OpenLibrary for a specific work.
/// Used to enrich the OpenAI prompt so the model can analyze obscure or
/// recently-published books it wouldn't otherwise recognize.
struct BookEnrichment: Sendable {
    var description: String?
    var subjects: [String]
    var firstPublishYear: Int?
    /// Verbatim chapter list from OpenLibrary's `table_of_contents` field.
    /// Empty when the work record doesn't include one (common for older or
    /// less-cataloged works). When non-empty, this is treated as authoritative
    /// by the OpenAI prompt for chapter citations.
    var tableOfContents: [String] = []
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

    /// Fetches the full work record for a key like `/works/OL12345W`. Returns
    /// `nil` if the request fails — enrichment is best-effort and the caller
    /// should fall back to a plain title/author prompt.
    static func fetchWorkDetails(workKey: String) async -> BookEnrichment? {
        let key = workKey.hasPrefix("/") ? workKey : "/\(workKey)"
        guard let url = URL(string: "https://openlibrary.org\(key).json") else { return nil }

        var request = URLRequest(url: url)
        request.timeoutInterval = 15
        request.setValue("Book2Action/1.0", forHTTPHeaderField: "User-Agent")

        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            guard (response as? HTTPURLResponse)?.statusCode == 200 else { return nil }
            let work = try JSONDecoder().decode(WorkResponse.self, from: data)

            let description: String? = {
                switch work.description {
                case .some(.string(let s)):
                    let trimmed = s.trimmingCharacters(in: .whitespacesAndNewlines)
                    return trimmed.isEmpty ? nil : trimmed
                case .some(.object(let obj)):
                    let trimmed = obj.value.trimmingCharacters(in: .whitespacesAndNewlines)
                    return trimmed.isEmpty ? nil : trimmed
                case .none:
                    return nil
                }
            }()

            let year: Int? = {
                guard let raw = work.first_publish_date else { return nil }
                // OpenLibrary returns things like "1985", "March 1985", or "1985-03-15".
                if let match = try? /(\d{4})/.firstMatch(in: raw) {
                    return Int(match.output.1)
                }
                return nil
            }()

            return BookEnrichment(
                description: description,
                subjects: work.subjects ?? [],
                firstPublishYear: year,
                tableOfContents: (work.table_of_contents ?? []).compactMap { $0.displayString }
            )
        } catch {
            return nil
        }
    }

    private struct WorkResponse: Decodable {
        var description: DescriptionField?
        var subjects: [String]?
        var first_publish_date: String?
        var table_of_contents: [TOCEntry]?
    }

    /// OpenLibrary's `table_of_contents` entries are objects with a mix of
    /// `title`, `label`, and `level` fields. We only need a human-readable
    /// string per chapter — prefer the title, fall back to label-only if
    /// title is missing. Sub-entries (level > 0) are filtered out so the
    /// prompt only sees top-level chapters.
    private struct TOCEntry: Decodable {
        var title: String?
        var label: String?
        var level: Int?

        var displayString: String? {
            if let level, level > 0 { return nil }
            let t = title?.trimmingCharacters(in: .whitespacesAndNewlines)
            let l = label?.trimmingCharacters(in: .whitespacesAndNewlines)
            let titleClean = (t?.isEmpty == false) ? t : nil
            let labelClean = (l?.isEmpty == false) ? l : nil
            switch (titleClean, labelClean) {
            case let (.some(title), .some(label)):
                if title.lowercased().hasPrefix(label.lowercased()) { return title }
                return "\(label). \(title)"
            case let (.some(title), .none):
                return title
            case let (.none, .some(label)):
                return label
            case (.none, .none):
                return nil
            }
        }
    }

    /// OpenLibrary returns `description` as either a plain string or an object
    /// `{ "type": "/type/text", "value": "..." }` depending on the record.
    private enum DescriptionField: Decodable {
        case string(String)
        case object(DescriptionObject)

        init(from decoder: Decoder) throws {
            let container = try decoder.singleValueContainer()
            if let s = try? container.decode(String.self) {
                self = .string(s)
            } else {
                self = .object(try container.decode(DescriptionObject.self))
            }
        }
    }

    private struct DescriptionObject: Decodable {
        var value: String
    }
}
