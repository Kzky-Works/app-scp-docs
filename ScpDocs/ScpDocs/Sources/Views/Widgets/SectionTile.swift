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

// MARK: - カード内ラベル（`foundationCard` が注入する環境で色を解決）

private struct SectionTileCardLabels: View {
    @Environment(\.foundationCardTextPrimary) private var cardTextPrimary
    @Environment(\.foundationCardTextSecondary) private var cardTextSecondary

    let title: String
    let subtitle: String
    let badge: String?
    let leading: SectionTileLeading
    let archiveTitleDoubleSize: Bool
    let isWide: Bool
    let style: FoundationCardStyle
    let showsTrailingChevron: Bool
    let onTap: (() -> Void)?
    let titleFont: Font
    let accessoryView: AnyView

    private var stretchVertically: Bool

    init(
        title: String,
        subtitle: String,
        badge: String?,
        leading: SectionTileLeading,
        archiveTitleDoubleSize: Bool,
        isWide: Bool,
        style: FoundationCardStyle,
        showsTrailingChevron: Bool,
        onTap: (() -> Void)?,
        titleFont: Font,
        stretchVertically: Bool,
        accessoryView: AnyView
    ) {
        self.title = title
        self.subtitle = subtitle
        self.badge = badge
        self.leading = leading
        self.archiveTitleDoubleSize = archiveTitleDoubleSize
        self.isWide = isWide
        self.style = style
        self.showsTrailingChevron = showsTrailingChevron
        self.onTap = onTap
        self.titleFont = titleFont
        self.stretchVertically = stretchVertically
        self.accessoryView = accessoryView
    }

    var body: some View {
        VStack(alignment: .leading, spacing: isWide ? 10 : 8) {
            if let badge, !badge.isEmpty {
                Text(badge)
                    .font(.caption2.weight(.semibold))
                    .foregroundStyle(cardTextSecondary.opacity(style == .inverted ? 0.92 : 1))
                    .monospaced()
            }
            HStack(alignment: .top, spacing: leading == .none ? 0 : 10) {
                leadingIconView

                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(titleFont)
                        .foregroundStyle(cardTextPrimary)
                        .lineLimit(archiveTitleDoubleSize ? 3 : nil)
                        .minimumScaleFactor(archiveTitleDoubleSize ? 0.45 : 1)
                        .multilineTextAlignment(.leading)
                    if !subtitle.isEmpty {
                        Text(subtitle)
                            .font(.caption.weight(.medium))
                            .foregroundStyle(cardTextSecondary)
                            .multilineTextAlignment(.leading)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)

                if onTap != nil, showsTrailingChevron {
                    Image(systemName: "chevron.right")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(cardTextSecondary.opacity(0.75))
                }
            }

            accessoryView

            if stretchVertically {
                Spacer(minLength: 0)
            }
        }
        .padding(14)
        .frame(maxWidth: .infinity, maxHeight: stretchVertically ? .infinity : nil, alignment: .topLeading)
    }

    @ViewBuilder
    private var leadingIconView: some View {
        switch leading {
        case .none:
            EmptyView()
        case .systemSymbol(let name):
            Image(systemName: name)
                .font(.title2.weight(.semibold))
                .foregroundStyle(cardTextPrimary)
                .frame(width: 28, alignment: .center)
        case .asset(let name):
            Image(name)
                .resizable()
                .renderingMode(.original)
                .scaledToFit()
                .frame(width: 28, height: 28)
        }
    }
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
    /// SCP-JP（01）: ダークで `specialCardChrome`（斜線）を重ねる。
    var scpJapanSpecialChrome: Bool = false
    /// タイル上部の等幅バッジ（例: `01 • ARCHIVE [JP]`）。
    var badge: String?
    /// `nil` のときは全体タップを付けず、埋め込み UI のみとする。
    var onTap: (() -> Void)?
    /// 親から高さが与えられたときに下方向へ伸ばし、カード面を埋める。
    var stretchVertically: Bool = false
    /// `onTap` があるときに右端へ付ける `chevron.right` を表示するか。
    var showsTrailingChevron: Bool = true
    /// 指定時は `emphasizeTitle` / `archiveTitleDoubleSize` より優先して主タイトルに使う（例: ホームの Wikidot 寄せスタック）。
    private let titleFontOverride: Font?

    private let accessoryView: AnyView

    init(
        title: String,
        subtitle: String,
        leading: SectionTileLeading = .none,
        emphasizeTitle: Bool = false,
        archiveTitleDoubleSize: Bool = false,
        isWide: Bool = false,
        style: FoundationCardStyle = .standard,
        scpJapanSpecialChrome: Bool = false,
        badge: String? = nil,
        stretchVertically: Bool = false,
        showsTrailingChevron: Bool = true,
        titleFontOverride: Font? = nil,
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
        self.scpJapanSpecialChrome = scpJapanSpecialChrome
        self.badge = badge
        self.stretchVertically = stretchVertically
        self.showsTrailingChevron = showsTrailingChevron
        self.titleFontOverride = titleFontOverride
        self.onTap = onTap
        self.accessoryView = AnyView(accessory())
    }

    private var resolvedTitleFont: Font {
        if let titleFontOverride {
            return titleFontOverride
        }
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
        return emphasizeTitle ? .title.weight(.semibold) : .title3.weight(.semibold)
    }

    var body: some View {
        let chrome = SectionTileCardLabels(
            title: title,
            subtitle: subtitle,
            badge: badge,
            leading: leading,
            archiveTitleDoubleSize: archiveTitleDoubleSize,
            isWide: isWide,
            style: style,
            showsTrailingChevron: showsTrailingChevron,
            onTap: onTap,
            titleFont: resolvedTitleFont,
            stretchVertically: stretchVertically,
            accessoryView: accessoryView
        )
        .foundationCard(style: style)
        .specialCardChrome(isActive: scpJapanSpecialChrome)

        Group {
            if let onTap {
                Button(action: onTap) {
                    chrome
                }
                .frame(maxWidth: .infinity, maxHeight: stretchVertically ? .infinity : nil, alignment: .topLeading)
                .buttonStyle(DashboardPressButtonStyle())
            } else {
                chrome
            }
        }
    }
}
