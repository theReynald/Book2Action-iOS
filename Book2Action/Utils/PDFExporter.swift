import Foundation
import UIKit

enum PDFExporter {
    /// Renders the book's summary + action plan into a PDF file in the temp directory
    /// and returns its URL, ready to be passed to a UIActivityViewController.
    ///
    /// - Parameter detailed: When true, each action step also includes its
    ///   key takeaway and per-sentence detailed implementation (matches the
    ///   in-app Action Detail screen). When false, only the step + chapter
    ///   are rendered (the original short layout).
    static func export(_ book: Book, detailed: Bool = false) throws -> URL {
        let html = renderHTML(for: book, detailed: detailed)
        let formatter = UIMarkupTextPrintFormatter(markupText: html)
        let pageSize = CGRect(x: 0, y: 0, width: 612, height: 792) // US Letter

        let renderer = UIPrintPageRenderer()
        renderer.addPrintFormatter(formatter, startingAtPageAt: 0)
        renderer.setValue(NSValue(cgRect: pageSize), forKey: "paperRect")
        renderer.setValue(NSValue(cgRect: pageSize.insetBy(dx: 36, dy: 48)), forKey: "printableRect")

        let pdfData = NSMutableData()
        UIGraphicsBeginPDFContextToData(pdfData, pageSize, nil)
        renderer.prepare(forDrawingPages: NSRange(location: 0, length: renderer.numberOfPages))
        let bounds = UIGraphicsGetPDFContextBounds()
        for i in 0..<renderer.numberOfPages {
            UIGraphicsBeginPDFPage()
            renderer.drawPage(at: i, in: bounds)
        }
        UIGraphicsEndPDFContext()

        let safeTitle = book.title
            .components(separatedBy: CharacterSet.alphanumerics.inverted)
            .joined(separator: "_")
            .prefix(60)
        let suffix = detailed ? "_detailed" : ""
        let fileURL = FileManager.default.temporaryDirectory
            .appendingPathComponent("Book2Action_\(safeTitle)\(suffix).pdf")
        try pdfData.write(to: fileURL, options: .atomic)
        return fileURL
    }

    private static func renderHTML(for book: Book, detailed: Bool) -> String {
        let dateStr = DateFormatter.localizedString(from: Date(), dateStyle: .long, timeStyle: .none)
        let stepsHTML = book.actionableSteps.enumerated().map { (i, step) in
            var block = """
            <div class="action-step">
              <div class="step-header">
                <span class="step-number">\(i + 1)</span>
                <span class="step-day">\(escape(step.day ?? "Day \(i + 1)"))</span>
              </div>
              <p class="step-text">\(escape(step.step))</p>
              <p class="step-chapter">From: \(escape(step.chapter))</p>
            """
            if detailed, let details = step.details {
                let sentences = details.sentences
                    .map { "<li>\(escape($0))</li>" }
                    .joined(separator: "\n")
                block += """

                  <p class="detail-label">Key takeaway</p>
                  <p class="detail-takeaway">\(escape(details.keyTakeaway))</p>
                  <p class="detail-label">Detailed implementation</p>
                  <ul class="detail-list">\(sentences)</ul>
                """
            }
            block += "\n</div>"
            return block
        }.joined(separator: "\n")

        let meta = book.genre.map { g -> String in
            let year = book.publishedYear.map { " • \($0)" } ?? ""
            return "<p class=\"book-meta\">\(escape(g))\(year)</p>"
        } ?? ""

        let planTitle = detailed ? "7-Day Action Plan (Detailed)" : "7-Day Action Plan"

        return """
        <!DOCTYPE html><html><head><meta charset="utf-8">
        <style>
          body { font-family: -apple-system, BlinkMacSystemFont, Helvetica, Arial, sans-serif;
                 line-height: 1.6; color: #1a202c; padding: 24px; }
          .header { text-align:center; margin-bottom: 32px; padding-bottom:16px;
                    border-bottom: 2px solid #3b82f6; }
          .book-title { font-size: 26px; font-weight: bold; color: #1e40af; }
          .book-author { font-size: 16px; color: #64748b; margin-top: 4px; }
          .book-meta { font-size: 13px; color: #94a3b8; margin-top: 4px; }
          .section-title { font-size: 18px; font-weight:bold; color:#1e40af;
                           margin: 24px 0 12px; padding-bottom: 6px;
                           border-bottom: 1px solid #e2e8f0; }
          .summary { font-size: 14px; color: #334155; white-space: pre-line; }
          .action-step { background:#f8fafc; border-radius:10px; padding:12px;
                         margin-bottom:12px; border-left:4px solid #3b82f6;
                         page-break-inside: avoid; }
          .step-header { display:flex; align-items:center; margin-bottom:6px; }
          .step-number { background:#3b82f6; color:#fff; width:24px; height:24px;
                         border-radius:50%; display:inline-flex; align-items:center;
                         justify-content:center; font-weight:bold; font-size:13px;
                         margin-right:10px; }
          .step-day { font-weight:600; color:#3b82f6; font-size:14px; }
          .step-text { font-size:14px; color:#1e293b; margin:6px 0; }
          .step-chapter { font-size:12px; color:#64748b; font-style:italic; }
          .detail-label { font-size:11px; font-weight:700; color:#1e40af;
                          text-transform:uppercase; letter-spacing:0.5px;
                          margin: 10px 0 4px; }
          .detail-takeaway { font-size:13px; color:#1e293b; margin:0 0 6px;
                             font-style: italic; }
          .detail-list { margin: 4px 0 0 18px; padding: 0; }
          .detail-list li { font-size:13px; color:#334155; margin-bottom: 4px; }
          .footer { margin-top: 32px; padding-top: 12px; border-top:1px solid #e2e8f0;
                    text-align:center; font-size:11px; color:#94a3b8; }
        </style></head><body>
        <div class="header">
          <h1 class="book-title">\(escape(book.title))</h1>
          <p class="book-author">by \(escape(book.author))</p>
          \(meta)
        </div>
        <h2 class="section-title">Summary</h2>
        <p class="summary">\(escape(book.summary))</p>
        <h2 class="section-title">\(planTitle)</h2>
        \(stepsHTML)
        <div class="footer"><p>Generated by Book2Action • \(dateStr)</p></div>
        </body></html>
        """
    }

    private static func escape(_ s: String) -> String {
        var out = s
        out = out.replacingOccurrences(of: "&", with: "&amp;")
        out = out.replacingOccurrences(of: "<", with: "&lt;")
        out = out.replacingOccurrences(of: ">", with: "&gt;")
        return out
    }
}
