import SwiftUI
import SwiftData
import UIKit

struct HomeView: View {
    @Environment(ThemeStore.self) private var theme
    @Environment(BookStore.self) private var bookStore
    @Environment(SettingsStore.self) private var settings
    @Environment(\.colorScheme) private var systemScheme
    @Environment(\.modelContext) private var modelContext

    /// Most-recently-viewed cached books, newest first. Limited to a small
    /// window so the Home screen stays light; full history can live behind
    /// a dedicated screen later.
    @Query(
        sort: \CachedBook.lastViewedAt,
        order: .reverse,
        animation: .default
    )
    private var recentBooks: [CachedBook]

    @State private var searchText = ""
    @State private var suggestions: [OpenLibraryBook] = []
    @State private var isSearchingSuggestions = false
    @State private var showSuggestions = false
    @State private var selectedCoverURL: URL?
    @State private var selectedWorkKey: String?
    @State private var suppressNextTextChange = false
    @State private var debounceTask: Task<Void, Never>?
    @State private var trending: [TrendingBook] = []
    @State private var classics: [TrendingBook] = ClassicBooks.random()
    @State private var placeholderIndex: Int = 0
    @State private var showNoKeyAlert = false

    /// True when the user hasn't configured an OpenAI key. In that mode the
    /// carousel only shows bundled books (which work offline) so every tap
    /// produces a complete analysis instead of a "missing API key" error.
    private var hasAPIKey: Bool {
        !settings.apiKey.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    /// The text field accepts typing only when an API key is configured.
    /// Even after a bundled pick populates the title, the field stays
    /// disabled — a tap then triggers the "API key required" alert.
    private var isSearchFieldEnabled: Bool { hasAPIKey }

    private let placeholders = [
        "Search by title or author…",
        "Try 'Atomic Habits' by James Clear",
        "Try 'Think and Grow Rich' by Napoleon Hill",
        "Try 'The 7 Habits of Highly Effective People'",
        "Try author: Malcolm Gladwell",
        "Try 'The 4-Hour Workweek' by Tim Ferriss",
        "Try 'Rich Dad Poor Dad' by Robert Kiyosaki",
        "Try author: Brené Brown"
    ]

    private var isDark: Bool {
        switch theme.mode {
        case .dark: true
        case .light: false
        case .system: systemScheme == .dark
        }
    }

    var body: some View {
        @Bindable var bookStore = bookStore
        ZStack {
            AppColor.background(dark: isDark)
                .ignoresSafeArea()
                .contentShape(Rectangle())
                .onTapGesture { hideKeyboard() }

            ScrollView {
                VStack(spacing: 24) {
                    header
                    searchCard
                    if bookStore.isLoading {
                        loadingCard
                    } else if let err = bookStore.errorMessage {
                        errorCard(err)
                    } else {
                        if !hasAPIKey {
                            noKeyHint
                        }
                        if !recentBooks.isEmpty {
                            recentlyViewedSection
                        }
                        // Trending row is hidden until a live data source
                        // (e.g. NYT Bestsellers API) is wired in. Re-enable by
                        // adding `if hasAPIKey { trendingSection }` here.
                        classicsSection
                        buildStampView
                    }
                }
                .padding(20)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
                .contentShape(Rectangle())
                .simultaneousGesture(TapGesture().onEnded { hideKeyboard() })
            }
            .scrollDismissesKeyboard(.immediately)
            .refreshable {
                classics = ClassicBooks.random()
            }
            .onAppear {
                if classics.isEmpty { classics = ClassicBooks.random() }
            }
        }
        .navigationBarHidden(true)
        .onReceive(Timer.publish(every: 5, on: .main, in: .common).autoconnect()) { _ in
            placeholderIndex = (placeholderIndex + 1) % placeholders.count
        }
    }

    // MARK: - Header

    private var header: some View {
        VStack(spacing: 12) {
            HStack {
                Spacer()
                Button {
                    bookStore.path.append(.settings)
                } label: {
                    Image(systemName: "gearshape.fill")
                        .padding(12)
                        .background(AppColor.cardBackground(dark: isDark), in: Circle())
                        .foregroundStyle(AppColor.textMuted(dark: isDark))
                }
                Button {
                    theme.toggle()
                } label: {
                    Image(systemName: isDark ? "sun.max.fill" : "moon.fill")
                        .padding(12)
                        .background(AppColor.cardBackground(dark: isDark), in: Circle())
                        .foregroundStyle(isDark ? .yellow : AppColor.primary)
                }
            }

            ZStack {
                Circle().fill(AppColor.primary.opacity(0.18)).frame(width: 80, height: 80)
                Image(systemName: "book.fill")
                    .font(.system(size: 38))
                    .foregroundStyle(AppColor.primary)
            }

            HStack(spacing: 0) {
                Text("Book").foregroundStyle(AppColor.text(dark: isDark))
                Text("2").foregroundStyle(AppColor.primary)
                Text("Action").foregroundStyle(AppColor.text(dark: isDark))
            }
            .font(.system(size: 34, weight: .bold))

            Text("Transform Books into Actionable Insights")
                .font(.subheadline)
                .foregroundStyle(AppColor.textMuted(dark: isDark))

            HStack(spacing: 16) {
                featureBadge(icon: "magnifyingglass", label: "Search Books")
                featureBadge(icon: "book.fill", label: "Get Summary")
                featureBadge(icon: "lightbulb.fill", label: "Actionable Steps")
            }
            .padding(.top, 4)
        }
    }

    private func featureBadge(icon: String, label: String) -> some View {
        HStack(spacing: 4) {
            Image(systemName: icon).font(.caption2)
            Text(label).font(.caption2)
        }
        .foregroundStyle(AppColor.textMuted(dark: isDark))
    }

    // MARK: - Search Card

    private var searchCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 8) {
                Image(systemName: "magnifyingglass")
                    .foregroundStyle(AppColor.textMuted(dark: isDark))
                ZStack {
                    TextField(
                        hasAPIKey ? placeholders[placeholderIndex] : "Tap a book below to start",
                        text: $searchText
                    )
                        .submitLabel(.search)
                        .disabled(!isSearchFieldEnabled)
                        .foregroundStyle(
                            isSearchFieldEnabled
                            ? AppColor.text(dark: isDark)
                            : AppColor.textMuted(dark: isDark)
                        )
                        .onChange(of: searchText) { _, newValue in
                            handleTextChange(newValue)
                        }
                        .onSubmit { Task { await runSearch() } }
                        .autocorrectionDisabled()
                        .textInputAutocapitalization(.words)

                    // When the field is disabled (no API key), intercept taps
                    // and surface the "API key required" alert instead of
                    // silently doing nothing.
                    if !isSearchFieldEnabled {
                        Color.clear
                            .contentShape(Rectangle())
                            .onTapGesture { showNoKeyAlert = true }
                    }
                }

                if !searchText.isEmpty {
                    Button {
                        searchText = ""
                        suggestions = []
                        showSuggestions = false
                        selectedCoverURL = nil
                        selectedWorkKey = nil
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundStyle(AppColor.textMuted(dark: isDark))
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(12)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(isDark ? Color(red: 0.12, green: 0.16, blue: 0.22) : Color.white)
            )

            if showSuggestions {
                suggestionsList
            }

            Button {
                Task { await runSearch() }
            } label: {
                HStack {
                    if bookStore.isLoading {
                        ProgressView().tint(.white)
                        Text("Analyzing…").bold()
                    } else {
                        Text("Get Insights").bold()
                    }
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(
                    searchText.trimmingCharacters(in: .whitespaces).isEmpty || bookStore.isLoading
                    ? AppColor.primary.opacity(0.5)
                    : AppColor.primary
                )
                .foregroundStyle(.white)
                .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            .disabled(searchText.trimmingCharacters(in: .whitespaces).isEmpty || bookStore.isLoading)

            if !bookStore.isLoading {
                Text("Try any book title — AI will analyze it and create actionable steps!")
                    .font(.caption)
                    .foregroundStyle(AppColor.textMuted(dark: isDark))
                    .frame(maxWidth: .infinity, alignment: .center)
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(AppColor.cardBackground(dark: isDark))
                .shadow(color: .black.opacity(0.08), radius: 12, x: 0, y: 4)
        )
        .alert("API key required", isPresented: $showNoKeyAlert) {
            Button("OK", role: .cancel) { }
        } message: {
            Text("Add an OpenAI key in Settings to search any book by title. Or tap one of the bundled books below — they work without a key.")
        }
    }

    @ViewBuilder
    private var suggestionsList: some View {
        VStack(spacing: 0) {
            if isSearchingSuggestions && suggestions.isEmpty {
                HStack {
                    ProgressView()
                    Text("Searching…")
                        .font(.caption)
                        .foregroundStyle(AppColor.textMuted(dark: isDark))
                }
                .padding(12)
            } else if !isSearchingSuggestions && suggestions.isEmpty && !searchText.isEmpty {
                Text("No books found. Tap Get Insights to search with AI.")
                    .font(.caption)
                    .foregroundStyle(AppColor.textMuted(dark: isDark))
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(12)
            } else {
                ForEach(suggestions) { book in
                    Button {
                        selectSuggestion(book)
                    } label: {
                        HStack(spacing: 10) {
                            AsyncImage(url: book.coverImageUrl) { phase in
                                switch phase {
                                case .success(let img): img.resizable().scaledToFill()
                                default:
                                    ZStack {
                                        AppColor.primary
                                        Image(systemName: "book.fill")
                                            .foregroundStyle(.white)
                                    }
                                }
                            }
                            .frame(width: 36, height: 50)
                            .clipShape(RoundedRectangle(cornerRadius: 4))

                            VStack(alignment: .leading, spacing: 2) {
                                Text(book.title).font(.subheadline.weight(.medium)).lineLimit(1)
                                Text(book.author).font(.caption).foregroundStyle(.secondary).lineLimit(1)
                            }
                            Spacer()
                        }
                        .padding(.vertical, 8)
                        .padding(.horizontal, 12)
                    }
                    .buttonStyle(.plain)
                    Divider()
                }
            }
        }
        .background(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.secondary.opacity(0.2))
        )
    }

    // MARK: - Loading / Error

    private var loadingCard: some View {
        @Bindable var bookStore = bookStore
        return VStack(spacing: 12) {
            if let gifURL = URL(string: "https://media.giphy.com/media/LYBMuRwH3JkhdmLbGE/giphy.gif") {
                AnimatedGIFView(url: gifURL)
                    .frame(width: 120, height: 120)
            } else {
                ProgressView().scaleEffect(1.4).tint(AppColor.primary)
            }
            Text("Our AI is reading through \"\(bookStore.searchTitle)\" to create a custom 7-day action plan…")
                .multilineTextAlignment(.center)
                .foregroundStyle(AppColor.primaryLight)
                .padding(.horizontal)
        }
        .padding(.vertical, 24)
    }

    private func errorCard(_ message: String) -> some View {
        @Bindable var bookStore = bookStore
        return VStack(spacing: 12) {
            Text("Oops! Something went wrong")
                .font(.headline)
                .foregroundStyle(AppColor.error)
            Text(message)
                .multilineTextAlignment(.center)
                .foregroundStyle(AppColor.textMuted(dark: isDark))
            Button("Try Again") {
                bookStore.errorMessage = nil
                searchText = ""
            }
            .padding(.horizontal, 16).padding(.vertical, 8)
            .background(AppColor.primary)
            .foregroundStyle(.white)
            .clipShape(Capsule())
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(AppColor.error.opacity(0.1), in: RoundedRectangle(cornerRadius: 16))
    }

    // MARK: - Trending

    /// Shown when no OpenAI API key is configured. Lets first-time users (and
    /// App Review) know they can try the app without supplying anything: the
    /// bundled books work fully offline.
    private var noKeyHint: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: "sparkles")
                .font(.title3)
                .foregroundStyle(AppColor.primary)
            VStack(alignment: .leading, spacing: 4) {
                Text("No account or API key needed to try the app")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(AppColor.text(dark: isDark))
                Text("Tap any book below to see a full summary and 7-day action plan. Add your own OpenAI key in Settings later to analyze any other book.")
                    .font(.caption)
                    .foregroundStyle(AppColor.textMuted(dark: isDark))
            }
            Spacer(minLength: 0)
        }
        .padding(14)
        .background(AppColor.primary.opacity(0.10), in: RoundedRectangle(cornerRadius: 12))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(AppColor.primary.opacity(0.25), lineWidth: 1)
        )
    }

    // MARK: - Recently Viewed

    /// Horizontal carousel of previously-analyzed books. Tapping one re-opens
    /// the cached analysis instantly (no OpenAI call, no key required).
    private var recentlyViewedSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Recently viewed")
                    .font(.headline)
                    .foregroundStyle(AppColor.text(dark: isDark))
                Spacer()
            }

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(recentBooks.prefix(20)) { entry in
                        Button {
                            openCached(entry)
                        } label: {
                            VStack(spacing: 6) {
                                BookCoverImage(isbn: nil, title: entry.title, explicitURL: entry.coverImageURL.flatMap(URL.init(string:)), width: 100, height: 150)
                                Text(entry.title)
                                    .font(.caption.weight(.medium))
                                    .lineLimit(2)
                                    .foregroundStyle(AppColor.text(dark: isDark))
                                Text(entry.author)
                                    .font(.caption2)
                                    .foregroundStyle(AppColor.textMuted(dark: isDark))
                                    .lineLimit(1)
                            }
                            .frame(width: 110)
                        }
                        .buttonStyle(.plain)
                        .contextMenu {
                            Button(role: .destructive) {
                                BookCacheStore(context: modelContext).remove(entry)
                            } label: {
                                Label("Remove", systemImage: "trash")
                            }
                        }
                    }
                }
                .padding(.vertical, 4)
            }
        }
    }

    private func openCached(_ entry: CachedBook) {
        @Bindable var bookStore = bookStore
        guard let book = try? JSONDecoder().decode(Book.self, from: entry.bookData) else { return }
        entry.lastViewedAt = .now
        try? modelContext.save()
        bookStore.errorMessage = nil
        bookStore.currentBook = book
        bookStore.path.append(.bookResult)
    }

    private var trendingSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Trending")
                    .font(.headline)
                    .foregroundStyle(AppColor.text(dark: isDark))
                Spacer()
                Button {
                    trending = TrendingBooks.random()
                } label: {
                    Image(systemName: "arrow.clockwise")
                        .foregroundStyle(AppColor.textMuted(dark: isDark))
                }
            }

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(trending) { b in
                        Button {
                            searchText = b.title
                            selectedCoverURL = URL(string: b.coverImageUrl)
                            Task { await runSearch() }
                        } label: {
                            VStack(spacing: 6) {
                                BookCoverImage(isbn: b.isbn, title: b.title, width: 100, height: 150)
                                Text(b.title)
                                    .font(.caption.weight(.medium))
                                    .lineLimit(2)
                                    .foregroundStyle(AppColor.text(dark: isDark))
                                Text(b.author)
                                    .font(.caption2)
                                    .foregroundStyle(AppColor.textMuted(dark: isDark))
                                    .lineLimit(1)
                            }
                            .frame(width: 110)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.vertical, 4)
            }
        }
    }

    private var classicsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Try one of these classics")
                    .font(.headline)
                    .foregroundStyle(AppColor.text(dark: isDark))
                Spacer()
                Button {
                    classics = ClassicBooks.random()
                } label: {
                    Image(systemName: "arrow.clockwise")
                        .foregroundStyle(AppColor.textMuted(dark: isDark))
                }
            }

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(classics) { b in
                        Button {
                            searchText = b.title
                            selectedCoverURL = URL(string: b.coverImageUrl)
                            Task { await runSearch() }
                        } label: {
                            VStack(spacing: 6) {
                                BookCoverImage(isbn: b.isbn, title: b.title, width: 100, height: 150)
                                Text(b.title)
                                    .font(.caption.weight(.medium))
                                    .lineLimit(2)
                                    .foregroundStyle(AppColor.text(dark: isDark))
                                Text(b.author)
                                    .font(.caption2)
                                    .foregroundStyle(AppColor.textMuted(dark: isDark))
                                    .lineLimit(1)
                            }
                            .frame(width: 110)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.vertical, 4)
            }
        }
    }

    private var buildStampView: some View {
        let info = Bundle.main.infoDictionary
        let version = (info?["CFBundleShortVersionString"] as? String) ?? "?"
        let build = (info?["CFBundleVersion"] as? String) ?? "?"
        let stamp: String = {
            if let exe = Bundle.main.executableURL,
               let attrs = try? FileManager.default.attributesOfItem(atPath: exe.path),
               let date = attrs[.modificationDate] as? Date {
                let df = DateFormatter()
                df.dateFormat = "yyyy-MM-dd HH:mm"
                return df.string(from: date)
            }
            return "unknown"
        }()
        return Text("v\(version) (\(build)) · built \(stamp)")
            .font(.caption2)
            .foregroundStyle(AppColor.textMuted(dark: isDark))
            .frame(maxWidth: .infinity, alignment: .center)
            .padding(.top, 16)
            .padding(.bottom, 4)
    }

    // MARK: - Actions

    private func handleTextChange(_ newValue: String) {
        // When the change was triggered programmatically by selectSuggestion,
        // skip the typeahead lookup so we don't flash "No books found" or
        // re-open the dropdown right before kicking off Get Insights.
        if suppressNextTextChange {
            suppressNextTextChange = false
            return
        }
        selectedCoverURL = nil
        selectedWorkKey = nil
        debounceTask?.cancel()
        let trimmed = newValue.trimmingCharacters(in: .whitespaces)
        if trimmed.isEmpty {
            suggestions = []
            showSuggestions = false
            isSearchingSuggestions = false
            return
        }
        showSuggestions = true
        isSearchingSuggestions = true
        debounceTask = Task {
            try? await Task.sleep(nanoseconds: 500_000_000)
            if Task.isCancelled { return }
            let results = await OpenLibraryService.search(query: trimmed)
            if Task.isCancelled { return }
            await MainActor.run {
                self.suggestions = results
                self.isSearchingSuggestions = false
            }
        }
    }

    private func selectSuggestion(_ b: OpenLibraryBook) {
        // Include the author so OpenAI returns the exact edition the user picked
        // (otherwise a title like "The Intruder" matches many different books).
        let author = b.author.trimmingCharacters(in: .whitespacesAndNewlines)
        suppressNextTextChange = true
        searchText = author.isEmpty ? b.title : "\(b.title) by \(author)"
        selectedCoverURL = b.coverImageUrl
        selectedWorkKey = b.id
        suggestions = []
        showSuggestions = false
        isSearchingSuggestions = false
        debounceTask?.cancel()
        // Tapping a suggestion is an explicit choice — go straight to analysis.
        Task { await runSearch() }
    }

    private func runSearch() async {
        @Bindable var bookStore = bookStore
        let trimmed = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty, !bookStore.isLoading else { return }

        // Defense-in-depth: if the text field was bypassed (e.g. hardware
        // keyboard or paste) and there is no API key, only allow searches
        // that resolve to a bundled book. Otherwise show a clear nudge.
        if !hasAPIKey && BundledBooks.match(trimmed) == nil {
            await MainActor.run { showNoKeyAlert = true }
            return
        }

        showSuggestions = false
        bookStore.searchTitle = trimmed
        bookStore.isLoading = true
        bookStore.errorMessage = nil

        // Cache hit: short-circuit the API call entirely.
        let (parsedTitle, parsedAuthor) = Self.splitTitleAndAuthor(trimmed)
        let cache = BookCacheStore(context: modelContext)
        if let cached = cache.lookup(title: parsedTitle, author: parsedAuthor) {
            await MainActor.run {
                bookStore.isLoading = false
                var book = cached
                if let selected = selectedCoverURL {
                    book.coverImageUrl = selected.absoluteString
                }
                bookStore.currentBook = book
                bookStore.path.append(.bookResult)
            }
            return
        }

        // If the user picked an OpenLibrary suggestion, fetch verified metadata
        // so the prompt is grounded in real synopsis/subjects (lets the model
        // analyze books that aren't in its training data).
        var enrichment: BookEnrichment? = nil
        if let workKey = selectedWorkKey {
            enrichment = await OpenLibraryService.fetchWorkDetails(workKey: workKey)
        }

        let result = await OpenAIService.searchBook(trimmed, apiKey: settings.apiKey, enrichment: enrichment)

        await MainActor.run {
            bookStore.isLoading = false
            if result.success, var book = result.book {
                if let selected = selectedCoverURL {
                    book.coverImageUrl = selected.absoluteString
                }
                cache.save(book)
                bookStore.currentBook = book
                bookStore.path.append(.bookResult)
            } else {
                bookStore.errorMessage = result.error ?? "Failed to find book"
            }
        }
    }

    private func hideKeyboard() {
        UIApplication.shared.sendAction(
            #selector(UIResponder.resignFirstResponder),
            to: nil, from: nil, for: nil
        )
    }

    /// Local copy of `OpenAIService.splitTitleAndAuthor` so we can derive the
    /// cache key without exposing the service's private helper.
    private static func splitTitleAndAuthor(_ raw: String) -> (title: String, author: String?) {
        let separator = " by "
        guard let range = raw.range(of: separator, options: [.caseInsensitive, .backwards]) else {
            return (raw, nil)
        }
        let title = raw[..<range.lowerBound].trimmingCharacters(in: .whitespacesAndNewlines)
        let author = raw[range.upperBound...].trimmingCharacters(in: .whitespacesAndNewlines)
        if title.isEmpty || author.isEmpty {
            return (raw, nil)
        }
        return (title, author)
    }
}

#Preview {
    NavigationStack {
        HomeView()
            .environment(ThemeStore())
            .environment(BookStore())
            .environment(SettingsStore())
    }
    .modelContainer(for: CachedBook.self, inMemory: true)
}
