import SwiftUI
import SwiftData

@main
struct ReviewSummarizerApp: App {
    @State private var composition: CompositionRoot

    init() {
        let configuration = AppConfiguration.load()
        do {
            self._composition = State(initialValue: try CompositionRoot(configuration: configuration))
        } catch {
            preconditionFailure("No se pudo inicializar el CompositionRoot: \(error)")
        }
    }

    var body: some Scene {
        WindowGroup {
            ProductListView(
                viewModel: composition.makeProductListViewModel(),
                detailFactory: { product in
                    AnyView(composition.makeProductDetailView(product: product))
                }
            )
        }
        .modelContainer(composition.modelContainer)
    }
}
