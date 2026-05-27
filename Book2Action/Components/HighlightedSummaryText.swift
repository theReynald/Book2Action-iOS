import SwiftUI

/// Renders `text` and, while SpeechManager is reading the same string, paints
/// the current sentence with a yellow background. Falls back to plain text
/// when nothing is playing or another string is being spoken.
///
/// Pass `spokenText` when this view shows only a slice of a longer string
/// that SpeechManager is reading (e.g. the Key Takeaway shown alongside other
/// sections, but spoken together as one utterance). The view will find where
/// `text` lives inside `spokenText` and translate the speech cursor into the
/// slice's local coordinates so the sentence highlight still works.
struct HighlightedSummaryText: View {
    let text: String
    let spokenText: String?
    @State private var speech = SpeechManager.shared
    @State private var sentenceRanges: [NSRange] = []

    init(text: String, spokenText: String? = nil) {
        self.text = text
        self.spokenText = spokenText
    }

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
        let speechSource = spokenText ?? text
        guard speech.currentText == speechSource,
              let word = speech.currentRange,
              let localLocation = localLocation(for: word.location),
              let sentenceNS = sentence(containing: localLocation),
              let attrRange = Range(sentenceNS, in: attr) else {
            return attr
        }
        attr[attrRange].backgroundColor = .yellow.opacity(0.45)
        return attr
    }

    /// Translate a character index in `spokenText` into a character index in
    /// `text`. Returns nil if the cursor isn't inside this slice.
    private func localLocation(for spokenLocation: Int) -> Int? {
        guard let spokenText, spokenText != text else { return spokenLocation }
        let offset = (spokenText as NSString).range(of: text).location
        guard offset != NSNotFound else { return nil }
        let local = spokenLocation - offset
        guard local >= 0, local < (text as NSString).length else { return nil }
        return local
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
