import SwiftUI
import WebKit

/// Presents an embedded YouTube video inside the app using WKWebView.
/// Use as a `.sheet` content view. Auto-loads with inline playback enabled
/// so it stays in the modal instead of jumping to fullscreen on tap.
struct YouTubePlayerSheet: View {
    let videoID: String
    var title: String = "Tutorial"
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            YouTubeWebView(videoID: videoID)
                .ignoresSafeArea(edges: .bottom)
                .navigationTitle(title)
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .topBarTrailing) {
                        Button("Done") { dismiss() }
                    }
                }
        }
    }
}

private struct YouTubeWebView: UIViewRepresentable {
    let videoID: String

    func makeUIView(context: Context) -> WKWebView {
        let config = WKWebViewConfiguration()
        config.allowsInlineMediaPlayback = true
        config.mediaTypesRequiringUserActionForPlayback = []
        let webView = WKWebView(frame: .zero, configuration: config)
        webView.scrollView.isScrollEnabled = false
        webView.backgroundColor = .black
        webView.isOpaque = false
        return webView
    }

    func updateUIView(_ webView: WKWebView, context: Context) {
        let html = """
        <!DOCTYPE html><html><head>
        <meta name="viewport" content="width=device-width, initial-scale=1, viewport-fit=cover">
        <style>
          html, body { margin: 0; padding: 0; background: #000; height: 100%; }
          .wrap { position: fixed; inset: 0; display: flex; align-items: center; justify-content: center; }
          iframe { width: 100%; height: 100%; border: 0; }
        </style></head><body>
        <div class="wrap">
          <iframe
            src="https://www.youtube-nocookie.com/embed/\(videoID)?playsinline=1&rel=0&modestbranding=1&autoplay=1"
            allow="autoplay; encrypted-media; picture-in-picture"
            allowfullscreen></iframe>
        </div></body></html>
        """
        webView.loadHTMLString(html, baseURL: URL(string: "https://www.youtube-nocookie.com"))
    }
}
