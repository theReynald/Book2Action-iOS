import SwiftUI

struct ReadAloudControls: View {
    let text: String
    @State private var speech = SpeechManager.shared
    @State private var showingVoicePicker = false

    /// True only when this control's `text` is the one currently being spoken.
    /// Lets multiple ReadAloudControls coexist (e.g. summary + action plan).
    private var isMine: Bool { speech.isSpeaking && speech.currentText == text }
    private var isMinePaused: Bool { isMine && speech.isPaused }

    var body: some View {
        HStack(spacing: 12) {
            Button {
                if isMine {
                    if speech.isPaused { speech.resume() } else { speech.pause() }
                } else {
                    speech.speak(text)
                }
            } label: {
                HStack(spacing: 6) {
                    Image(systemName: isMine
                        ? (isMinePaused ? "play.fill" : "pause.fill")
                        : "speaker.wave.2.fill")
                    Text(isMine
                        ? (isMinePaused ? "Resume" : "Pause")
                        : "Read Aloud")
                        .lineLimit(1)
                }
                .font(.subheadline.weight(.semibold))
                .fixedSize(horizontal: true, vertical: false)
                .padding(.horizontal, 14)
                .padding(.vertical, 10)
                .background(AppColor.primary)
                .foregroundStyle(.white)
                .clipShape(Capsule())
            }
            .layoutPriority(1)

            if isMine {
                Button {
                    speech.stop()
                } label: {
                    Image(systemName: "stop.fill")
                        .padding(10)
                        .background(.thinMaterial, in: Circle())
                }
                .accessibilityLabel("Stop reading")
            }

            Button {
                showingVoicePicker = true
            } label: {
                Image(systemName: "person.wave.2.fill")
                    .padding(10)
                    .background(.thinMaterial, in: Circle())
            }
            .accessibilityLabel("Voice settings")
        }
        .sheet(isPresented: $showingVoicePicker) {
            VoiceSettingsSheet(speech: speech)
                .presentationDetents([.medium, .large])
        }
    }
}

struct VoiceSettingsSheet: View {
    @Bindable var speech: SpeechManager
    @Environment(\.dismiss) private var dismiss
    @State private var voices: [VoiceOption] = []

    var body: some View {
        NavigationStack {
            Form {
                Section("Speed") {
                    Slider(value: $speech.rate, in: 0.3...0.7, step: 0.05) {
                        Text("Speech rate")
                    } minimumValueLabel: {
                        Image(systemName: "tortoise.fill").foregroundStyle(.secondary)
                    } maximumValueLabel: {
                        Image(systemName: "hare.fill").foregroundStyle(.secondary)
                    }
                }

                Section("Voice") {
                    if voices.isEmpty {
                        Text("Loading voices…").foregroundStyle(.secondary)
                    } else {
                        ForEach(voices) { v in
                            HStack {
                                VStack(alignment: .leading) {
                                    Text(v.name)
                                    Text(v.language + (v.isEnhanced ? " • Enhanced" : ""))
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }
                                Spacer()
                                if speech.voiceId == v.id {
                                    Image(systemName: "checkmark")
                                        .foregroundStyle(AppColor.primary)
                                }
                            }
                            .contentShape(Rectangle())
                            .onTapGesture {
                                speech.voiceId = v.id
                            }
                        }
                    }
                }
            }
            .navigationTitle("Voice Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { dismiss() }
                }
            }
            .task {
                self.voices = SpeechManager.availableVoices()
            }
        }
    }
}
