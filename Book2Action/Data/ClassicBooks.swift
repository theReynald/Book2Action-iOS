import Foundation

/// Curated list of literary/non-fiction classics used to power the
/// "Try one of these classics" row on Home. Distinct from `TrendingBooks`
/// (which is the contemporary popular-list shown only when an API key is set).
enum ClassicBooks {
    static let all: [TrendingBook] = [
        .init(title: "Pride and Prejudice", author: "Jane Austen", isbn: "9780141439518", coverImageUrl: "https://covers.openlibrary.org/b/isbn/9780141439518-L.jpg"),
        .init(title: "1984", author: "George Orwell", isbn: "9780451524935", coverImageUrl: "https://covers.openlibrary.org/b/isbn/9780451524935-L.jpg"),
        .init(title: "To Kill a Mockingbird", author: "Harper Lee", isbn: "9780061120084", coverImageUrl: "https://covers.openlibrary.org/b/isbn/9780061120084-L.jpg"),
        .init(title: "The Great Gatsby", author: "F. Scott Fitzgerald", isbn: "9780743273565", coverImageUrl: "https://covers.openlibrary.org/b/isbn/9780743273565-L.jpg"),
        .init(title: "Brave New World", author: "Aldous Huxley", isbn: "9780060850524", coverImageUrl: "https://covers.openlibrary.org/b/isbn/9780060850524-L.jpg"),
        .init(title: "The Catcher in the Rye", author: "J. D. Salinger", isbn: "9780316769488", coverImageUrl: "https://covers.openlibrary.org/b/isbn/9780316769488-L.jpg"),
        .init(title: "Crime and Punishment", author: "Fyodor Dostoevsky", isbn: "9780143058144", coverImageUrl: "https://covers.openlibrary.org/b/isbn/9780143058144-L.jpg"),
        .init(title: "Moby-Dick", author: "Herman Melville", isbn: "9780142437247", coverImageUrl: "https://covers.openlibrary.org/b/isbn/9780142437247-L.jpg"),
        .init(title: "Jane Eyre", author: "Charlotte Brontë", isbn: "9780141441146", coverImageUrl: "https://covers.openlibrary.org/b/isbn/9780141441146-L.jpg"),
        .init(title: "Wuthering Heights", author: "Emily Brontë", isbn: "9780141439556", coverImageUrl: "https://covers.openlibrary.org/b/isbn/9780141439556-L.jpg"),
        .init(title: "The Odyssey", author: "Homer", isbn: "9780140268867", coverImageUrl: "https://covers.openlibrary.org/b/isbn/9780140268867-L.jpg"),
        .init(title: "Meditations", author: "Marcus Aurelius", isbn: "9780812968255", coverImageUrl: "https://covers.openlibrary.org/b/isbn/9780812968255-L.jpg"),
        .init(title: "The Art of War", author: "Sun Tzu", isbn: "9781590302255", coverImageUrl: "https://covers.openlibrary.org/b/isbn/9781590302255-L.jpg"),
        .init(title: "Walden", author: "Henry David Thoreau", isbn: "9780691096124", coverImageUrl: "https://covers.openlibrary.org/b/isbn/9780691096124-L.jpg"),
        .init(title: "Frankenstein", author: "Mary Shelley", isbn: "9780141439471", coverImageUrl: "https://covers.openlibrary.org/b/isbn/9780141439471-L.jpg"),
        .init(title: "The Picture of Dorian Gray", author: "Oscar Wilde", isbn: "9780141439570", coverImageUrl: "https://covers.openlibrary.org/b/isbn/9780141439570-L.jpg"),
        .init(title: "A Tale of Two Cities", author: "Charles Dickens", isbn: "9780141439600", coverImageUrl: "https://covers.openlibrary.org/b/isbn/9780141439600-L.jpg"),
        .init(title: "Great Expectations", author: "Charles Dickens", isbn: "9780141439563", coverImageUrl: "https://covers.openlibrary.org/b/isbn/9780141439563-L.jpg"),
        .init(title: "The Brothers Karamazov", author: "Fyodor Dostoevsky", isbn: "9780374528379", coverImageUrl: "https://covers.openlibrary.org/b/isbn/9780374528379-L.jpg"),
        .init(title: "Anna Karenina", author: "Leo Tolstoy", isbn: "9780143035008", coverImageUrl: "https://covers.openlibrary.org/b/isbn/9780143035008-L.jpg"),
        .init(title: "War and Peace", author: "Leo Tolstoy", isbn: "9781400079988", coverImageUrl: "https://covers.openlibrary.org/b/isbn/9781400079988-L.jpg"),
        .init(title: "Don Quixote", author: "Miguel de Cervantes", isbn: "9780060934347", coverImageUrl: "https://covers.openlibrary.org/b/isbn/9780060934347-L.jpg"),
        .init(title: "The Iliad", author: "Homer", isbn: "9780140275360", coverImageUrl: "https://covers.openlibrary.org/b/isbn/9780140275360-L.jpg"),
        .init(title: "Fahrenheit 451", author: "Ray Bradbury", isbn: "9781451673319", coverImageUrl: "https://covers.openlibrary.org/b/isbn/9781451673319-L.jpg"),
        .init(title: "Of Mice and Men", author: "John Steinbeck", isbn: "9780140177398", coverImageUrl: "https://covers.openlibrary.org/b/isbn/9780140177398-L.jpg")
    ]

    static func random(count: Int = 5, excluding: Set<String> = []) -> [TrendingBook] {
        let pool = all.filter { !excluding.contains($0.title) }
        return Array(pool.shuffled().prefix(count))
    }
}
