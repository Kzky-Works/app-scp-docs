import SwiftUI

/// ダッシュボード用の硬質タイル（サテンシルバー枠・小さめの角丸）。
struct SectionTile: View {
    let title: String
    let subtitle: String
    let systemImageName: String
    var isWide: Bool = false
    /// `nil` のときは全体タップを付けず、埋め込み UI のみとする。
    var onTap: (() -> Void)?
    private let accessoryView: AnyView

    init(
        title: String,
        subtitle: String,
        systemImageName: String,
        isWide: Bool = false,
        onTap: (() -> Void)?,
        @ViewBuilder accessory: @escaping () -> some View = { EmptyView() }
    ) {
        self.title = title
        self.subtitle = subtitle
        self.systemImageName = systemImageName
        self.isWide = isWide
        self.onTap = onTap
        self.accessoryView = AnyView(accessory())
    }

    private let cornerRadius: CGFloat = 6

    var body: some View {
        VStack(alignment: .leading, spacing: isWide ? 10 : 8) {
            HStack(alignment: .top, spacing: 10) {
                Image(systemName: systemImageName)
                    .font(.title2.weight(.semibold))
                    .foregroundStyle(AppTheme.accentPrimary)
                    .frame(width: 28, alignment: .center)

                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(isWide ? .headline.weight(.semibold) : .subheadline.weight(.semibold))
                        .foregroundStyle(AppTheme.accentPrimary)
                        .multilineTextAlignment(.leading)
                    Text(subtitle)
                        .font(.caption.weight(.medium))
                        .foregroundStyle(AppTheme.accentPrimary.opacity(0.78))
                        .multilineTextAlignment(.leading)
                }
                .frame(maxWidth: .infinity, alignment: .leading)

                if onTap != nil {
                    Image(systemName: "chevron.right")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(AppTheme.accentPrimary.opacity(0.55))
                }
            }

            accessoryView
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(AppTheme.backgroundPrimary)
        .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                .stroke(AppTheme.accentPrimary.opacity(0.55), lineWidth: 1)
        )
        .modifier(OptionalTileTap(onTap: onTap))
    }
}

private struct OptionalTileTap: ViewModifier {
    let onTap: (() -> Void)?

    @ViewBuilder
    func body(content: Content) -> some View {
        if let onTap {
            content
                .contentShape(Rectangle())
                .onTapGesture(perform: onTap)
        } else {
            content
        }
    }
}
