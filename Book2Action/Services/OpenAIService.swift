import Foundation

/// Calls OpenAI's chat completions endpoint (gpt-4o, JSON mode) to
/// turn a book title into a structured 7-day action plan, matching the
/// behavior of the original mobile app's openRouterService.ts.
enum OpenAIService {
    private static let endpoint = URL(string: "https://api.openai.com/v1/chat/completions")!
    private static let model = "gpt-4o"

    enum ServiceError: LocalizedError {
        case missingAPIKey
        case http(Int, String)
        case decoding(String)
        case notFound
        case empty

        var errorDescription: String? {
            switch self {
            case .missingAPIKey: "Missing OpenAI API key. Add one in Settings."
            case .http(let c, let m): "OpenAI request failed (\(c)): \(m)"
            case .decoding(let m): "Couldn't read OpenAI's response: \(m)"
            case .notFound: "We couldn't find this book."
            case .empty: "OpenAI returned an empty response."
            }
        }
    }

    /// Lightweight validation of an OpenAI API key by calling the `/v1/models` endpoint.
    /// Returns `.success` on HTTP 200, `.invalid` on 401/403, or `.failure` for other errors.
    enum KeyValidationResult {
        case success
        case invalid(String)
        case failure(String)
    }

    static func validateAPIKey(_ apiKey: String) async -> KeyValidationResult {
        let trimmed = apiKey.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else {
            return .invalid("API key is empty.")
        }
        guard trimmed.hasPrefix("sk-") else {
            return .invalid("API key should start with \"sk-\".")
        }

        guard let url = URL(string: "https://api.openai.com/v1/models") else {
            return .failure("Invalid validation URL.")
        }
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(trimmed)", forHTTPHeaderField: "Authorization")
        request.timeoutInterval = 15

        do {
            let (_, response) = try await URLSession.shared.data(for: request)
            guard let http = response as? HTTPURLResponse else {
                return .failure("Unexpected response from OpenAI.")
            }
            switch http.statusCode {
            case 200:
                return .success
            case 401:
                return .invalid("Invalid API key. Please check it and try again.")
            case 403:
                return .invalid("This key is not authorized to access OpenAI.")
            case 429:
                return .failure("Rate limited by OpenAI. Try again shortly.")
            default:
                return .failure("OpenAI returned status \(http.statusCode).")
            }
        } catch {
            return .failure("Couldn't reach OpenAI: \(error.localizedDescription)")
        }
    }

    static func searchBook(_ rawTitle: String, apiKey: String, enrichment: BookEnrichment? = nil) async -> BookSearchResult {
        let raw = rawTitle.trimmingCharacters(in: .whitespacesAndNewlines)
        let (title, author) = splitTitleAndAuthor(raw)
        let normalized = raw.lowercased()

        if !ContentFilter.isAppropriate(normalized) {
            return .init(success: false,
                         error: "Sorry, we cannot process this book title due to our content policy.")
        }

        if let bundled = BundledBooks.match(title) {
            return .init(success: true, book: bundled)
        }

        guard !apiKey.isEmpty else {
            return .init(success: false, error: ServiceError.missingAPIKey.errorDescription)
        }

        do {
            let book = try await generateBookAnalysis(for: title, author: author, apiKey: apiKey, enrichment: enrichment)
            return .init(success: true, book: book)
        } catch ServiceError.notFound {
            return .init(
                success: false,
                error: "Sorry, we couldn't find or analyze \"\(title)\". Try a different book title or check the spelling."
            )
        } catch {
            return .init(success: false, error: error.localizedDescription)
        }
    }

    // MARK: - Private

