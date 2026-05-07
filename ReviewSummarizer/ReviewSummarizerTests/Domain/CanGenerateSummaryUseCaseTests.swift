import Testing
@testable import ReviewSummarizer

@Suite("CanGenerateSummaryUseCase (CA-RF-05, RN-01, S-03)")
struct CanGenerateSummaryUseCaseTests {
    let sut = CanGenerateSummaryUseCase()

    @Test("0 → false")  func zero()      { #expect(sut.execute(reviewCount: 0)  == false) }
    @Test("1 → false")  func one()       { #expect(sut.execute(reviewCount: 1)  == false) }
    @Test("5 → false")  func fiveBoundary() { #expect(sut.execute(reviewCount: 5)  == false) }
    @Test("6 → true")   func sixBoundary()  { #expect(sut.execute(reviewCount: 6)  == true) }
    @Test("20 → true")  func twenty()    { #expect(sut.execute(reviewCount: 20) == true) }

    @Test("threshold expuesto = 5")
    func thresholdConstant() {
        #expect(CanGenerateSummaryUseCase.threshold == 5)
    }
}
