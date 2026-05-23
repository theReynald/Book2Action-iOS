# Book2Action — Native iOS (Swift + SwiftUI)

A native iOS rebuild of the original Book2Action mobile app (formerly Expo / React Native). Search any book, get an AI-generated 3-paragraph summary, and a 7-day action plan with detailed implementation steps. Built **fully native** in Swift + SwiftUI — no JS runtime, no React Native, no Expo — for maximum TestFlight/App Store stability.

## Features

- **Open Library typeahead** book search (debounced, 8 results)
- **OpenAI gpt-4o-mini** book analysis with JSON mode → 3-paragraph summary + 7 actionable steps
- 3 **bundled offline books** (Atomic Habits, Think and Grow Rich, 7 Habits) — work without an API key
- 25 **trending books** carousel with pull-to-refresh randomization
- **Book cover** staged loading: OpenLibrary ISBN → Google Books → OpenLibrary title → placeholder
- **Action detail** screen with Key Takeaway + 5 detailed sentences
- **Read Aloud** (`AVSpeechSynthesizer`) with voice picker, speech-rate slider, play/pause/stop, audio-session ducking
- **Add to Calendar** via native `EventKit` (no Google OAuth required) — events scheduled for the next matching weekday at 9am with a 30-min reminder
- **Export to PDF** via `UIGraphicsPDFRenderer` and native share sheet
- **Buy on Amazon** deep link (ISBN-preferred)
- **Settings**: theme (System / Light / Dark), OpenAI API key (stored in **Keychain**)
- **Light + dark theme**, persisted to `UserDefaults`
- **Privacy manifest** (`PrivacyInfo.xcprivacy`) included
- No third-party dependencies — only Apple SDKs

## Project layout

```
B2A v2.0/
├── Book2Action.xcodeproj/         # Xcode project (synchronized file groups)
├── Config.xcconfig                # build-time settings (incl. optional OPENAI_API_KEY)
├── Book2Action/
│   ├── Book2ActionApp.swift       # @main app + RootView + AppRoute
│   ├── Theme/AppTheme.swift
│   ├── Models/Models.swift
│   ├── Services/
│   │   ├── KeychainStore.swift
│   │   ├── SettingsStore.swift
│   │   ├── OpenAIService.swift
│   │   └── OpenLibraryService.swift
│   ├── Stores/BookStore.swift
│   ├── Utils/
│   │   ├── AmazonLinks.swift
│   │   ├── CalendarHelper.swift
│   │   ├── ContentFilter.swift
│   │   ├── CoverImage.swift
│   │   ├── PDFExporter.swift
│   │   └── SpeechManager.swift
│   ├── Components/
│   │   ├── BookCoverImage.swift
│   │   ├── HighlightedText.swift
│   │   ├── ReadAloudControls.swift
│   │   └── ShareSheet.swift
│   ├── Views/
│   │   ├── HomeView.swift
│   │   ├── BookResultView.swift
│   │   ├── ActionDetailView.swift
│   │   └── SettingsView.swift
│   ├── Data/
│   │   ├── BundledBooks.swift
│   │   └── TrendingBooks.swift
│   ├── Assets.xcassets/
│   └── PrivacyInfo.xcprivacy
└── Book2ActionTests/              # XCTest unit tests
```

## Requirements

- macOS with **Xcode 16+** (Xcode 16 introduced synchronized file system groups, which this project uses; works in 16, 17, 26)
- iOS 17.0+ deployment target
- Apple Developer account for TestFlight / App Store
- An OpenAI API key (for AI analysis beyond the 3 bundled books)

## Setup

1. Open the project:
   ```bash
   open "Book2Action.xcodeproj"
   ```
2. In the project editor → **Signing & Capabilities**, pick your **Team** and (optionally) change `PRODUCT_BUNDLE_IDENTIFIER`.
3. (Optional, recommended for personal builds) Inject your OpenAI key at build time by editing `Config.xcconfig`:
   ```
   OPENAI_API_KEY = sk-xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
   ```
   (the line is commented out by default). Otherwise enter it in the in-app **Settings** screen — it will be stored in the iOS Keychain.
4. Select an iPhone simulator (or your device) and **Run** (⌘R).

## TestFlight checklist

The project is configured for App Store submission out of the box:

- ✅ Bundle ID, version, build number set
- ✅ Auto-generated `Info.plist` with launch screen, supported orientations, and the calendar usage description (`NSCalendarsFullAccessUsageDescription` / `NSCalendarsUsageDescription`)
- ✅ `PrivacyInfo.xcprivacy` privacy manifest (declares required-reason API usage for `UserDefaults` and `fileTimestamp`)
- ✅ No tracking / no IDFA / no analytics SDKs
- ✅ All networking goes over HTTPS to public, named endpoints (OpenAI, Open Library, Google Books cover service)

Before archiving:

1. Add an App Store **App Icon** (1024×1024 PNG) at `Book2Action/Assets.xcassets/AppIcon.appiconset/`. (The slot is created; just drag the PNG in via Xcode's asset catalog editor.)
2. Verify your **Team** and **Bundle Identifier** in target settings.
3. **Product → Archive**, then upload via the Organizer to App Store Connect → TestFlight.

## Mapping from the old Expo app

| Original (Expo / RN)                        | New (native iOS)                                     |
| ------------------------------------------- | ---------------------------------------------------- |
| `expo-router`                               | `NavigationStack` + `AppRoute` enum                  |
| `zustand`                                   | `@Observable` classes                                |
| `expo-secure-store`                         | Keychain wrapper (`KeychainStore.swift`)             |
| `axios` → OpenAI                            | `URLSession` + `async/await`                         |
| `expo-speech`                               | `AVSpeechSynthesizer`                                |
| `expo-print` + `expo-sharing`               | `UIGraphicsPDFRenderer` + `UIActivityViewController` |
| Google Calendar OAuth (`expo-auth-session`) | Native `EventKit` (on-device Calendar)               |
| `nativewind` / Tailwind                     | SwiftUI modifiers + `AppColor`                       |
| `lucide-react-native`                       | SF Symbols                                           |
| Expo Go runtime                             | (none — native binary)                               |

> **Note:** Calendar integration is now _device-local_ via EventKit instead of Google Calendar, so it requires no sign-in. If you want Google Calendar sync back later, that's a separate feature and an Apple-review consideration.

## Tests

```bash
xcodebuild test -project Book2Action.xcodeproj -scheme Book2Action -destination 'platform=iOS Simulator,name=iPhone 16'
```

## License

MIT