    /// Splits a query like `"The Intruder by Miriam MacGregor"` into
    /// `(title: "The Intruder", author: "Miriam MacGregor")`. If no `" by "`
    /// separator is found, returns the whole string as the title and a nil author.
    private static func splitTitleAndAuthor(_ raw: String) -> (title: String, author: String?) {
        let separator = " by "
        guard let range = raw.range(of: separator, options: [.caseInsensitive, .backwards]) else {
            return (raw, nil)
        }
        let title = raw[..<range.lowerBound].trimmingCharacters(in: .whitespacesAndNewlines)
        let author = raw[range.upperBound...].trimmingCharacters(in: .whitespacesAndNewlines)
        if title.isEmpty || author.isEmpty {
            return (raw, nil)
        }
        return (title, author)
    }

    /// Asks the model in a single-purpose call for the verbatim table of
    /// contents of `title` (optionally by `author`). The model is instructed
    /// to return an empty array when it isn't highly confident, so a non-empty
    /// result is the model's own attestation that it recalls the ToC.
    ///
    /// Used as a third-tier fallback after OpenLibrary's `table_of_contents`
    /// field and the hand-curated `BundledTableOfContents` map.
    private static func fetchTableOfContents(title: String, author: String?, apiKey: String) async throws -> [String] {
        let authorClause = author.map { " by \($0)" } ?? ""
        let userPrompt = """
        I need the verbatim table of contents for the book "\(title)"\(authorClause).

        Return JSON in this exact shape:
        {
          "tableOfContents": [
            "Chapter 1: Title of chapter one",
            "Chapter 2: Title of chapter two"
          ]
        }

        Rules:
        - Each entry is the chapter heading as printed in the book, including the chapter number when the book uses one (e.g. "Chapter 5: The End of Time Management" or "Ch 1: Showing Up").
        - List ONLY top-level chapters. Skip the preface/introduction/acknowledgements unless they are numbered chapters in the book.
        - List them in the order they appear in the book.
        - For well-known published books that you can recall, provide the chapter list. Use your knowledge of the book.
        - ONLY return {"tableOfContents": []} if the book is obscure, fictional/made-up, or you genuinely have no recollection of its chapter structure. Do NOT invent chapter titles for unknown books.
        - Respond with ONLY the JSON object.
        """

        let body: [String: Any] = [
            "model": model,
            "messages": [
                [
                    "role": "system",
                    "content": "You are a careful librarian. You return only JSON. You never fabricate chapter titles — returning an empty array is always preferable to guessing."
                ],
                ["role": "user", "content": userPrompt]
            ],
            "temperature": 0.0,
            "max_tokens": 1500,
            "response_format": ["type": "json_object"]
        ]

        var request = URLRequest(url: endpoint)
        request.httpMethod = "POST"
        request.timeoutInterval = 30
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONSerialization.data(withJSONObject: body)

        let (data, response) = try await URLSession.shared.data(for: request)
        guard (response as? HTTPURLResponse).map({ (200...299).contains($0.statusCode) }) == true else {
            return []
        }

        struct ChatResponse: Decodable {
            struct Choice: Decodable { struct Msg: Decodable { let content: String }; let message: Msg }
            let choices: [Choice]
        }
        struct TOCEnvelope: Decodable { let tableOfContents: [String]? }

        guard let chat = try? JSONDecoder().decode(ChatResponse.self, from: data),
              let content = chat.choices.first?.message.content,
              let contentData = content.data(using: .utf8),
              let envelope = try? JSONDecoder().decode(TOCEnvelope.self, from: contentData) else {
            return []
        }
        return (envelope.tableOfContents ?? [])
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
    }

