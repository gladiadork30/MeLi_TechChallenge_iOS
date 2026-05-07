import Testing
import Foundation
@testable import ReviewSummarizer

@Suite("ProductDTO+Mapping (mapping defensivo)")
struct ProductDTOMappingTests {

    @Test("imageUrl=nil → imageURL=nil")
    func nilImageURL() {
        let dto = ProductDTO(id: "p", title: "t", imageUrl: nil, reviews: [])
        #expect(dto.toDomain().imageURL == nil)
    }

    @Test("imageUrl vacío → imageURL=nil")
    func emptyImageURL() {
        let dto = ProductDTO(id: "p", title: "t", imageUrl: "", reviews: [])
        #expect(dto.toDomain().imageURL == nil)
    }

    @Test("rating=0 → review filtrada")
    func ratingTooLow() {
        let dto = ProductDTO(id: "p", title: "t", imageUrl: nil, reviews: [
            ReviewDTO(author: "a", rating: 0, text: "x")
        ])
        #expect(dto.toDomain().reviews.isEmpty)
    }

    @Test("rating=6 → review filtrada")
    func ratingTooHigh() {
        let dto = ProductDTO(id: "p", title: "t", imageUrl: nil, reviews: [
            ReviewDTO(author: "a", rating: 6, text: "x")
        ])
        #expect(dto.toDomain().reviews.isEmpty)
    }

    @Test("reviews=nil → []")
    func nilReviews() {
        let dto = ProductDTO(id: "p", title: "t", imageUrl: nil, reviews: nil)
        #expect(dto.toDomain().reviews.isEmpty)
    }

    @Test("Mix válido e inválido → se conservan los válidos")
    func mixValidAndInvalid() {
        let dto = ProductDTO(id: "p", title: "t", imageUrl: nil, reviews: [
            ReviewDTO(author: "ok", rating: 4, text: "ok"),
            ReviewDTO(author: "bad", rating: 9, text: "bad"),
            ReviewDTO(author: "ok2", rating: 1, text: "ok2"),
        ])
        let domain = dto.toDomain()
        #expect(domain.reviews.map(\.author) == ["ok", "ok2"])
    }
}
