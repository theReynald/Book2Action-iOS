import SwiftUI

/// Renders text and highlights certain spans (currently any "Key Takeaway:" /
/// "Detailed Implementation:" labels, plus the very first sentence) so it
/// matches the look of the original RN HighlightedText component.
struct HighlightedText: View {
    let text: String

    var body: some View {
        Text(makeAttributed())
            .font(.body)
            .lineSpacing(4)
            .multilineTextAlignment(.leading)
            .fixedSize(horizontal: false, vertical: true)
    }

    private func makeAttributed() -> AttributedString {
        var attr = AttributedString(text)
        let labels = ["Key Takeaway:", "Detailed Implementation:"]
        for label in labels {
            if let range = attr.range(of: label) {
                attr[range].foregroundColor = AppColor.accent
                attr[range].font = .body.bold()
            }
        }
        return attr
    }
}

#Preview {
    HighlightedText(text: "Do the thing. Key Takeaway: be consistent. Detailed Implementation: every day, 2 minutes.")
        .padding()
}
