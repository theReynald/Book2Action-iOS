import Foundation

enum AmazonLinks {
    static func searchURL(title: String, author: String, isbn: String?) -> URL? {
        let query: String
        if let isbn, !isbn.isEmpty {
            query = isbn
        } else {
            query = "\(title) \(author) book"
        }
        var comps = URLComponents(string: "https://www.amazon.com/s")!
        comps.queryItems = [URLQueryItem(name: "k", value: query)]
        return comps.url
    }
}
