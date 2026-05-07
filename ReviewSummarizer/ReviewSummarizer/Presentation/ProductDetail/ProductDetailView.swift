import SwiftUI

/// Pantalla "Detalle de Producto" (RF-04..RF-12, RF-15, S-01, S-15).
struct ProductDetailView: View {
    @State private var viewModel: ProductDetailViewModel
    private let computeAverageRating: ComputeAverageRatingUseCase

    init(viewModel: ProductDetailViewModel, computeAverageRating: ComputeAverageRatingUseCase) {
        self._viewModel = State(initialValue: viewModel)
        self.computeAverageRating = computeAverageRating
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                header
                summarySection
                Divider()
                reviewsSection
            }
            .padding()
        }
        .navigationTitle(viewModel.product.title)
        .navigationBarTitleDisplayMode(.inline)
        .task {
            await viewModel.onAppear()
        }
        .onDisappear {
            viewModel.onDisappear()
        }
    }

    // MARK: - Header

    private var header: some View {
        VStack(alignment: .leading, spacing: 12) {
            AsyncImage(url: viewModel.product.imageURL) { phase in
                switch phase {
                case .success(let image):
                    image.resizable().scaledToFill()
                case .empty:
                    placeholderImage.overlay(ProgressView())
                case .failure:
                    placeholderImage
                @unknown default:
                    placeholderImage
                }
            }
            .frame(height: 200)
            .frame(maxWidth: .infinity)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .accessibilityLabel(Text("a11y.product_image \(viewModel.product.title)"))

            Text(viewModel.product.title)
                .font(.title2.bold())

            HStack(spacing: 12) {
                let avg = computeAverageRating.execute(reviews: viewModel.product.reviews)
                RatingBadgeView(display: ratingDisplay(from: avg))
                Text("detail.review_count \(viewModel.product.reviews.count)")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
        }
    }

    private var placeholderImage: some View {
        RoundedRectangle(cornerRadius: 12)
            .fill(Color.secondary.opacity(0.15))
            .overlay {
                Image(systemName: "photo")
                    .font(.title)
                    .foregroundStyle(.secondary)
            }
    }

    private func ratingDisplay(from result: AverageRating) -> ProductListItemUIModel.RatingDisplay {
        switch result {
        case .value(let v): return .value(String(format: "%.1f", v))
        case .unrated:      return .unrated
        }
    }

    // MARK: - Summary

    @ViewBuilder
    private var summarySection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("detail.summary_title")
                .font(.headline)

            switch viewModel.summaryState {
            case .available(let summary):
                SummarySectionView(summary: summary)
            case .generating:
                LoadingView(label: String(localized: "summary.generating"))
                    .frame(height: 120)
            case .none, .error, .unsupported, .disabledByThreshold:
                EmptyView()
            }

            GenerateSummaryButton(
                state: viewModel.summaryState,
                generate: viewModel.generateSummary,
                regenerate: viewModel.regenerateSummary
            )
        }
    }

    // MARK: - Reviews

    private var reviewsSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("detail.reviews_title")
                .font(.headline)
            if viewModel.product.reviews.isEmpty {
                Text("detail.reviews_empty")
                    .font(.body)
                    .foregroundStyle(.secondary)
            } else {
                ForEach(Array(viewModel.product.reviews.enumerated()), id: \.offset) { _, review in
                    ReviewRowView(review: review)
                    Divider()
                }
            }
        }
    }
}
