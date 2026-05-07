import Testing
@testable import ReviewSummarizer

@Suite("PromptBuilder.truncated")
struct PromptBuilderTruncatedTests {

    @Test("Texto largo se trunca preservando inicio")
    func truncatesLongText() {
        let longText = String(repeating: "a", count: 1000)
        let review = Review.fixture(text: longText)

        let result = PromptBuilder.truncated([review], maxCharsPerReview: 600)

        #expect(result.first?.text.count == 600)
        #expect(result.first?.text == String(repeating: "a", count: 600))
    }

    @Test("Texto corto no se modifica")
    func keepsShortText() {
        let shortText = "Texto breve."
        let review = Review.fixture(text: shortText)

        let result = PromptBuilder.truncated([review], maxCharsPerReview: 600)

        #expect(result.first?.text == shortText)
    }

    @Test("Preserva author y rating al truncar")
    func preservesOtherFields() {
        let review = Review.fixture(author: "Ana", rating: 5, text: String(repeating: "x", count: 700))
        let result = PromptBuilder.truncated([review], maxCharsPerReview: 600).first

        #expect(result?.author == "Ana")
        #expect(result?.rating == 5)
        #expect(result?.text.count == 600)
    }
}
