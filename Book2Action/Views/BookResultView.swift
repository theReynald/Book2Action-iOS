import SwiftUI
import UIKit

struct BookResultView: View {
    @Environment(BookStore.self) private var bookStore
    @Environment(ThemeStore.self) private var theme
    @Environment(\.colorScheme) private var systemScheme
    @Environment(\.openURL) private var openURL

    @State private var sharePayload: SharePayload?
    @State private var toastMessage: String?
    @State private var isPreparingShare = false

    /// Identifiable wrapper so SwiftUI's `.sheet(item:)` always rebuilds the
    /// ShareSheet with the latest items. Using `.sheet(isPresented:)` with
    /// a separate items array can present an empty sheet on the first tap
    /// when the state change and the bool toggle land in the same render
    /// pass.
    private struct SharePayload: Identifiable {
        let id = UUID()
        let items: [Any]
    }

    private var isDark: Bool {
        switch theme.mode {
        case .dark: true
        case .light: false
        case .system: systemScheme == .dark
        }
    }

    var body: some View {
        if let book = bookStore.currentBook {
            content(for: book)
        } else {
            ContentUnavailableView("No book selected", systemImage: "book")
        }
    }

    @ViewBuilder
    private func content(for book: Book) -> some View {
        ZStack(alignment: .bottom) {
            AppColor.background(dark: isDark).ignoresSafeArea()
            ScrollView {
                VStack(spacing: 20) {
                    headerCard(book)
                    summaryCard(book)
                    actionsCard(book)
                }
                .padding(20)
            }
            if let toast = toastMessage {
                Text(toast)
                    .padding(.horizontal, 14).padding(.vertical, 10)
                    .background(.thinMaterial, in: Capsule())
                    .padding(.bottom, 16)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
            }
        }
        .navigationTitle(book.title)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Menu {
                    Button {
                        if let url = AmazonLinks.searchURL(title: book.title, author: book.author, isbn: book.isbn) {
                            openURL(url)
                        }
                    } label: {
                        Label("Buy on Amazon", systemImage: "cart")
                    }
                    Button {
                        Task { await shareBook(book) }
                    } label: {
                        Label("Share book", systemImage: "square.and.arrow.up.on.square")
                    }
                    .disabled(isPreparingShare)
                    Button {
                        postToX(book)
                    } label: {
                        Label("Post to X", systemImage: "text.bubble")
                    }
                    Button {
                        exportPDF(book)
                    } label: {
                        Label("Export PDF", systemImage: "doc.richtext")
                    }
                } label: {
                    Image(systemName: "ellipsis.circle")
                }
            }
        }
        .sheet(item: $sharePayload) { payload in
            ShareSheet(items: payload.items)
        }
    }

    // MARK: - Sections

    private func headerCard(_ book: Book) -> some View {
        HStack(alignment: .top, spacing: 16) {
            BookCoverImage(
                isbn: book.isbn,
                title: book.title,
                explicitURL: book.coverImageUrl.flatMap(URL.init(string:)),
                width: 110,
                height: 165
            )
            VStack(alignment: .leading, spacing: 6) {
                Text(book.title)
                    .font(.title3.bold())
                    .foregroundStyle(AppColor.text(dark: isDark))
                Text("by \(book.author)")
                    .font(.subheadline)
                    .foregroundStyle(AppColor.textMuted(dark: isDark))
                if let g = book.genre {
                    Text(g + (book.publishedYear.map { " • \($0)" } ?? ""))
                        .font(.caption)
                        .foregroundStyle(AppColor.textMuted(dark: isDark))
                }
                Spacer(minLength: 8)
                Button {
                    if let url = AmazonLinks.searchURL(title: book.title, author: book.author, isbn: book.isbn) {
                        openURL(url)
                    }
                } label: {
                    Label("Buy on Amazon", systemImage: "cart.fill")
                        .font(.caption.bold())
                        .padding(.horizontal, 10).padding(.vertical, 6)
                        .background(AppColor.amazon)
                        .foregroundStyle(.white)
                        .clipShape(Capsule())
                }
            }
            Spacer(minLength: 0)
        }
        .padding(14)
        .background(AppColor.cardBackground(dark: isDark), in: RoundedRectangle(cornerRadius: 16))
    }

    private func summaryCard(_ book: Book) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Label("Summary", systemImage: "text.alignleft").font(.headline)
                Spacer()
                ReadAloudControls(text: book.summary)
            }
            HighlightedSummaryText(text: book.summary)
                .foregroundStyle(AppColor.text(dark: isDark))
        }
        .padding(14)
        .background(AppColor.cardBackground(dark: isDark), in: RoundedRectangle(cornerRadius: 16))
    }

    private func actionsCard(_ book: Book) -> some View {
        @Bindable var bookStore = bookStore
        let script = Self.actionPlanReadAloudScript(book)
        return VStack(alignment: .leading, spacing: 12) {
            HStack {
                Label("7-Day Action Plan", systemImage: "lightbulb.fill").font(.headline)
                Spacer()
                Button {
                    exportPDF(book)
                } label: {
                    Label("PDF", systemImage: "square.and.arrow.up").font(.caption.bold())
                }
                Button {
                    let speech = SpeechManager.shared
                    if speech.isSpeaking && speech.currentText == script.text {
                        speech.stop()
                    } else {
                        speech.speak(script.text)
                    }
                } label: {
                    Label(
                        SpeechManager.shared.currentText == script.text && SpeechManager.shared.isSpeaking ? "Stop" : "Read Aloud",
                        systemImage: SpeechManager.shared.currentText == script.text && SpeechManager.shared.isSpeaking ? "stop.fill" : "speaker.wave.2.fill"
                    )
                    .font(.caption.bold())
                }
                .accessibilityLabel("Read 7-day action plan aloud")
            }
            ForEach(Array(book.actionableSteps.enumerated()), id: \.offset) { (i, step) in
                Button {
                    bookStore.path.append(.actionDetail(i))
                } label: {
                    actionRow(
                        index: i,
                        step: step,
                        book: book,
                        isReading: Self.isReading(stepIndex: i, script: script)
                    )
                }
                .buttonStyle(.plain)
            }
        }
        .padding(14)
        .background(AppColor.cardBackground(dark: isDark), in: RoundedRectangle(cornerRadius: 16))
    }

    /// Spoken script for the 7-day action plan, with per-step character ranges
    /// so we can highlight the row currently being read.
    private struct ActionPlanScript: Equatable {
        let text: String
        let stepRanges: [NSRange]
    }

    private static func actionPlanReadAloudScript(_ book: Book) -> ActionPlanScript {
        var output = "Seven day action plan for \(book.title)."
        var ranges: [NSRange] = []
        for (i, step) in book.actionableSteps.enumerated() {
            output += " "
            let start = (output as NSString).length
            let label = step.day ?? "Day \(i + 1)"
            var line = "\(label). \(step.step)"
            if !line.hasSuffix(".") { line += "." }
            let chapter = step.chapter.trimmingCharacters(in: .whitespacesAndNewlines)
            if !chapter.isEmpty { line += " From \(chapter)." }
            output += line
            let end = (output as NSString).length
            ranges.append(NSRange(location: start, length: end - start))
        }
        return ActionPlanScript(text: output, stepRanges: ranges)
    }

    private static func isReading(stepIndex: Int, script: ActionPlanScript) -> Bool {
        let speech = SpeechManager.shared
        guard speech.currentText == script.text,
              let r = speech.currentRange,
              stepIndex < script.stepRanges.count else { return false }
        return NSLocationInRange(r.location, script.stepRanges[stepIndex])
    }

    private func actionRow(index: Int, step: ActionableStep, book: Book, isReading: Bool = false) -> some View {
        HStack(alignment: .top, spacing: 12) {
            ZStack {
                Circle().fill(AppColor.primary)
                Text("\(index + 1)").foregroundStyle(.white).font(.caption.bold())
            }
            .frame(width: 28, height: 28)

            VStack(alignment: .leading, spacing: 4) {
                if let day = step.day {
                    Text(day).font(.caption.bold()).foregroundStyle(AppColor.primary)
                }
                Text(step.step).font(.subheadline).foregroundStyle(AppColor.text(dark: isDark))
                Text(step.chapter).font(.caption).italic().foregroundStyle(AppColor.textMuted(dark: isDark))
                HStack(spacing: 12) {
                    if step.day != nil {
                        Button {
                            Task { await addToCalendar(step: step, book: book) }
                        } label: {
                            Label("Add to Calendar", systemImage: "calendar.badge.plus").font(.caption)
                        }
                    }
                    Image(systemName: "chevron.right").font(.caption).foregroundStyle(.secondary)
                }
                .padding(.top, 2)
            }
            Spacer()
        }
        .padding(10)
        .background(
            (isReading ? Color.yellow.opacity(0.35) : Color.clear),
            in: RoundedRectangle(cornerRadius: 10)
        )
        .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 10))
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .strokeBorder(isReading ? Color.yellow.opacity(0.9) : .clear, lineWidth: 2)
        )
        .animation(.easeInOut(duration: 0.2), value: isReading)
    }

    // MARK: - Actions

    private func addToCalendar(step: ActionableStep, book: Book) async {
        guard let day = step.day else { return }
        let start = CalendarHelper.nextOccurrence(of: day)
        // Mirror ActionDetailView so the event has the same "Book Action:"
        // title prefix and a full notes body (chapter + key takeaway +
        // detail sentences) regardless of where it was added from.
        var notesLines: [String] = [
            "From book: \(book.title)",
            "Chapter: \(step.chapter)"
        ]
        if let details = step.details {
            notesLines.append("")
            notesLines.append("Key takeaway: \(details.keyTakeaway)")
            notesLines.append("")
            notesLines.append("Details:")
            notesLines.append(details.sentences.joined(separator: "\n"))
        }
        do {
            let result = try await CalendarHelper.addEvent(
                title: "Book Action: \(step.step)",
                notes: notesLines.joined(separator: "\n"),
                start: start
            )
            await showToast(CalendarHelper.toastMessage(for: result))
        } catch {
            await showToast("Couldn't add to Calendar")
        }
    }

    private func exportPDF(_ book: Book) {
        do {
            let url = try PDFExporter.export(book)
            sharePayload = SharePayload(items: [url])
        } catch {
            Task { await showToast("PDF export failed") }
        }
    }

    @MainActor
    private func shareBook(_ book: Book) async {
        isPreparingShare = true
        defer { isPreparingShare = false }

        let firstSteps = book.actionableSteps.prefix(3)
            .map { "• \($0.step)" }
            .joined(separator: "\n")
        var text = "\"\(book.title)\" by \(book.author) — my 7-day action plan 📚"
        if !firstSteps.isEmpty { text += "\n\n\(firstSteps)" }
        text += "\n\nBuilt with Book2Action."

        var items: [Any] = [text]
        if let urlStr = book.coverImageUrl,
           let url = URL(string: urlStr),
           let image = await loadImage(from: url) {
            items.append(image)
        }
        if let amazon = AmazonLinks.searchURL(title: book.title, author: book.author, isbn: book.isbn) {
            items.append(amazon)
        }
        sharePayload = SharePayload(items: items)
    }

    private func loadImage(from url: URL) async -> UIImage? {
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            return UIImage(data: data)
        } catch {
            return nil
        }
    }

    private func postToX(_ book: Book) {
        let amazon = AmazonLinks.searchURL(title: book.title, author: book.author, isbn: book.isbn)
        let separator = "──────────"

        var lines: [String] = []
        lines.append("📚 \"\(book.title)\" by \(book.author)")
        lines.append("")
        let summary = Self.shortSummary(book.summary, maxSentences: 5)
        if !summary.isEmpty {
            lines.append(summary)
            lines.append("")
        }
        if !book.actionableSteps.isEmpty {
            lines.append(separator)
            lines.append("My 7-day action plan:")
            lines.append("")
            for (i, step) in book.actionableSteps.enumerated() {
                let prefix = step.day ?? "Day \(i + 1)"
                lines.append("\(prefix): \(step.step)")
                lines.append("")
            }
        }
        lines.append("Built with Book2Action 🚀")
        let text = lines.joined(separator: "\n")

        let encodedText = text.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        let encodedURL = amazon?.absoluteString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""

        var deepLinkString = "twitter://post?message=\(encodedText)"
        if !encodedURL.isEmpty {
            deepLinkString += "%0A\(encodedURL)"
        }

        var webString = "https://x.com/intent/post?text=\(encodedText)"
        if !encodedURL.isEmpty {
            webString += "&url=\(encodedURL)"
        }
        let webURL = URL(string: webString)

        if let deepLink = URL(string: deepLinkString) {
            UIApplication.shared.open(deepLink, options: [:]) { success in
                if !success, let webURL {
                    UIApplication.shared.open(webURL)
                }
            }
        } else if let webURL {
            openURL(webURL)
        }
    }

    @MainActor
    private func showToast(_ message: String) async {
        withAnimation { toastMessage = message }
        try? await Task.sleep(nanoseconds: 4_000_000_000)
        withAnimation { toastMessage = nil }
    }

    private static func shortSummary(_ raw: String, maxSentences: Int) -> String {
        let trimmed = raw.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return "" }
        var sentences: [String] = []
        trimmed.enumerateSubstrings(in: trimmed.startIndex..., options: [.bySentences, .localized]) { substring, _, _, stop in
            if let s = substring?.trimmingCharacters(in: .whitespacesAndNewlines), !s.isEmpty {
                sentences.append(s)
                if sentences.count >= maxSentences { stop = true }
            }
        }
        return sentences.joined(separator: " ")
    }
}
