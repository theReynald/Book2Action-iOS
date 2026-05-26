import SwiftUI
import WebKit

/// Displays an animated GIF from a remote URL.
///
/// SwiftUI's `AsyncImage` only renders the first frame of a GIF, so we host
/// a transparent `WKWebView` that loads the GIF inside a minimal HTML wrapper.
struct AnimatedGIFView: UIViewRepresentable {
    let url: URL

    func makeUIView(context: Context) -> WKWebView {
        let config = WKWebViewConfiguration()
        let webView = WKWebView(frame: .zero, configuration: config)
        webView.scrollView.isScrollEnabled = false
        webView.scrollView.bounces = false
        webView.isOpaque = false
        webView.backgroundColor = .clear
        webView.scrollView.backgroundColor = .clear
        return webView
    }

    func updateUIView(_ webView: WKWebView, context: Context) {
        let html = """
        <!DOCTYPE html>
        <html>
        <head>
          <meta name="viewport" content="width=device-width, initial-scale=1, user-scalable=no">
          <style>
            html, body {
              margin: 0;
              padding: 0;
              background: transparent;
              height: 100%;
              display: flex;
              align-items: center;
              justify-content: center;
            }
            img {
              max-width: 100%;
              max-height: 100%;
              object-fit: contain;
            }
          </style>
        </head>
        <body>
          <img src="\(url.absoluteString)" />
        </body>
        </html>
        """
        webView.loadHTMLString(html, baseURL: nil)
    }
}
