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
            // Placeholder: se reemplaza por `ProductListView(viewModel:)` en Fase 8 (T-085).
            BootstrapPlaceholderView(baseURL: composition.configuration.backendBaseURL)
        }
        .modelContainer(composition.modelContainer)
    }
}

/// Vista placeholder que confirma que el CompositionRoot levantó OK.
/// Se elimina cuando entre `ProductListView` (T-085).
private struct BootstrapPlaceholderView: View {
    let baseURL: URL

    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: "wand.and.stars")
                .font(.system(size: 48))
                .foregroundStyle(.tint)
            Text("ReviewSummarizer")
                .font(.title.bold())
            Text("Lista de productos próximamente")
                .foregroundStyle(.secondary)
            Text("Backend: \(baseURL.absoluteString)")
                .font(.caption)
                .foregroundStyle(.tertiary)
        }
        .padding()
    }
}
