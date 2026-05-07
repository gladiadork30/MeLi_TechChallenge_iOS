import Testing
@testable import ReviewSummarizer

@Suite("ComputeAverageRatingUseCase")
struct ComputeAverageRatingUseCaseTests {
    let sut = ComputeAverageRatingUseCase()

    @Test("[5,4,3] → 4.0 (CA-RF-03)")
    func threeReviews() {
        let reviews = [Review.fixture(rating: 5), .fixture(rating: 4), .fixture(rating: 3)]
        #expect(sut.execute(reviews: reviews) == .value(4.0))
    }

    @Test("[] → .unrated (CA-RF-03)")
    func empty() {
        #expect(sut.execute(reviews: []) == .unrated)
    }

    @Test("[4] → 4.0 (single review)")
    func singleReview() {
        #expect(sut.execute(reviews: [.fixture(rating: 4)]) == .value(4.0))
    }

    @Test("[5,4] → 4.5 (1-decimal rounding)")
    func roundingHalf() {
        let reviews = [Review.fixture(rating: 5), .fixture(rating: 4)]
        #expect(sut.execute(reviews: reviews) == .value(4.5))
    }

    @Test("[4,4,3] → 3.7 (1-decimal rounding)")
    func roundingThird() {
        let reviews = [Review.fixture(rating: 4), .fixture(rating: 4), .fixture(rating: 3)]
        // 11/3 = 3.6666… → 3.7
        #expect(sut.execute(reviews: reviews) == .value(3.7))
    }
}
