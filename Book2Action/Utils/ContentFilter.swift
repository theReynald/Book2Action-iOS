import Foundation

enum ContentFilter {
    private static let inappropriate: [String] = [
        "f*ck", "fuck", "shit", "damn", " ass ", "bitch", "crap"
    ]

    static func isAppropriate(_ title: String) -> Bool {
        let normalized = " " + title.lowercased() + " "
        return !inappropriate.contains { normalized.contains($0) }
    }
}