    private static func generateBookAnalysis(for title: String, author: String?, apiKey: String, enrichment: BookEnrichment? = nil) async throws -> Book {
        // If the live enrichment doesn't carry a ToC, try the bundled fallback
        // for popular titles so the prompt can still ground chapter citations.
        var effectiveEnrichment: BookEnrichment? = {
            guard let bundled = BundledTableOfContents.lookup(title: title) else { return enrichment }
            if var e = enrichment {
                if e.tableOfContents.isEmpty { e.tableOfContents = bundled }
                return e
            }
            return BookEnrichment(description: nil, subjects: [], firstPublishYear: nil, tableOfContents: bundled)
        }()

        // Third-tier fallback: if no ToC came from OpenLibrary or the bundled
        // list, ask the model itself in a dedicated, single-purpose call where
        // its full attention is on factual chapter recall (not analysis).
        // The call returns an empty list when the model isn't confident.
        if (effectiveEnrichment?.tableOfContents ?? []).isEmpty {
            let llmTOC = (try? await fetchTableOfContents(title: title, author: author, apiKey: apiKey)) ?? []
            print("[OpenAIService] fetchTableOfContents(\(title)) returned \(llmTOC.count) entries")
            if !llmTOC.isEmpty {
                if var e = effectiveEnrichment {
                    e.tableOfContents = llmTOC
                    effectiveEnrichment = e
                } else {
                    effectiveEnrichment = BookEnrichment(description: nil, subjects: [], firstPublishYear: nil, tableOfContents: llmTOC)
                }
            }
        } else {
            print("[OpenAIService] ToC already present (\(effectiveEnrichment?.tableOfContents.count ?? 0) entries), skipping LLM fetch")
        }

        let authorHint: String
        if let author, !author.isEmpty {
            authorHint = """
            \n\nIMPORTANT — the user picked this title together with the author "\(author)".
            - If you recognize a real book by this exact title and author, analyze THAT specific edition (do not switch to a more famous book that shares the title).
            - If you do not recognize this specific edition, DO NOT return notFound. Instead, use the title "\(title)" plus any general knowledge of "\(author)" (their typical genre/themes if any) and craft a thematically appropriate analysis. Set "author" in the JSON to "\(author)" exactly.
            """
        } else {
            authorHint = ""
        }

        let enrichmentHint: String = {
            guard let enrichment = effectiveEnrichment else { return "" }
            var lines: [String] = []
            if let desc = enrichment.description {
                // Cap description to keep token usage reasonable.
                let capped = desc.count > 2000 ? String(desc.prefix(2000)) + "…" : desc
                lines.append("Synopsis (from OpenLibrary): \(capped)")
            }
            if !enrichment.subjects.isEmpty {
                let subjects = enrichment.subjects.prefix(15).joined(separator: ", ")
                lines.append("Subjects/themes: \(subjects)")
            }
            if let year = enrichment.firstPublishYear {
                lines.append("First published: \(year)")
            }
            var groundTruth = ""
            if !lines.isEmpty {
                groundTruth += """
                \n\nGROUND TRUTH — the following metadata about this exact book was retrieved from OpenLibrary and is verified. Treat it as authoritative and base your analysis on it (do NOT return notFound; do NOT substitute a different book with the same title):
                \(lines.joined(separator: "\n"))
                """
            }
            if !enrichment.tableOfContents.isEmpty {
                let toc = enrichment.tableOfContents.enumerated()
                    .map { "  - \($0.element)" }
                    .joined(separator: "\n")
                groundTruth += """
                \n\nVERIFIED CHAPTER LIST (from OpenLibrary's table_of_contents) — this is the AUTHORITATIVE list of chapters for this book. When filling the "chapter" field for each actionable step, you MUST pick a chapter from THIS list and copy its text VERBATIM. Do NOT invent chapters not in this list. Do NOT paraphrase.
                \(toc)
                """
            }
            return groundTruth
        }()

        let userPrompt = """
        Analyze the book "\(title)"\(authorHint)\(enrichmentHint) and provide a comprehensive response in the following JSON format:

        {
          "title": "Exact book title",
          "author": "Author name",
          "publishedYear": year_as_number,
          "genre": "Primary genre",
          "isbn": "The book's ISBN-13 number (13 digits, no hyphens)",
          "summary": "A comprehensive 3-paragraph summary that deeply explores the book's core concepts, main themes, key insights, practical methodologies, and real-world applications.",
          "actionableSteps": [
            {
              "day": "Monday",
              "step": "Specific actionable step that readers can implement",
              "chapter": "If a VERIFIED CHAPTER LIST is provided above, pick a chapter from it and copy the text VERBATIM (including any chapter number). Otherwise, give the exact chapter number and title ONLY if you are highly confident it is correct for THIS book; if not confident, write a thematic descriptor (e.g. 'Discussed throughout the book' or 'Section on <topic>'). NEVER invent chapter numbers or titles.",
              "details": {
                "sentences": [
                  "Detailed explanation sentence 1",
                  "Detailed explanation sentence 2",
                  "Detailed explanation sentence 3",
                  "Detailed explanation sentence 4",
                  "Detailed explanation sentence 5"
                ],
                "keyTakeaway": "The core lesson to remember from this action step"
              }
            }
          ]
        }

        Requirements:
        - ALWAYS try to find a book first. The input may be a book title, movie, TV show, video game, or other media.
        - If the input is a movie, TV show, or video game, find the official novelization, tie-in novel, or "making of" companion book and analyze that.
        - If you cannot find an exact novelization, find the CLOSEST related book on the same subject/franchise and analyze that — do NOT return notFound for well-known media.
        - When an author name is provided, prefer that author's edition; if you don't recognize it, still produce a useful analysis based on the title and any general knowledge of the author rather than returning notFound.
        - Only respond with {"notFound": true} if the input is gibberish or nonsensical with no plausible meaning whatsoever.
        - The summary should be 3 substantial paragraphs
        - Provide exactly 7 actionable steps, one for each day of the week (Monday through Sunday)
        - Each step should have detailed implementation information
        - Include the correct ISBN-13 number for accurate book identification
        - CHAPTER ACCURACY: If a VERIFIED CHAPTER LIST is provided in the GROUND TRUTH section above, the "chapter" field for every actionable step MUST be copied VERBATIM from that list — do not paraphrase, do not invent chapters not in the list. If no chapter list is provided, cite a specific chapter number/title ONLY when highly confident; otherwise use a thematic descriptor such as "Discussed throughout the book". DO NOT invent or guess chapter numbers or chapter titles — fabricated citations are worse than generic ones.

        Respond with ONLY the JSON object.

        Please analyze: "\(title)"
        """

        let body: [String: Any] = [
            "model": model,
            "messages": [
                [
                    "role": "system",
                    "content": "You are a helpful assistant that always responds with valid JSON. If a book cannot be found, respond with: {\"notFound\": true}"
                ],
                ["role": "user", "content": userPrompt]
            ],
            "temperature": 0.7,
            "max_tokens": 4000,
            "response_format": ["type": "json_object"]
        ]

        var request = URLRequest(url: endpoint)
        request.httpMethod = "POST"
        request.timeoutInterval = 60
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONSerialization.data(withJSONObject: body)

        let (data, response) = try await URLSession.shared.data(for: request)
        guard let http = response as? HTTPURLResponse else {
            throw ServiceError.empty
        }
        guard (200...299).contains(http.statusCode) else {
            let snippet = String(data: data, encoding: .utf8) ?? ""
            throw ServiceError.http(http.statusCode, snippet.prefix(200).description)
        }

        struct ChatResponse: Decodable {
            struct Choice: Decodable { struct Msg: Decodable { let content: String }; let message: Msg }
            let choices: [Choice]
        }
        let parsed = try JSONDecoder().decode(ChatResponse.self, from: data)
        guard let content = parsed.choices.first?.message.content else {
            throw ServiceError.empty
        }
        guard let contentData = content.data(using: .utf8) else {
            throw ServiceError.decoding("Non-UTF8 content")
        }

        // notFound short-circuit
        if let obj = try? JSONSerialization.jsonObject(with: contentData) as? [String: Any],
           obj["notFound"] as? Bool == true {
            throw ServiceError.notFound
        }

        do {
            var book = try JSONDecoder().decode(Book.self, from: contentData)
            // Add cover image URL if missing.
            if book.coverImageUrl == nil {
                book.coverImageUrl = CoverImage.primaryURL(isbn: book.isbn, title: book.title)?.absoluteString
            }
            return book
        } catch {
            throw ServiceError.decoding(error.localizedDescription)
        }
    }
}
