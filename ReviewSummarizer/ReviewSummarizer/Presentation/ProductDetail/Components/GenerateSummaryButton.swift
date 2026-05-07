import SwiftUI

/// Botón contextual de generación / regeneración de resumen.
///
/// Resuelve título, habilitación y mensaje informativo a partir del
/// `SummaryUIState` (RF-05, RF-12).
struct GenerateSummaryButton: View {
    let state: SummaryUIState
    let generate: () -> Void
    let regenerate: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            mainButton
            if let info = informationalMessage {
                Text(info)
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
        }
    }

    @ViewBuilder
    private var mainButton: some View {
        switch state {
        case .none:
            Button(action: generate) {
                Label(String(localized: "summary.generate"), systemImage: "wand.and.stars")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)

        case .generating:
            Button(action: {}) {
                HStack {
                    ProgressView()
                        .controlSize(.small)
                    Text("summary.generating")
                }
                .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .disabled(true)

        case .available:
            Button(action: regenerate) {
                Label(String(localized: "summary.regenerate"), systemImage: "arrow.clockwise")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.bordered)

        case .error:
            Button(action: regenerate) {
                Label(String(localized: "common.retry"), systemImage: "arrow.clockwise")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)

        case .unsupported, .disabledByThreshold:
            Button(action: {}) {
                Label(String(localized: "summary.generate"), systemImage: "wand.and.stars")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.bordered)
            .disabled(true)
        }
    }

    private var informationalMessage: String? {
        switch state {
        case .disabledByThreshold(let needed):
            return String(localized: "summary.disabled_threshold \(needed)")
        case .unsupported:
            return String(localized: "summary.unavailable")
        case .error(let err):
            switch err {
            case .generationFailed:
                return String(localized: "summary.error_generic")
            case .contextOverflow:
                return String(localized: "summary.error_overflow")
            }
        case .none, .generating, .available:
            return nil
        }
    }
}

#Preview("none") {
    GenerateSummaryButton(state: .none, generate: {}, regenerate: {})
        .padding()
}

#Preview("generating") {
    GenerateSummaryButton(state: .generating, generate: {}, regenerate: {})
        .padding()
}

#Preview("available") {
    GenerateSummaryButton(
        state: .available(.init(productId: "p", sentiment: .positive, strengths: [], weaknesses: [], tagline: "Buen producto.", generatedAt: .now)),
        generate: {}, regenerate: {}
    ).padding()
}

#Preview("error") {
    GenerateSummaryButton(state: .error(.generationFailed), generate: {}, regenerate: {})
        .padding()
}

#Preview("unsupported") {
    GenerateSummaryButton(state: .unsupported(reason: .deviceNotEligible), generate: {}, regenerate: {})
        .padding()
}

#Preview("threshold") {
    GenerateSummaryButton(state: .disabledByThreshold(needed: 6), generate: {}, regenerate: {})
        .padding()
}
