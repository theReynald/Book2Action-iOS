import Foundation

/// Hand-curated table-of-contents fallback for popular non-fiction titles
/// where OpenLibrary's `table_of_contents` field is empty or missing.
///
/// Used by `OpenAIService.generateBookAnalysis` to ground the model's chapter
/// citations when the live enrichment doesn't include one. Keys are matched
/// on a loose normalized form of the title (lowercased, punctuation stripped)
/// so common variants like "The 4-Hour Workweek" / "4 Hour Workweek" all hit.
enum BundledTableOfContents {
    /// Returns the bundled ToC for `title` if available, otherwise `nil`.
    static func lookup(title: String) -> [String]? {
        let key = normalize(title)
        return entries[key]
    }

    private static func normalize(_ raw: String) -> String {
        let lowered = raw.lowercased()
        let stripped = lowered.unicodeScalars.filter { scalar in
            CharacterSet.alphanumerics.contains(scalar) || scalar == " "
        }
        let collapsed = String(String.UnicodeScalarView(stripped))
            .replacingOccurrences(of: "  ", with: " ")
            .trimmingCharacters(in: .whitespaces)
        return collapsed
    }

    /// Title (normalized) → verbatim chapter list. Keep entries in publication
    /// order. Each entry should be the full "Chapter N: Title" string the UI
    /// will display.
    ///
    /// Intentionally empty by default — the primary chapter-grounding path is
    /// OpenLibrary's `table_of_contents` field, with a dedicated OpenAI call
    /// as a second fallback. This map exists only for cases where both of
    /// those fail repeatedly for a specific high-traffic title.
    private static let entries: [String: [String]] = [:]
}
