import Testing
@testable import ReviewSummarizer

@Suite("Entities smoke")
struct EntitiesSmokeTests {

    @Test("Sentiment(rawValue:) cubre los 3 casos")
    func sentimentRawValues() {
        #expect(Sentiment(rawValue: "positive") == .positive)
        #expect(Sentiment(rawValue: "neutral")  == .neutral)
        #expect(Sentiment(rawValue: "negative") == .negative)
        #expect(Sentiment(rawValue: "??")       == nil)
    }

    @Test("ReviewSummary.fixture respeta tope de 140 chars en tagline")
    func taglineLengthFixture() {
        let s = ReviewSummary.fixture()
        #expect(s.tagline.count <= 140)
    }
}
