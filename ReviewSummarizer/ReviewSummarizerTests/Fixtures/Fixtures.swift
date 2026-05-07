import Foundation
@testable import ReviewSummarizer

extension Review {
    static func fixture(
        author: String = "Test User",
        rating: Int = 4,
        text: String = "Texto de prueba."
    ) -> Review {
        Review(author: author, rating: rating, text: text)
    }
}

extension Product {
    static func fixture(
        id: String = "p_test",
        title: String = "Producto Test",
        imageURL: URL? = URL(string: "http://localhost/img.jpg"),
        reviewCount: Int = 6,
        rating: Int = 4
    ) -> Product {
        let reviews = (0..<reviewCount).map { Review.fixture(author: "User\($0)", rating: rating) }
        return Product(id: id, title: title, imageURL: imageURL, reviews: reviews)
    }
}

extension ReviewSummary {
    static func fixture(
        productId: String = "p_test",
        sentiment: Sentiment = .positive,
        strengths: [String] = ["Bien sonido", "Buena batería"],
        weaknesses: [String] = ["Carga lenta"],
        tagline: String = "Producto sólido para uso diario.",
        generatedAt: Date = Date(timeIntervalSince1970: 1_700_000_000)
    ) -> ReviewSummary {
        ReviewSummary(
            productId: productId,
            sentiment: sentiment,
            strengths: strengths,
            weaknesses: weaknesses,
            tagline: tagline,
            generatedAt: generatedAt
        )
    }
}
