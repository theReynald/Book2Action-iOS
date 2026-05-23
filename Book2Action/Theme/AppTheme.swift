import SwiftUI

enum ThemeMode: String, CaseIterable, Identifiable, Codable {
    case system, light, dark
    var id: String { rawValue }
    var label: String {
        switch self {
        case .system: "System"
        case .light: "Light"
        case .dark: "Dark"
        }
    }
}

@Observable
final class ThemeStore {
    private static let storageKey = "book2action_theme_mode"

    var mode: ThemeMode {
        didSet { save() }
    }

    init() {
        if let raw = UserDefaults.standard.string(forKey: Self.storageKey),
           let m = ThemeMode(rawValue: raw) {
            self.mode = m
        } else {
            self.mode = .dark
        }
    }

    private func save() {
        UserDefaults.standard.set(mode.rawValue, forKey: Self.storageKey)
    }

    var colorScheme: ColorScheme? {
        switch mode {
        case .system: nil
        case .light: .light
        case .dark: .dark
        }
    }

    func toggle() {
        mode = (mode == .dark) ? .light : .dark
    }
}

enum AppColor {
    static let primary = Color(red: 0x31/255, green: 0x82/255, blue: 0xCE/255)   // #3182ce
    static let primaryLight = Color(red: 0x42/255, green: 0x99/255, blue: 0xE1/255) // #4299e1
    static let primaryDark = Color(red: 0x2B/255, green: 0x6C/255, blue: 0xB0/255)  // #2b6cb0
    static let accent = Color(red: 0x3B/255, green: 0x82/255, blue: 0xF6/255)
    static let success = Color(red: 0x22/255, green: 0xC5/255, blue: 0x5E/255)
    static let error = Color(red: 0xEF/255, green: 0x44/255, blue: 0x44/255)
    static let warning = Color(red: 0xF5/255, green: 0x9E/255, blue: 0x0B/255)
    static let amazon = Color(red: 0xFF/255, green: 0x99/255, blue: 0x00/255)

    static func background(dark: Bool) -> Color {
        dark ? Color(red: 0x1A/255, green: 0x20/255, blue: 0x2C/255)
             : Color(red: 0xEB/255, green: 0xF8/255, blue: 0xFF/255)
    }

    static func text(dark: Bool) -> Color {
        dark ? Color(red: 0xF7/255, green: 0xFA/255, blue: 0xFC/255)
             : Color(red: 0x1E/255, green: 0x29/255, blue: 0x3B/255)
    }

    static func textMuted(dark: Bool) -> Color {
        dark ? Color.white.opacity(0.7)
             : Color(red: 0x1E/255, green: 0x29/255, blue: 0x3B/255).opacity(0.7)
    }

    static func cardBackground(dark: Bool) -> Color {
        dark ? Color(red: 25/255, green: 30/255, blue: 40/255).opacity(0.75)
             : Color.white.opacity(0.85)
    }
}
