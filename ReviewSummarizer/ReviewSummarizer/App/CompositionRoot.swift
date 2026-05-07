import Foundation
import SwiftData
import SwiftUI

/// Composition Root: arma todas las dependencias de la app sin un framework
/// de DI externo (§3 reglas de dependencia).
///
/// Construido una sola vez al iniciar (`@main App`). Mantiene los singletons
/// implícitos (HTTPClient, ModelContainer, SummarizerService) y use cases
/// que son `Sendable` y baratos de mantener vivos.
///
/// Las factories de ViewModels se agregan a medida que cada feature se
/// implementa (Fase 8/9). Hoy expone solo los building blocks.
@MainActor
final class CompositionRoot {
    // MARK: - Configuración
    let configuration: AppConfiguration

    // MARK: - Persistencia
    let modelContainer: ModelContainer

    // MARK: - Capa Data
    let productRepository: any ProductRepository
    let summaryRepository: any SummaryRepository
    let summarizerService: any SummarizerService

    // MARK: - Use Cases
    let fetchProductsUseCase: FetchProductsUseCase
    let generateSummaryUseCase: GenerateSummaryUseCase
    let getCachedSummaryUseCase: GetCachedSummaryUseCase
    let computeAverageRatingUseCase: ComputeAverageRatingUseCase
    let canGenerateSummaryUseCase: CanGenerateSummaryUseCase

    init(configuration: AppConfiguration) throws {
        self.configuration = configuration

        // Persistencia
        self.modelContainer = try ModelContainerFactory.makePersistent()

        // Networking
        let httpClient: any HTTPClient = URLSessionHTTPClient(baseURL: configuration.backendBaseURL)
        self.productRepository = HTTPProductRepository(client: httpClient)

        // Summary persistence
        self.summaryRepository = SwiftDataSummaryRepository(container: modelContainer)

        // AI on-device
        self.summarizerService = FoundationModelsSummarizerService()

        // Use cases
        self.fetchProductsUseCase = FetchProductsUseCase(repository: productRepository)
        self.generateSummaryUseCase = GenerateSummaryUseCase(
            summarizer: summarizerService,
            repository: summaryRepository
        )
        self.getCachedSummaryUseCase = GetCachedSummaryUseCase(repository: summaryRepository)
        self.computeAverageRatingUseCase = ComputeAverageRatingUseCase()
        self.canGenerateSummaryUseCase = CanGenerateSummaryUseCase()
    }

    // MARK: - View Model factories

    func makeProductListViewModel() -> ProductListViewModel {
        ProductListViewModel(
            fetchProducts: fetchProductsUseCase,
            summaryRepository: summaryRepository,
            computeAverageRating: computeAverageRatingUseCase
        )
    }

    func makeProductDetailViewModel(product: Product) -> ProductDetailViewModel {
        ProductDetailViewModel(
            product: product,
            summarizer: summarizerService,
            getCachedSummary: getCachedSummaryUseCase,
            generateSummaryUseCase: generateSummaryUseCase,
            canGenerateSummary: canGenerateSummaryUseCase
        )
    }

    /// Construye la vista de detalle ya cableada con su VM y dependencias.
    @ViewBuilder
    func makeProductDetailView(product: Product) -> some View {
        ProductDetailView(
            viewModel: makeProductDetailViewModel(product: product),
            computeAverageRating: computeAverageRatingUseCase
        )
    }
}
