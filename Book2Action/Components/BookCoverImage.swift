import SwiftUI

/// Async book cover with OpenLibrary → Google Books → placeholder fallback,
/// mirroring the per-ISBN stage logic in the original mobile app.
struct BookCoverImage: View {
    let isbn: String?
    let title: String
    var explicitURL: URL? = nil
    var width: CGFloat = 120
    var height: CGFloat = 180

    @State private var stage: Int = 0  // 0 = explicit/primary, then fallbacks, then placeholder

    private var candidates: [URL] {
        var urls: [URL] = []
        if let explicitURL { urls.append(explicitURL) }
        urls.append(contentsOf: CoverImage.fallbackURLs(isbn: isbn, title: title))
        return urls
    }

    var body: some View {
        Group {
            if stage < candidates.count {
                AsyncImage(url: candidates[stage]) { phase in
                    switch phase {
                    case .empty:
                        placeholder.overlay(ProgressView())
                    case .success(let img):
                        img.resizable().scaledToFill()
                    case .failure:
                        Color.clear.onAppear { advanceStage() }
                    @unknown default:
                        placeholder
                    }
                }
            } else {
                placeholder
            }
        }
        .frame(width: width, height: height)
        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
        .shadow(color: .black.opacity(0.25), radius: 6, x: 0, y: 3)
    }

    private func advanceStage() {
        if stage < candidates.count { stage += 1 }
    }

    private var placeholder: some View {
        ZStack {
            LinearGradient(
                colors: [AppColor.primary, AppColor.primaryLight],
                startPoint: .topLeading, endPoint: .bottomTrailing
            )
            VStack(spacing: 6) {
                Image(systemName: "book.closed.fill")
                    .font(.system(size: min(width, height) * 0.3))
                Text(title)
                    .font(.caption2.weight(.semibold))
                    .multilineTextAlignment(.center)
                    .lineLimit(3)
                    .padding(.horizontal, 6)
            }
            .foregroundStyle(.white)
        }
    }
}
