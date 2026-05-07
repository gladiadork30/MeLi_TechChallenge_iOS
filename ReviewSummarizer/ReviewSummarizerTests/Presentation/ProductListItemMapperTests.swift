import Testing
@testable import ReviewSummarizer

@Suite("ProductListItemMapper")
struct ProductListItemMapperTests {
    let avg = ComputeAverageRatingUseCase()

    @Test("Producto con [5,4,3] → ratingDisplay = .value(\"4.0\") (RF-03)")
    func ratingFormatted() {
        let p = Product(id: "p", title: "t", imageURL: nil, reviews: [
            .fixture(rating: 5), .fixture(rating: 4), .fixture(rating: 3)
        ])

        let ui = ProductListItemMapper.map(p, cachedSummaryIds: [], averageRating: avg)
        #expect(ui.ratingDisplay == .value("4.0"))
        #expect(ui.reviewCount == 3)
    }

    @Test("Producto sin reviews → .unrated")
    func unrated() {
        let p = Product(id: "p", title: "t", imageURL: nil, reviews: [])
        let ui = ProductListItemMapper.map(p, cachedSummaryIds: [], averageRating: avg)
        #expect(ui.ratingDisplay == .unrated)
        #expect(ui.reviewCount == 0)
    }

    @Test("cachedSummaryIds contiene id → hasCachedSummary=true (RF-10)")
    func hasCached() {
        let p = Product.fixture(id: "p1")
        let ui = ProductListItemMapper.map(p, cachedSummaryIds: ["p1"], averageRating: avg)
        #expect(ui.hasCachedSummary == true)
    }

    @Test("cachedSummaryIds NO contiene id → hasCachedSummary=false")
    func noCached() {
        let p = Product.fixture(id: "p1")
        let ui = ProductListItemMapper.map(p, cachedSummaryIds: ["other"], averageRating: avg)
        #expect(ui.hasCachedSummary == false)
    }
}
