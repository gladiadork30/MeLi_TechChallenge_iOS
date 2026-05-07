import SwiftUI

/// Badge compacto que muestra el rating promedio o "Sin calificación" (RF-03).
struct RatingBadgeView: View {
    let display: ProductListItemUIModel.RatingDisplay

    var body: some View {
        switch display {
        case .value(let formatted):
            Label {
                Text(formatted)
                    .font(.subheadline.weight(.semibold))
                    .monospacedDigit()
            } icon: {
                Image(systemName: "star.fill")
                    .foregroundStyle(.yellow)
            }
            .accessibilityLabel(Text("rating.value \(formatted)"))
        case .unrated:
            Text("rating.unrated")
                .font(.caption)
                .foregroundStyle(.secondary)
                .accessibilityLabel(Text("rating.unrated"))
        }
    }
}

#Preview("Con valor") {
    RatingBadgeView(display: .value("4.0"))
        .padding()
}

#Preview("Sin calificación") {
    RatingBadgeView(display: .unrated)
        .padding()
}
