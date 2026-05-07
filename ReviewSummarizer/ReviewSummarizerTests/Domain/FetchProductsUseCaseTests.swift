import Testing
import Foundation
@testable import ReviewSummarizer

@Suite("FetchProductsUseCase")
struct FetchProductsUseCaseTests {
    private struct AnyError: Error & Sendable {}

    @Test("Éxito → devuelve lista del repositorio")
    func happyPath() async throws {
        let products = [Product.fixture(id: "p1"), .fixture(id: "p2")]
        let repo = ProductRepositoryStub(products: products)
        let sut = FetchProductsUseCase(repository: repo)

        let result = try await sut.execute()
        #expect(result.map(\.id) == ["p1", "p2"])
    }

    @Test("Lista vacía → devuelve []")
    func empty() async throws {
        let repo = ProductRepositoryStub(products: [])
        let sut = FetchProductsUseCase(repository: repo)

        let result = try await sut.execute()
        #expect(result.isEmpty)
    }

    @Test("Error del repositorio → se propaga")
    func errorPropagation() async {
        let repo = ProductRepositoryStub(error: AnyError())
        let sut = FetchProductsUseCase(repository: repo)

        await #expect(throws: AnyError.self) {
            _ = try await sut.execute()
        }
    }
}
