import SwiftUI

/// Floating audio control that appears whenever SpeechManager is reading
/// something, regardless of which screen is on top. Lets users pause/resume
/// or stop playback after navigating away from the source view.
struct SpeechMiniPlayer: View {
    @State private var speech = SpeechManager.shared

    var body: some View {
        Group {
            if speech.isSpeaking {
                HStack(spacing: 12) {
                    Image(systemName: speech.isPaused ? "speaker.slash.fill" : "speaker.wave.2.fill")
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(.white)
                        .frame(width: 28, height: 28)
                        .background(AppColor.primary, in: Circle())

                    VStack(alignment: .leading, spacing: 1) {
                        Text("Reading aloud")
                            .font(.subheadline.weight(.semibold))
                        Text(speech.isPaused ? "Paused" : "Tap to control playback")
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                    }

                    Spacer()

                    Button {
                        if speech.isPaused { speech.resume() } else { speech.pause() }
                    } label: {
                        Image(systemName: speech.isPaused ? "play.fill" : "pause.fill")
                            .font(.subheadline.weight(.bold))
                            .frame(width: 36, height: 36)
                            .background(.thinMaterial, in: Circle())
                    }
                    .accessibilityLabel(speech.isPaused ? "Resume" : "Pause")

                    Button {
                        speech.stop()
                    } label: {
                        Image(systemName: "stop.fill")
                            .font(.subheadline.weight(.bold))
                            .frame(width: 36, height: 36)
                            .background(.thinMaterial, in: Circle())
                    }
                    .accessibilityLabel("Stop")
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(.regularMaterial, in: Capsule())
                .overlay(Capsule().strokeBorder(.white.opacity(0.15), lineWidth: 0.5))
                .shadow(color: .black.opacity(0.2), radius: 12, x: 0, y: 4)
                .padding(.horizontal, 16)
                .padding(.bottom, 8)
                .transition(.move(edge: .bottom).combined(with: .opacity))
            }
        }
        .animation(.easeInOut(duration: 0.2), value: speech.isSpeaking)
    }
}
