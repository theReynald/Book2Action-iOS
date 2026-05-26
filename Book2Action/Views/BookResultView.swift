import SwiftUI

struct BookResultView: View {
    @Environment(BookStore.self) private var bookStore
    @Environment(ThemeStore.self) private var theme
    @Environment(\.colorScheme) private var systemScheme
    @Environment(\.openURL) private var openURL

    @State private var shareURL: URL?
    @State private var showShareSheet = false
    @State private var toastMessage: String?

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
                        exportPDF(book)
                    } label: {
                        Label("Export PDF", systemImage: "square.and.arrow.up")
                    }
                } label: {
                    Image(systemName: "ellipsis.circle")
                }
            }
        }
        .sheet(isPresented: $showShareSheet) {
            if let shareURL { ShareSheet(items: [shareURL]) }
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
            Text(book.summary)
                .font(.body)
                .foregroundStyle(AppColor.text(dark: isDark))
                .lineSpacing(4)
        }
        .padding(14)
        .background(AppColor.cardBackground(dark: isDark), in: RoundedRectangle(cornerRadius: 16))
    }

    private func actionsCard(_ book: Book) -> some View {
        @Bindable var bookStore = bookStore
        return VStack(alignment: .leading, spacing: 12) {
            HStack {
                Label("7-Day Action Plan", systemImage: "lightbulb.fill").font(.headline)
                Spacer()
                Button {
                    exportPDF(book)
                } label: {
                    Label("PDF", systemImage: "square.and.arrow.up").font(.caption.bold())
                }
            }
            ForEach(Array(book.actionableSteps.enumerated()), id: \.offset) { (i, step) in
                Button {
                    bookStore.path.append(.actionDetail(i))
                } label: {
                    actionRow(index: i, step: step, book: book)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(14)
        .background(AppColor.cardBackground(dark: isDark), in: RoundedRectangle(cornerRadius: 16))
    }

    private func actionRow(index: Int, step: ActionableStep, book: Book) -> some View {
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
        .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 10))
    }

    // MARK: - Actions

    private func addToCalendar(step: ActionableStep, book: Book) async {
        guard let day = step.day else { return }
        let start = CalendarHelper.nextOccurrence(of: day)
        do {
            _ = try await CalendarHelper.addEvent(
                title: step.step,
                notes: "Action step from \"\(book.title)\"",
                start: start
            )
            await showToast("Added to Calendar")
        } catch {
            await showToast("Couldn't add to Calendar")
        }
    }

    private func exportPDF(_ book: Book) {
        do {
            let url = try PDFExporter.export(book)
            shareURL = url
            showShareSheet = true
        } catch {
            Task { await showToast("PDF export failed") }
        }
    }

    @MainActor
    private func showToast(_ message: String) async {
        withAnimation { toastMessage = message }
        try? await Task.sleep(nanoseconds: 2_500_000_000)
        withAnimation { toastMessage = nil }
    }
}
