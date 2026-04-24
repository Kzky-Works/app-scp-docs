import SwiftUI

/// 記事 WebView の文字サイズ注入が完了するまでの待機用。モノクローム（グレー系）の端末風ローディング。
struct SCPArticleReaderLoadingOverlay: View {
    @State private var sweepPhase: CGFloat = 0

    private var trackColor: Color {
        AppTheme.textSecondary.opacity(colorScheme == .dark ? 0.35 : 0.22)
    }

    private var fillColor: Color {
        AppTheme.textSecondary.opacity(colorScheme == .dark ? 0.75 : 0.5)
    }

    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        VStack(spacing: 18) {
            Text(String(localized: String.LocalizationValue(LocalizationKey.articleReaderTypographyLoadingTitle)))
                .font(.system(.caption, design: .monospaced).weight(.semibold))
                .tracking(1.0)
                .foregroundStyle(AppTheme.textSecondary)
                .multilineTextAlignment(.center)

            Text(String(localized: String.LocalizationValue(LocalizationKey.articleReaderTypographyLoadingSubtitle)))
                .font(.system(.caption2, design: .monospaced))
                .foregroundStyle(AppTheme.textSecondary.opacity(0.72))
                .multilineTextAlignment(.center)

            GeometryReader { geo in
                let w = geo.size.width
                let segmentW = max(w * 0.34, 24)
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(trackColor)
                    Capsule()
                        .fill(fillColor)
                        .frame(width: segmentW)
                        .offset(x: (w - segmentW) * sweepPhase)
                }
            }
            .frame(height: 5)
            .frame(maxWidth: 240)
        }
        .accessibilityElement(children: .combine)
        .padding(.horizontal, 28)
        .onAppear {
            sweepPhase = 0
            withAnimation(.easeInOut(duration: 1.05).repeatForever(autoreverses: true)) {
                sweepPhase = 1
            }
        }
    }
}
