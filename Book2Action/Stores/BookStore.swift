import Foundation
import Observation

@Observable
final class BookStore {
    var currentBook: Book?
    var isLoading: Bool = false
    var errorMessage: String?
    var searchTitle: String = ""
    var path: [AppRoute] = []

    func reset() {
        currentBook = nil
        isLoading = false
        errorMessage = nil
        searchTitle = ""
    }
}
