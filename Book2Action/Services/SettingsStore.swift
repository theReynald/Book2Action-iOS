import Foundation
import Observation

/// Stores user-controlled settings. The OpenAI API key lives in the Keychain;
/// everything else lives in UserDefaults.
@Observable
final class SettingsStore {
    static let apiKeyKeychainKey = "openai_api_key"

    /// In-memory mirror of the Keychain key. UI binds to this.
    var apiKey: String {
        didSet {
            if apiKey.isEmpty {
                KeychainStore.delete(Self.apiKeyKeychainKey)
            } else {
                KeychainStore.set(apiKey, for: Self.apiKeyKeychainKey)
            }
        }
    }

    init() {
        // Prefer Keychain; fall back to Info.plist build-time injection
        if let stored = KeychainStore.get(Self.apiKeyKeychainKey), !stored.isEmpty {
            self.apiKey = stored
        } else if
            let v = Bundle.main.object(forInfoDictionaryKey: "OpenAIAPIKey") as? String,
            !v.isEmpty,
            v != "$(OPENAI_API_KEY)"
        {
            self.apiKey = v
        } else {
            self.apiKey = ""
        }
    }

    var hasApiKey: Bool { !apiKey.isEmpty }
}
