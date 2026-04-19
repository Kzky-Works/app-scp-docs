import SwiftUI
#if canImport(UIKit)
import UIKit
#endif

/// ホームダッシュボード用の先頭アイコン（SF Symbols またはアセット）。
enum SectionTileLeading: Equatable {
    case none
    case systemSymbol(String)
    case asset(String)
}

/// ダッシュボード用タイル（FoundationCard ＋ 等幅ラベル）。
struct SectionTile: View {
    let title: String
    let subtitle: String
    var leading: SectionTileLeading = .none
    /// アーカイヴなど、ホームの主タイトルを一段大きくする。
    var emphasizeTitle: Bool = false
    /// `emphasizeTitle` 時に `title2` の約 2 倍（Dynamic Type 連動）で主タイトルを表示する。
    var archiveTitleDoubleSize: Bool = false
    var isWide: Bool = false
    var style: FoundationCardStyle = .standard
    /// タイル上部の等幅バッジ（例: `01 • ARCHIVE [JP]`）。
    var badge: String?
    /// `nil` のときは全体タップを付けず、埋め込み UI のみとする。
    var onTap: (() -> Void)?
    /// 親から高さが与えられたときに下方向へ伸ばし、カード面を埋める。
    var stretchVertically: Bool = false

    private let accessoryView: AnyView

    init(
        title: String,
        subtitle: String,
        leading: SectionTileLeading = .none,
        emphasizeTitle: Bool = false,
        archiveTitleDoubleSize: Bool = false,
        isWide: Bool = false,
        style: FoundationCardStyle = .standard,
        badge: String? = nil,
        stretchVertically: Bool = false,
        onTap: (() -> Void)?,
        @ViewBuilder accessory: @escaping () -> some View = { EmptyView() }
    ) {
        self.title = title
        self.subtitle = subtitle
        self.leading = leading
        self.emphasizeTitle = emphasizeTitle
        self.archiveTitleDoubleSize = archiveTitleDoubleSize
        self.isWide = isWide
        self.style = style
        self.badge = badge
        self.stretchVertically = stretchVertically
        self.onTap = onTap
        self.accessoryView = AnyView(accessory())
    }

    private var titleColor: Color {
        switch style {
        case .standard, .indexGrid:
            AppTheme.textPrimary
        case .inverted:
            AppTheme.textOnInverted
        case .danger:
            Color.white
        }
    }

    private var subtitleColor: Color {
        switch style {
        case .standard, .indexGrid:
            AppTheme.textSecondary
        case .inverted:
            AppTheme.textOnInverted.opacity(0.82)
        case .danger:
            Color.white.opacity(0.88)
        }
    }

    private var badgeColor: Color {
        switch style {
        case .standard, .indexGrid:
            AppTheme.textSecondary
        case .inverted:
            AppTheme.textOnInverted.opacity(0.72)
        case .danger:
            Color.white.opacity(0.82)
        }
    }

    private var titleFont: Font {
        if archiveTitleDoubleSize {
#if canImport(UIKit)
            let base = UIFont.preferredFont(forTextStyle: .title2)
            let doubled = base.withSize(base.pointSize * 2)
            let scaled = UIFontMetrics(forTextStyle: .title2).scaledFont(for: doubled)
            return Font(scaled)
#else
            return .largeTitle.weight(.semibold)
#endif
        }
        return emphasizeTitle ? .title2.weight(.semibold) : .title3.weight(.semibold)
    }

    var body: some View {
        let core = VStack(alignment: .leading, spacing: isWide ? 10 : 8) {
            if let badge, !badge.isEmpty {
                Text(badge)
                    .font(.caption2.weight(.semibold))
                    .foregroundStyle(badgeColor)
                    .monospaced()
            }
            HStack(alignment: .top, spacing: leading == .none ? 0 : 10) {
                leadingIconView

                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(titleFont)
                        .foregroundStyle(titleColor)
                        .lineLimit(archiveTitleDoubleSize ? 3 : nil)
                        .minimumScaleFactor(archiveTitleDoubleSize ? 0.45 : 1)
                        .multilineTextAlignment(.leading)
                    Text(subtitle)
                        .font(.caption.weight(.medium))
                        .foregroundStyle(subtitleColor)
                        .multilineTextAlignment(.leading)
                }
                .frame(maxWidth: .infinity, alignment: .leading)

                if onTap != nil {
                    Image(systemName: "chevron.right")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(style == .danger ? Color.white.opacity(0.85) : AppTheme.textSecondary.opacity(0.75))
                }
            }

            accessoryView

            if stretchVertically {
                Spacer(minLength: 0)
            }
        }
        .padding(14)
        .frame(maxWidth: .infinity, maxHeight: stretchVertically ? .infinity : nil, alignment: .topLeading)
        .foundationCard(style: style)

        Group {
            if let onTap {
                Button(action: onTap) {
                    core
                }
                .frame(maxWidth: .infinity, maxHeight: stretchVertically ? .infinity : nil, alignment: .topLeading)
                .buttonStyle(DashboardPressButtonStyle())
            } else {
                core
            }
        }
    }

    @ViewBuilder
    private var leadingIconView: some View {
        switch leading {
        case .none:
            EmptyView()
        case .systemSymbol(let name):
            Image(systemName: name)
                .font(.title2.weight(.semibold))
                .foregroundStyle(iconTint)
                .frame(width: 28, alignment: .center)
        case .asset(let name):
            Image(name)
                .resizable()
                .renderingMode(.original)
                .scaledToFit()
                .frame(width: 28, height: 28)
        }
    }

    private var iconTint: Color {
        switch style {
        case .standard, .indexGrid:
            AppTheme.textPrimary
        case .inverted:
            AppTheme.textOnInverted
        case .danger:
            Color.white
        }
    }
}
