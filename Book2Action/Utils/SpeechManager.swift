import AVFoundation
import Foundation
import Observation

struct VoiceOption: Identifiable, Hashable {
    let id: String           // identifier
    let name: String
    let language: String
    let isEnhanced: Bool
}

@Observable
final class SpeechManager: NSObject, AVSpeechSynthesizerDelegate {

    static let shared = SpeechManager()

    private let synthesizer = AVSpeechSynthesizer()

    var isSpeaking: Bool = false
    var isPaused: Bool = false
    /// The text currently being spoken (nil when idle). Consumers use this
    /// to scope per-text UI like sentence highlighting and Play/Pause buttons.
    var currentText: String? = nil
    /// UTF-16 range within `currentText` of the word currently being spoken.
    /// Updated by the synthesizer delegate as playback progresses.
    var currentRange: NSRange? = nil
    /// Selected voice identifier (persisted)
    var voiceId: String? {
        didSet { UserDefaults.standard.set(voiceId, forKey: "book2action_voice_id") }
    }
    /// Speech rate, 0.0...1.0 where 0.5 ≈ AVSpeechUtteranceDefaultSpeechRate.
    var rate: Float {
        didSet { UserDefaults.standard.set(rate, forKey: "book2action_speech_rate") }
    }

    private override init() {
        self.voiceId = UserDefaults.standard.string(forKey: "book2action_voice_id")
        let stored = UserDefaults.standard.float(forKey: "book2action_speech_rate")
        self.rate = stored == 0 ? AVSpeechUtteranceDefaultSpeechRate : stored
        super.init()
        synthesizer.delegate = self
        configureAudioSession()
    }

    private func configureAudioSession() {
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .spokenAudio, options: [.duckOthers])
        } catch {
            // Non-fatal
        }
    }

    /// Build a curated, deduplicated list of high-quality English voices.
    static func availableVoices() -> [VoiceOption] {
        let novelty: Set<String> = [
            "albert", "bad news", "bahh", "bells", "boing", "bubbles", "cellos",
            "good news", "jester", "organ", "superstar", "trinoids", "whisper",
            "zarvox", "bruce", "fred", "junior", "kathy", "princess", "ralph",
            "agnes", "hysterical", "flo", "grandma", "grandpa", "eddy", "reed",
            "rocko", "sandy", "shelley", "wobble", "deranged", "pipe organ"
        ]
        let all = AVSpeechSynthesisVoice.speechVoices()
        let filtered = all.filter { v in
            guard v.language.lowercased().hasPrefix("en") else { return false }
            let n = v.name.lowercased()
            if novelty.contains(where: { n.contains($0) }) { return false }
            return v.name.count >= 3
        }

        // Deduplicate by lowercased name, preferring enhanced/premium.
        var byName: [String: AVSpeechSynthesisVoice] = [:]
        for v in filtered {
            let key = v.name.lowercased()
            if let existing = byName[key] {
                let existingScore = score(existing)
                let newScore = score(v)
                if newScore > existingScore { byName[key] = v }
            } else {
                byName[key] = v
            }
        }

        return byName.values
            .sorted(by: voiceSort)
            .map { VoiceOption(id: $0.identifier, name: $0.name, language: $0.language, isEnhanced: $0.quality == .enhanced || $0.quality == .premium) }
    }

    private static func score(_ v: AVSpeechSynthesisVoice) -> Int {
        switch v.quality {
        case .premium: return 3
        case .enhanced: return 2
        default: return 1
        }
    }

    private static func voiceSort(_ a: AVSpeechSynthesisVoice, _ b: AVSpeechSynthesisVoice) -> Bool {
        // Daniel > Kate > Samantha > UK > Premium > Enhanced > name
        let priorities = ["daniel", "kate", "samantha"]
        for needle in priorities {
            let aHas = a.name.lowercased().contains(needle)
            let bHas = b.name.lowercased().contains(needle)
            if aHas != bHas { return aHas }
        }
        let aUK = a.language.contains("GB")
        let bUK = b.language.contains("GB")
        if aUK != bUK { return aUK }
        if score(a) != score(b) { return score(a) > score(b) }
        return a.name.localizedCaseInsensitiveCompare(b.name) == .orderedAscending
    }

    // MARK: - Controls

    func speak(_ text: String) {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        if synthesizer.isSpeaking { synthesizer.stopSpeaking(at: .immediate) }

        currentText = trimmed
        currentRange = nil

        let utterance = AVSpeechUtterance(string: trimmed)
        if let voiceId, let v = AVSpeechSynthesisVoice(identifier: voiceId) {
            utterance.voice = v
        } else {
            utterance.voice = AVSpeechSynthesisVoice(language: "en-US")
        }
        utterance.rate = rate
        utterance.pitchMultiplier = 1.0
        synthesizer.speak(utterance)
    }

    func pause() {
        guard synthesizer.isSpeaking, !synthesizer.isPaused else { return }
        synthesizer.pauseSpeaking(at: .word)
    }

    func resume() {
        guard synthesizer.isPaused else { return }
        synthesizer.continueSpeaking()
    }

    func stop() {
        synthesizer.stopSpeaking(at: .immediate)
    }

    // MARK: - Delegate

    func speechSynthesizer(_ s: AVSpeechSynthesizer, didStart u: AVSpeechUtterance) {
        isSpeaking = true
        isPaused = false
    }
    func speechSynthesizer(_ s: AVSpeechSynthesizer, willSpeakRangeOfSpeechString characterRange: NSRange, utterance: AVSpeechUtterance) {
        currentRange = characterRange
    }
    func speechSynthesizer(_ s: AVSpeechSynthesizer, didPause u: AVSpeechUtterance) {
        isPaused = true
    }
    func speechSynthesizer(_ s: AVSpeechSynthesizer, didContinue u: AVSpeechUtterance) {
        isPaused = false
    }
    func speechSynthesizer(_ s: AVSpeechSynthesizer, didFinish u: AVSpeechUtterance) {
        isSpeaking = false
        isPaused = false
        currentText = nil
        currentRange = nil
    }
    func speechSynthesizer(_ s: AVSpeechSynthesizer, didCancel u: AVSpeechUtterance) {
        isSpeaking = false
        isPaused = false
        currentText = nil
        currentRange = nil
    }
}
