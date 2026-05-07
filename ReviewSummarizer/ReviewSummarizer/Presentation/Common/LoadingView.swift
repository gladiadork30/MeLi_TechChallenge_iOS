import SwiftUI

/// Vista de loading reutilizable (RF-14).
struct LoadingView: View {
    let label: String?

    init(label: String? = nil) {
        self.label = label
    }

    var body: some View {
        VStack(spacing: 12) {
            ProgressView()
                .controlSize(.large)
            if let label {
                Text(label)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .accessibilityElement(children: .combine)
        .accessibilityLabel(label ?? String(localized: "common.loading"))
    }
}

#Preview("Sin label") {
    LoadingView()
}

#Preview("Con label") {
    LoadingView(label: "Cargando productos…")
}
