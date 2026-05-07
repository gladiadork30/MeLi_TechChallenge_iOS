import Testing
import Foundation
@testable import ReviewSummarizer

@Suite("ProductListViewModel")
@MainActor
struct ProductListViewModelTests {
    private struct AnyError: Error & Sendable {}

    private func waitForState(
        _ vm: ProductListViewModel,
        timeoutMs: Int = 1000,
        condition: @MainActor (ProductListUIState) -> Bool
    ) async {
        let stepNs: UInt64 = 10_000_000
        var elapsedMs = 0
        while !condition(vm.state) {
            try? await Task.sleep(nanoseconds: stepNs)
            elapsedMs += 10
            if elapsedMs >= timeoutMs { break }
        }
    }

    @Test("Éxito con productos → estado .success")
    func successPath() async {
        let products = [Product.fixture(id: "p1"), .fixture(id: "p2")]
        let repo = ProductRepositoryStub(products: products)
        let summaryRepo = SummaryRepositorySpy()
        let vm = ProductListViewModel(
            fetchProducts: FetchProductsUseCase(repository: repo),
            summaryRepository: summaryRepo,
            computeAverageRating: ComputeAverageRatingUseCase()
        )

        vm.load()
        await waitForState(vm) { if case .success = $0 { return true } else { return false } }

        guard case let .success(items, _) = vm.state else {
            Issue.record("Esperaba .success, obtuvo \(vm.state)"); return
        }
        #expect(items.map(\.id) == ["p1", "p2"])
    }

    @Test("Respuesta vacía → estado .empty")
    func emptyPath() async {
        let repo = ProductRepositoryStub(products: [])
        let vm = ProductListViewModel(
            fetchProducts: FetchProductsUseCase(repository: repo),
            summaryRepository: SummaryRepositorySpy(),
            computeAverageRating: ComputeAverageRatingUseCase()
        )

        vm.load()
        await waitForState(vm) { $0 == .empty }
        #expect(vm.state == .empty)
    }

    @Test("Error de red → estado .error (CA-RF-13)")
    func errorPath() async {
        let repo = ProductRepositoryStub(error: AnyError())
        let vm = ProductListViewModel(
            fetchProducts: FetchProductsUseCase(repository: repo),
            summaryRepository: SummaryRepositorySpy(),
            computeAverageRating: ComputeAverageRatingUseCase()
        )

        vm.load()
        await waitForState(vm) { if case .error = $0 { return true } else { return false } }
        if case .error = vm.state {
            // ok
        } else {
            Issue.record("Esperaba .error, obtuvo \(vm.state)")
        }
    }

    @Test("Refresh fallido conserva lista anterior y muestra mensaje (CA-RF-16)")
    func refreshFailureKeepsPreviousList() async {
        let products = [Product.fixture(id: "p1")]
        let repo = ProductRepositoryStub(products: products)
        let vm = ProductListViewModel(
            fetchProducts: FetchProductsUseCase(repository: repo),
            summaryRepository: SummaryRepositorySpy(),
            computeAverageRating: ComputeAverageRatingUseCase()
        )

        vm.load()
        await waitForState(vm) { if case .success = $0 { return true } else { return false } }

        // Ahora hacemos fallar el repo y forzamos un refresh.
        await repo.setResult(.failure(AnyError()))
        await vm.refresh()

        // La lista anterior se preserva.
        if case let .success(items, _) = vm.state {
            #expect(items.count == 1)
        } else {
            Issue.record("Esperaba mantener .success tras refresh fallido")
        }
        #expect(vm.refreshErrorMessage != nil)
    }
}
