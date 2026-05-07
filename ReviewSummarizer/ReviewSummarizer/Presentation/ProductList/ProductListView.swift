import SwiftUI

/// Pantalla "Lista de Productos" (RF-02, RF-13, RF-14, RF-16).
///
/// Maneja los 4 estados (loading/success/empty/error) con los componentes
/// comunes y soporta pull-to-refresh. La construcción del detalle se
/// inyecta como closure para no acoplar la lista al CompositionRoot.
struct ProductListView: View {
    @State private var viewModel: ProductListViewModel
    private let detailFactory: (Product) -> AnyView

    init(viewModel: ProductListViewModel, detailFactory: @escaping (Product) -> AnyView) {
        self._viewModel = State(initialValue: viewModel)
        self.detailFactory = detailFactory
    }

    var body: some View {
        NavigationStack {
            content
                .navigationTitle(Text("list.title"))
                .navigationDestination(for: Product.self) { product in
                    detailFactory(product)
                }
        }
        .task {
            viewModel.load()
        }
        .onDisappear {
            viewModel.cancel()
        }
    }

    @ViewBuilder
    private var content: some View {
        switch viewModel.state {
        case .loading:
            LoadingView(label: String(localized: "list.loading"))

        case .empty:
            EmptyStateView(
                title: String(localized: "list.empty_title"),
                message: String(localized: "list.empty_message"),
                action: .init(label: String(localized: "common.retry"), perform: viewModel.load)
            )

        case .error(let message):
            ErrorView(message: message, retry: viewModel.load)

        case .success(let items, _):
            successList(items: items)
        }
    }

    private func successList(items: [ProductListItemUIModel]) -> some View {
        List(items) { item in
            NavigationLink(value: viewModel.product(withId: item.id)) {
                ProductRowView(item: item)
            }
            .disabled(viewModel.product(withId: item.id) == nil)
        }
        .listStyle(.plain)
        .refreshable {
            await viewModel.refresh()
        }
        .overlay(alignment: .bottom) {
            if let message = viewModel.refreshErrorMessage {
                refreshErrorBanner(message)
            }
        }
    }

    private func refreshErrorBanner(_ message: String) -> some View {
        Text(message)
            .font(.footnote)
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(.ultraThinMaterial, in: Capsule())
            .padding(.bottom, 12)
            .transition(.move(edge: .bottom).combined(with: .opacity))
    }
}

