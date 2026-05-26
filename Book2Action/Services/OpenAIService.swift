import Foundation

/// Calls OpenAI's chat completions endpoint (gpt-4o-mini, JSON mode) to
/// turn a book title into a structured 7-day action plan, matching the
/// behavior of the original mobile app's openRouterService.ts.
enum OpenAIService {
    private static let endpoint = URL(string: "https://api.openai.com/v1/chat/completions")!
    private static let model = "gpt-4o-mini"

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

    static func searchBook(_ rawTitle: String, apiKey: String) async -> BookSearchResult {
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
            let book = try await generateBookAnalysis(for: title, author: author, apiKey: apiKey)
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

    private static func generateBookAnalysis(for title: String, author: String?, apiKey: String) async throws -> Book {
        let authorHint: String
        if let author, !author.isEmpty {
            authorHint = "\n\nThe author is \"\(author)\". This author hint is authoritative — use it to disambiguate when multiple books share the title, and return THIS author's edition."
        } else {
            authorHint = ""
        }

        let userPrompt = """
        Analyze the book "\(title)"\(authorHint) and provide a comprehensive response in the following JSON format:

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
              "chapter": "Chapter or section where this concept is primarily discussed",
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
        - Only respond with {"notFound": true} if the input is gibberish, nonsensical, or has no plausible book/novelization/related work whatsoever.
        - The summary should be 3 substantial paragraphs
        - Provide exactly 7 actionable steps, one for each day of the week (Monday through Sunday)
        - Each step should have detailed implementation information
        - Include the correct ISBN-13 number for accurate book identification

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
