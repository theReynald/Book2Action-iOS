import SwiftUI

struct ActionDetailView: View {
    let stepIndex: Int
    @Environment(BookStore.self) private var bookStore
    @Environment(ThemeStore.self) private var theme
    @Environment(\.colorScheme) private var systemScheme
    @State private var toastMessage: String?

    private var isDark: Bool {
        switch theme.mode {
        case .dark: true
        case .light: false
        case .system: systemScheme == .dark
        }
    }

    var body: some View {
        if let book = bookStore.currentBook,
           book.actionableSteps.indices.contains(stepIndex) {
            content(book: book, step: book.actionableSteps[stepIndex])
        } else {
            ContentUnavailableView("Action not found", systemImage: "exclamationmark.triangle")
        }
    }

    private func content(book: Book, step: ActionableStep) -> some View {
        let details = step.details ?? DetailedStepInfo(
            sentences: [
                "This step is foundational to applying the principles of the book in real life.",
                "Consistency matters more than intensity; repeat this action daily.",
                "Use small wins to build momentum and reinforce the new identity.",
                "Pair this with an existing routine to make it stick.",
                "Reflect at the end of each day to track your progress."
            ],
            keyTakeaway: "The most important aspect of \"\(step.step)\" is consistency and intentional practice."
        )
        let fullText = """
        \(step.step). Key Takeaway: \(details.keyTakeaway). Detailed Implementation: \(details.sentences.joined(separator: ". "))
        """

        return ZStack(alignment: .bottom) {
            AppColor.background(dark: isDark).ignoresSafeArea()
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    if let day = step.day {
                        Text(day)
                            .font(.caption.bold())
                            .padding(.horizontal, 10).padding(.vertical, 6)
                            .background(AppColor.primary.opacity(0.15))
                            .foregroundStyle(AppColor.primary)
                            .clipShape(Capsule())
                    }
                    Text(step.step)
                        .font(.title3.bold())
                        .foregroundStyle(AppColor.text(dark: isDark))
                    Text(step.chapter)
                        .font(.caption).italic()
                        .foregroundStyle(AppColor.textMuted(dark: isDark))

                    Divider().padding(.vertical, 4)

                    ReadAloudControls(text: fullText)

                    section(title: "Key Takeaway") {
                        Text(details.keyTakeaway)
                            .foregroundStyle(AppColor.text(dark: isDark))
                    }

                    section(title: "Detailed Implementation") {
                        VStack(alignment: .leading, spacing: 10) {
                            ForEach(Array(details.sentences.enumerated()), id: \.offset) { (i, s) in
                                HStack(alignment: .top, spacing: 8) {
                                    Text("\(i + 1).")
                                        .font(.caption.bold())
                                        .foregroundStyle(AppColor.primary)
                                    Text(s)
                                        .foregroundStyle(AppColor.text(dark: isDark))
                                }
                            }
                        }
                    }

                    Button {
                        Task { await addToCalendar(step: step, book: book, details: details) }
                    } label: {
                        Label("Add to Calendar", systemImage: "calendar.badge.plus")
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                            .background(AppColor.primary)
                            .foregroundStyle(.white)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                    .padding(.top, 8)
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
        .navigationTitle("Action Step")
        .navigationBarTitleDisplayMode(.inline)
    }

    @ViewBuilder
    private func section<Content: View>(title: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title).font(.headline)
                .foregroundStyle(AppColor.text(dark: isDark))
            content()
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(AppColor.cardBackground(dark: isDark), in: RoundedRectangle(cornerRadius: 14))
    }

    private func addToCalendar(step: ActionableStep, book: Book, details: DetailedStepInfo) async {
        let tomorrow = Calendar.current.date(byAdding: .day, value: 1, to: Date()) ?? Date()
        var start = tomorrow
        if let nineAM = Calendar.current.date(bySettingHour: 9, minute: 0, second: 0, of: tomorrow) {
            start = nineAM
        }
        let notes = """
        From book: \(book.title)
        Chapter: \(step.chapter)

        Key takeaway: \(details.keyTakeaway)

        Details:
        \(details.sentences.joined(separator: "\n"))
        """
        do {
            _ = try await CalendarHelper.addEvent(
                title: "Book Action: \(step.step)",
                notes: notes,
                start: start
            )
            await showToast("Added to Calendar")
        } catch {
            await showToast("Couldn't add to Calendar")
        }
    }

    @MainActor
    private func showToast(_ message: String) async {
        withAnimation { toastMessage = message }
        try? await Task.sleep(nanoseconds: 2_500_000_000)
        withAnimation { toastMessage = nil }
    }
}
