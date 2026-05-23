import SwiftUI

struct SettingsView: View {
    @Environment(SettingsStore.self) private var settings
    @Environment(ThemeStore.self) private var theme
    @State private var apiKeyDraft: String = ""
    @State private var isApiKeyVisible: Bool = false
    @State private var savedMessage: String?

    var body: some View {
        @Bindable var settings = settings
        @Bindable var theme = theme

        Form {
            Section {
                Picker("Theme", selection: $theme.mode) {
                    ForEach(ThemeMode.allCases) { mode in
                        Text(mode.label).tag(mode)
                    }
                }
                .pickerStyle(.segmented)
            } header: {
                Text("Appearance")
            }

            Section {
                HStack {
                    Group {
                        if isApiKeyVisible {
                            TextField("sk-…", text: $apiKeyDraft)
                        } else {
                            SecureField("sk-…", text: $apiKeyDraft)
                        }
                    }
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()

                    Button {
                        isApiKeyVisible.toggle()
                    } label: {
                        Image(systemName: isApiKeyVisible ? "eye.slash" : "eye")
                            .foregroundStyle(.secondary)
                    }
                    .buttonStyle(.plain)
                }

                Button("Save API Key") {
                    settings.apiKey = apiKeyDraft.trimmingCharacters(in: .whitespacesAndNewlines)
                    savedMessage = "API key saved to Keychain."
                }
                .disabled(apiKeyDraft.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)

                if settings.hasApiKey {
                    Button("Remove API Key", role: .destructive) {
                        settings.apiKey = ""
                        apiKeyDraft = ""
                        savedMessage = "API key removed."
                    }
                }

                if let savedMessage {
                    Text(savedMessage).font(.caption).foregroundStyle(.secondary)
                }
            } header: {
                Text("OpenAI API Key")
            } footer: {
                Text("Stored securely in the iOS Keychain on this device. Get a key at platform.openai.com. Without one, only the three pre-loaded books (Atomic Habits, Think and Grow Rich, 7 Habits) will work.")
            }

            Section("About") {
                LabeledContent("Version", value: appVersion)
                Link(destination: URL(string: "https://github.com/theReynald/Book2Action")!) {
                    Label("Source", systemImage: "link")
                }
            }
        }
        .navigationTitle("Settings")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            apiKeyDraft = settings.apiKey
        }
    }

    private var appVersion: String {
        let v = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
        let b = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "1"
        return "\(v) (\(b))"
    }
}
