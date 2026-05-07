import Foundation
import Observation
import os

/// Estado de la pantalla de lista de productos (RF-14).
enum ProductListUIState: Equatable {
    case loading
    case success(items: [ProductListItemUIModel], products: [Product])
    case empty
    case error(message: String)
}

/// ViewModel de la pantalla de lista de productos (§3, MVVM).
///
/// `@MainActor` por defecto: muta UI state. Las llamadas a use cases /
/// repos viajan a sus actores via async/await.
@MainActor
@Observable
final class ProductListViewModel {
    // MARK: - State observable
    private(set) var state: ProductListUIState = .loading
    private(set) var refreshErrorMessage: String?

    // MARK: - Dependencias
    private let fetchProducts: FetchProductsUseCase
    private let summaryRepository: any SummaryRepository
    private let computeAverageRating: ComputeAverageRatingUseCase

    private var loadTask: Task<Void, Never>?

    init(
        fetchProducts: FetchProductsUseCase,
        summaryRepository: any SummaryRepository,
        computeAverageRating: ComputeAverageRatingUseCase
    ) {
        self.fetchProducts = fetchProducts
        self.summaryRepository = summaryRepository
        self.computeAverageRating = computeAverageRating
    }

    // MARK: - Acciones

    /// Carga inicial. Setea state a `.loading` antes de pegarle al endpoint.
    func load() {
        loadTask?.cancel()
        loadTask = Task { [weak self] in
            guard let self else { return }
            self.state = .loading
            await self.performLoad(isRefresh: false)
        }
    }

    /// Pull-to-refresh. NO setea `.loading`; mantiene la lista anterior visible
    /// y muestra un mensaje transitorio si la nueva carga falla (CA-RF-16).
    func refresh() async {
        await performLoad(isRefresh: true)
    }

    /// Cancela la tarea de carga en curso (RF-15).
    func cancel() {
        loadTask?.cancel()
        loadTask = nil
    }

    // MARK: - Private

    private func performLoad(isRefresh: Bool) async {
        do {
            async let productsTask = fetchProducts.execute()
            async let cachedIdsTask = summaryRepository.fetchAllProductIds()

            let products = try await productsTask
            let cachedIds = (try? await cachedIdsTask) ?? []

            try Task.checkCancellation()

            guard !products.isEmpty else {
                self.state = .empty
                self.refreshErrorMessage = nil
                return
            }

            let items = products.map { product in
                ProductListItemMapper.map(
                    product,
                    cachedSummaryIds: cachedIds,
                    averageRating: computeAverageRating
                )
            }
            self.state = .success(items: items, products: products)
            self.refreshErrorMessage = nil
        } catch is CancellationError {
            // Silencioso: el caller decidió cancelar.
        } catch {
            Logger.ui.error("ProductList load failed: \(error.localizedDescription, privacy: .public)")
            if isRefresh, case .success = self.state {
                // CA-RF-16: si falla el refresh, conservamos la lista previa
                // y exponemos un mensaje transitorio.
                self.refreshErrorMessage = String(localized: "list.refresh_failed")
            } else {
                self.state = .error(message: String(localized: "list.error_message"))
            }
        }
    }

    /// Devuelve el `Product` original asociado a un `id` de UI model.
    /// Usado por la navegación al detalle.
    func product(withId id: String) -> Product? {
        guard case let .success(_, products) = state else { return nil }
        return products.first { $0.id == id }
    }
}
