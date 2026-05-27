import SwiftUI
import SwiftData

@main
struct Book2ActionApp: App {
    @State private var theme = ThemeStore()
    @State private var bookStore = BookStore()
    @State private var settings = SettingsStore()

    var body: some Scene {
        WindowGroup {
            RootView()
                .environment(theme)
                .environment(bookStore)
                .environment(settings)
                .preferredColorScheme(theme.colorScheme)
        }
        .modelContainer(for: CachedBook.self)
    }
}

struct RootView: View {
    @Environment(BookStore.self) private var bookStore

    var body: some View {
        @Bindable var bookStore = bookStore
        NavigationStack(path: $bookStore.path) {
            HomeView()
                .navigationDestination(for: AppRoute.self) { route in
                    switch route {
                    case .bookResult:
                        BookResultView()
                    case .actionDetail(let index):
                        ActionDetailView(stepIndex: index)
                    case .settings:
                        SettingsView()
                    }
                }
        }
    }
}

enum AppRoute: Hashable {
    case bookResult
    case actionDetail(Int)
    case settings
}
