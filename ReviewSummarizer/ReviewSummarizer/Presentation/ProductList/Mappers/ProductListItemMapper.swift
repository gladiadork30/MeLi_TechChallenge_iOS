import Foundation

/// Mapper Product → ProductListItemUIModel.
///
/// Inyecta el `ComputeAverageRatingUseCase` y el set de productIds con
/// resumen cacheado para alimentar `RatingDisplay` y `hasCachedSummary`.
enum ProductListItemMapper {
    static func map(
        _ product: Product,
        cachedSummaryIds: Set<String>,
        averageRating: ComputeAverageRatingUseCase
    ) -> ProductListItemUIModel {
        let display: ProductListItemUIModel.RatingDisplay
        switch averageRating.execute(reviews: product.reviews) {
        case .value(let avg):
            display = .value(String(format: "%.1f", avg))
        case .unrated:
            display = .unrated
        }

        return ProductListItemUIModel(
            id: product.id,
            title: product.title,
            imageURL: product.imageURL,
            reviewCount: product.reviews.count,
            ratingDisplay: display,
            hasCachedSummary: cachedSummaryIds.contains(product.id)
        )
    }
}
