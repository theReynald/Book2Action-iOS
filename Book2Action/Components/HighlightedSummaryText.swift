import SwiftUI

/// Renders `text` and, while SpeechManager is reading the same string, paints
/// the current sentence with a yellow background. Falls back to plain text
/// when nothing is playing or another string is being spoken.
struct HighlightedSummaryText: View {
    let text: String
    @State private var speech = SpeechManager.shared
    @State private var sentenceRanges: [NSRange] = []

    var body: some View {
        Text(attributed)
            .font(.body)
            .lineSpacing(4)
            .multilineTextAlignment(.leading)
            .fixedSize(horizontal: false, vertical: true)
            .onAppear { recomputeSentencesIfNeeded() }
            .onChange(of: text) { _, _ in recomputeSentencesIfNeeded(force: true) }
    }

    private var attributed: AttributedString {
        var attr = AttributedString(text)
        guard speech.currentText == text,
              let word = speech.currentRange,
              let sentenceNS = sentence(containing: word.location),
              let attrRange = Range(sentenceNS, in: attr) else {
            return attr
        }
        attr[attrRange].backgroundColor = .yellow.opacity(0.45)
        return attr
    }

    private func sentence(containing location: Int) -> NSRange? {
        sentenceRanges.first { NSLocationInRange(location, $0) }
    }

    private func recomputeSentencesIfNeeded(force: Bool = false) {
        if !force && !sentenceRanges.isEmpty { return }
        var ranges: [NSRange] = []
        text.enumerateSubstrings(
            in: text.startIndex..<text.endIndex,
            options: .bySentences
        ) { _, range, _, _ in
            ranges.append(NSRange(range, in: text))
        }
        sentenceRanges = ranges
    }
}
