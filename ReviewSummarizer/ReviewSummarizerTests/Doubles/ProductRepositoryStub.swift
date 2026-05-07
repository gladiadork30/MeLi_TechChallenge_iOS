import Foundation
@testable import ReviewSummarizer

/// Stub determinista de `ProductRepository`. Inyectable: éxito o error.
actor ProductRepositoryStub: ProductRepository {
    private var result: Result<[Product], any Error & Sendable>

    init(products: [Product] = []) {
        self.result = .success(products)
    }

    init(error: any Error & Sendable) {
        self.result = .failure(error)
    }

    func setResult(_ result: Result<[Product], any Error & Sendable>) {
        self.result = result
    }

    func fetchProducts() async throws -> [Product] {
        switch result {
        case .success(let products): return products
        case .failure(let error):    throw error
        }
    }
}
