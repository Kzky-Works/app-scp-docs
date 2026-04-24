import SwiftUI

// MARK: - Index list chrome（`List` + フローティング・カード行）

extension View {
    /// 索引 `List` 行: 区切り線なし・行間すき・`listRowBackground` でカード面を表示。
    func indexListRowChrome(cardStyle: FoundationCardStyle = .standard) -> some View {
        listRowBackground(IndexListFloatingCardBackground(style: cardStyle))
            .listRowSeparator(.hidden)
            .listRowInsets(EdgeInsets(top: 4, leading: 16, bottom: 4, trailing: 16))
    }

    /// 子階層行（親より左に余白を追加）。
    func indexListRowChromeIndented(extraLeading: CGFloat = 12, cardStyle: FoundationCardStyle = .standard) -> some View {
        listRowBackground(IndexListFloatingCardBackground(style: cardStyle))
            .listRowSeparator(.hidden)
            .listRowInsets(EdgeInsets(top: 4, leading: 16 + extraLeading, bottom: 4, trailing: 16))
    }
}

// MARK: - Index screen shell（ピッカー付き画面でもリスト開始位置を揃える）

/// 索引画面の骨組み: 本文（通常は `List`）と下部アクセサリ（シリーズ／セグメントピッカー等）を縦に並べ、背景を統一する。
struct IndexScreenLayout<Bottom: View, Content: View>: View {
    @ViewBuilder private let content: () -> Content
    @ViewBuilder private let bottomAccessory: () -> Bottom

    init(
        @ViewBuilder content: @escaping () -> Content,
        @ViewBuilder bottomAccessory: @escaping () -> Bottom
    ) {
        self.content = content
        self.bottomAccessory = bottomAccessory
    }

    var body: some View {
        VStack(spacing: 0) {
            content()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            bottomAccessory()
        }
        .background(AppTheme.mainBackground)
    }
}

extension IndexScreenLayout where Bottom == EmptyView {
    init(@ViewBuilder content: @escaping () -> Content) {
        self.init(content: content, bottomAccessory: { EmptyView() })
    }
}

// MARK: - FoundationIndexRow

/// 索引行の情報密度（1 行 / 2 行）。
enum FoundationIndexRowLayout: Sendable {
    /// ガイド等: タイトルのみを 1 行で表示。`subtitle` はレイアウトに使わない。
    case compact
    /// 報告書・カテゴリ等: タイトル + サブタイトル（2 行）。
    case twoLine
}

/// 索引・一覧の標準行。`List` では `embedsCardChrome: false` と `indexListRowChrome()` を組み合わせる。
struct FoundationIndexRow<Trailing: View>: View {
    let layout: FoundationIndexRowLayout
    let title: String
    var subtitle: String?
    /// タイトル行右寄せに表示するオブジェクトクラス（任意・短いラベル想定）。
    var objectClassBadge: String?
    /// 行末に表示するタグ（`showsTags == true` かつ空でないときのみ）。
    var tags: [String]
    var showsTags: Bool
    var leadingSystemImage: String?
    /// 報告書番号行などで数字揃えが必要なとき `true`。
    var monospacedTitleDigits: Bool
    /// `true` のときのみ行内に `foundationCard` を重ねる（`List` 行では通常 `false`）。
    var embedsCardChrome: Bool
    @ViewBuilder private let trailing: () -> Trailing

    init(
        layout: FoundationIndexRowLayout = .twoLine,
        title: String,
        subtitle: String? = nil,
        objectClassBadge: String? = nil,
        tags: [String] = [],
        showsTags: Bool = false,
        leadingSystemImage: String? = nil,
        monospacedTitleDigits: Bool = false,
        embedsCardChrome: Bool = false,
        @ViewBuilder trailing: @escaping () -> Trailing = { EmptyView() }
    ) {
        self.layout = layout
        self.title = title
        self.subtitle = subtitle
        self.objectClassBadge = objectClassBadge
        self.tags = tags
        self.showsTags = showsTags
        self.leadingSystemImage = leadingSystemImage
        self.monospacedTitleDigits = monospacedTitleDigits
        self.embedsCardChrome = embedsCardChrome
        self.trailing = trailing
    }

    var body: some View {
        HStack(alignment: rowAlignment, spacing: 12) {
            if let leadingSystemImage {
                Image(systemName: leadingSystemImage)
                    .font(.title3.weight(.semibold))
                    .foregroundStyle(AppTheme.textPrimary)
                    .frame(width: 28, alignment: .center)
            }

            Group {
                switch layout {
                case .compact:
                    compactTextColumn
                case .twoLine:
                    twoLineTextColumn
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            trailing()
        }
        .padding(.vertical, 10)
        .padding(.horizontal, 4)
        .modifier(OptionalFoundationCardModifier(enabled: embedsCardChrome, style: .standard))
        .contentShape(RoundedRectangle(cornerRadius: AppTheme.cornerRadiusCard, style: .continuous))
    }

    private var rowAlignment: VerticalAlignment {
        layout == .compact ? .center : .top
    }

    private var compactTextColumn: some View {
        titleText
            .lineLimit(1)
    }

    @ViewBuilder
    private var twoLineTextColumn: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack(alignment: .firstTextBaseline, spacing: 8) {
                titleText
                    .frame(maxWidth: .infinity, alignment: .leading)
                if let badge = objectClassBadge?.trimmingCharacters(in: .whitespacesAndNewlines), !badge.isEmpty {
                    Text(badge)
                        .font(.caption2.weight(.heavy))
                        .foregroundStyle(AppTheme.textSecondary)
                        .lineLimit(2)
                        .multilineTextAlignment(.trailing)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(
                            RoundedRectangle(cornerRadius: 6, style: .continuous)
                                .stroke(AppTheme.borderSubtle.opacity(0.85), lineWidth: AppTheme.borderWidthHairline)
                        )
                }
            }
            if let subtitle, !subtitle.isEmpty {
                Text(subtitle)
                    .font(.subheadline)
                    .foregroundStyle(AppTheme.textSecondary)
                    .multilineTextAlignment(.leading)
                    .lineLimit(3)
            }
            if showsTags, !tags.isEmpty {
                tagStrip
            }
        }
    }

    private var titleText: some View {
        Group {
            if monospacedTitleDigits {
                Text(title)
                    .font(.headline)
                    .foregroundStyle(AppTheme.textPrimary)
                    .multilineTextAlignment(.leading)
                    .monospacedDigit()
            } else {
                Text(title)
                    .font(.headline)
                    .foregroundStyle(AppTheme.textPrimary)
                    .multilineTextAlignment(.leading)
            }
        }
    }

    private var tagStrip: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 6) {
                ForEach(Array(tags.prefix(20)), id: \.self) { tag in
                    TagChipView(label: tag, isSelected: false)
                }
                if tags.count > 20 {
                    Text(verbatim: "+\(tags.count - 20)")
                        .font(.caption2.weight(.semibold))
                        .foregroundStyle(AppTheme.textSecondary)
                        .padding(.leading, 2)
                }
            }
        }
    }
}

// MARK: - Optional card wrapper（プレビュー単体表示用）

private struct OptionalFoundationCardModifier: ViewModifier {
    let enabled: Bool
    let style: FoundationCardStyle

    @ViewBuilder
    func body(content: Content) -> some View {
        if enabled {
            content.foundationCard(style: style)
        } else {
            content
        }
    }
}
