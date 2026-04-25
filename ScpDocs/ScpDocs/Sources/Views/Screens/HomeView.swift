import SwiftUI
#if canImport(UIKit)
import UIKit
#endif

#if canImport(UIKit)
/// Split Hero 左（SCP-JP）／右下（国際版）: 1 行のまま、与えられた矩形内で最太・最大のポイントサイズに収める。
private struct HomeHeroFittingLineTitle: View {
    let rawTitle: String
    let locale: Locale

    var body: some View {
        let display = rawTitle.uppercased(with: locale)
        GeometryReader { geo in
            let w = max(0, geo.size.width)
            let h = max(0, geo.size.height)
            let pt = Self.maxPointSizeSingleLine(
                text: display,
                maxWidth: w,
                maxHeight: h,
                weight: .heavy
            )
            Text(display)
                .font(.system(size: pt, weight: .heavy, design: .default))
                .foregroundStyle(AppTheme.textPrimary)
                .lineLimit(1)
                .minimumScaleFactor(0.2)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        }
    }

    /// 1 行のバウンディングが `maxWidth` / `maxHeight` に入る最も大きいフォント（二分探索）。
    private static func maxPointSizeSingleLine(
        text: String,
        maxWidth: CGFloat,
        maxHeight: CGFloat,
        weight: UIFont.Weight
    ) -> CGFloat {
        guard !text.isEmpty, maxWidth > 2, maxHeight > 2 else { return 8 }
        var lo: CGFloat = 4
        var hi: CGFloat = min(maxWidth * 1.4, maxHeight * 1.4, 160)
        for _ in 0 ..< 28 {
            let mid = (lo + hi) * 0.5
            let f = UIFont.systemFont(ofSize: mid, weight: weight)
            let size = (text as NSString).boundingRect(
                with: CGSize(width: 9_999, height: 9_999),
                options: [.usesLineFragmentOrigin, .usesFontLeading],
                attributes: [.font: f],
                context: nil
            ).size
            if size.width <= maxWidth * 0.99, size.height <= maxHeight * 0.99 {
                lo = mid
            } else {
                hi = mid
            }
        }
        return max(4, lo)
    }
}
#endif

/// 職員ダッシュボード。縦スクロールなしで表示領域に収め、`HomeViewModel` と `NavigationRouter` をバインドする。
struct HomeView: View {
    @Bindable var navigationRouter: NavigationRouter
    private let homeViewModel: HomeViewModel
    @Bindable var articleRepository: ArticleRepository
    var onOpenSettings: () -> Void

    @Environment(\.scpHomeAdBottomReserve) private var homeAdBottomReserve
    @Environment(\.colorScheme) private var colorScheme

    private let homeGridSpacing: CGFloat = 12

    init(
        navigationRouter: NavigationRouter,
        homeViewModel: HomeViewModel,
        articleRepository: ArticleRepository,
        onOpenSettings: @escaping () -> Void = {}
    ) {
        self.navigationRouter = navigationRouter
        self.homeViewModel = homeViewModel
        self.articleRepository = articleRepository
        self.onOpenSettings = onOpenSettings
    }

    private var hasActiveContinueReading: Bool {
        homeViewModel.continueReadingTargetURL != nil && homeViewModel.continueReadingRow != nil
    }

    var body: some View {
        GeometryReader { geo in
            let bottomPad = 8 + homeAdBottomReserve
            VStack(spacing: homeGridSpacing) {
                dashboardHeaderCard
                GeometryReader { flex in
                    homeFlexColumn(availableHeight: flex.size.height)
                }
            }
            .padding(.horizontal, 16)
            .padding(.top, 0)
            .padding(.bottom, bottomPad)
            .frame(height: geo.size.height, alignment: .top)
        }
        .scrollIndicators(.hidden)
        .background(AppTheme.mainBackground)
        .toolbar(.hidden, for: .navigationBar)
        .tint(AppTheme.brandAccent)
        .onAppear {
            Task { @MainActor in
                homeViewModel.refreshTrifoldPersonnelDashboard()
            }
        }
    }

    // MARK: - 可変縦スタック（続き → ランダム → SCP 3 系統 → 2×2）

    private func homeFlexColumn(availableHeight: CGFloat) -> some View {
        let sectionCount = 4
        let gapCount = max(0, sectionCount - 1)
        let gapsTotal = CGFloat(gapCount) * homeGridSpacing
        let usable = max(0, availableHeight - gapsTotal)
        let (hContinue, hRandom, hHero, hSupport) = flexSegmentHeights(usable: usable)

        let categoryHeroOverhead: CGFloat = 28
        let heroGridHeight = max(0, hHero - categoryHeroOverhead)

        return VStack(spacing: homeGridSpacing) {
            VStack(alignment: .leading, spacing: 0) {
                sectionContinueReadingSlot()
                Spacer(minLength: 0)
            }
            .frame(height: hContinue, alignment: .top)
            VStack(spacing: 0) {
                randomArticleSection
                Spacer(minLength: 0)
            }
            .frame(height: hRandom, alignment: .top)
            VStack(alignment: .leading, spacing: 6) {
                homeSectionOuterTitle(localizationKey: LocalizationKey.homePillarCategorySectionCaption)
                sectionSplitHeroGrid(heroHeight: heroGridHeight)
            }
            .frame(height: hHero, alignment: .top)
            .clipped()
            sectionSupportHubs(fixedHeight: hSupport)
                .frame(height: hSupport, alignment: .top)
                .clipped()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
    }

    private func flexSegmentHeights(usable: CGFloat) -> (CGFloat, CGFloat, CGFloat, CGFloat) {
        let wContinue: CGFloat = 0.26
        let wRandom: CGFloat = 0.16
        let wHero: CGFloat = 0.36
        let wSupport: CGFloat = 0.22
        return (
            usable * wContinue,
            usable * wRandom,
            usable * wHero,
            usable * wSupport
        )
    }

    // MARK: - Continue reading（常時。記録なしはグレーアウト）

    private func homeSectionOuterTitle(localizationKey: String) -> some View {
        Text(String(localized: String.LocalizationValue(localizationKey)))
            .font(continueReadingOuterTitleFont())
            .foregroundStyle(AppTheme.textPrimary)
            .tracking(0.8)
            .frame(maxWidth: .infinity, alignment: .leading)
    }

    private func sectionContinueReadingSlot() -> some View {
        Group {
            if hasActiveContinueReading, let url = homeViewModel.continueReadingTargetURL, let row = homeViewModel.continueReadingRow {
                Button {
                    Haptics.medium()
                    navigationRouter.pushArticle(url: url)
                } label: {
                    VStack(alignment: .leading, spacing: 6) {
                        homeSectionOuterTitle(localizationKey: LocalizationKey.homeContinueReadingCaption)
                        terminalPanel {
                            VStack(alignment: .leading, spacing: 5) {
                                Text(row.categoryLine)
                                    .font(continueReadingCategoryFont())
                                    .foregroundStyle(AppTheme.textSecondary.opacity(0.9))
                                    .lineLimit(1)
                                    .minimumScaleFactor(0.88)
                                Text(row.titleLine)
                                    .font(continueReadingTitleFont())
                                    .foregroundStyle(AppTheme.textPrimary)
                                    .lineLimit(3)
                                    .minimumScaleFactor(0.85)
                                continueReadingLine3Block(row: row)
                                readingProgressGauge(progress: row.scrollProgress, locale: homeViewModel.resolvedLocale)
                            }
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .contentShape(Rectangle())
                }
                .buttonStyle(DashboardPressButtonStyle())
            } else {
                VStack(alignment: .leading, spacing: 6) {
                    homeSectionOuterTitle(localizationKey: LocalizationKey.homeContinueReadingCaption)
                    terminalPanel {
                        VStack(alignment: .leading, spacing: 8) {
                            Text(String(localized: String.LocalizationValue(LocalizationKey.homeContinueReadingEmptyTitle)))
                                .font(.subheadline.weight(.semibold))
                                .foregroundStyle(AppTheme.textSecondary)
                                .lineLimit(3)
                                .minimumScaleFactor(0.85)
                            Text(String(localized: String.LocalizationValue(LocalizationKey.homeContinueReadingEmptySubtitle)))
                                .font(.caption.weight(.medium))
                                .foregroundStyle(AppTheme.textSecondary.opacity(0.95))
                                .lineLimit(5)
                                .minimumScaleFactor(0.88)
                        }
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .opacity(0.52)
                .allowsHitTesting(false)
            }
        }
        .frame(maxWidth: .infinity, alignment: .top)
    }

    // MARK: - Random article（常時・枠は 1 枚のみ）

    private var randomArticleSection: some View {
        Button {
            Haptics.medium()
            if let u = homeViewModel.randomDiscoveryURL {
                navigationRouter.pushArticle(url: u)
            } else {
                navigationRouter.pushArticle(url: homeViewModel.selectedBranch.randomSCPURL)
            }
        } label: {
            VStack(alignment: .leading, spacing: 6) {
                homeSectionOuterTitle(localizationKey: LocalizationKey.homeRandomArticleReadSectionTitle)
                terminalPanel {
                    HStack(alignment: .center, spacing: 12) {
                        randomPanelDiceIcon()
                        VStack(alignment: .leading, spacing: 3) {
                            HStack(alignment: .firstTextBaseline, spacing: 0) {
                                Text(String(localized: String.LocalizationValue(LocalizationKey.homeRandomCLIPrefix)))
                                    .foregroundStyle(AppTheme.textSecondary.opacity(0.9))
                                Text(String(localized: String.LocalizationValue(LocalizationKey.homeRandomCLIWildcard)))
                                    .foregroundStyle(AppTheme.readingProgressGaugeFill)
                            }
                            .font(continueReadingCategoryFont())
                            .lineLimit(2)
                            .minimumScaleFactor(0.72)
                            Text(String(localized: String.LocalizationValue(LocalizationKey.homeRandomExploreSubtitle)))
                                .font(randomPanelExploreTitleFont())
                                .foregroundStyle(AppTheme.textPrimary)
                                .lineLimit(2)
                                .minimumScaleFactor(0.85)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        Image(systemName: "chevron.right")
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(AppTheme.textSecondary)
                    }
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .contentShape(Rectangle())
        }
        .buttonStyle(DashboardPressButtonStyle())
        .frame(maxWidth: .infinity, alignment: .top)
    }

    /// ホーム「ランダム記事」左アイコン（`dice.fill`）。
    @ViewBuilder
    private func randomPanelDiceIcon() -> some View {
        #if canImport(UIKit)
        Image(systemName: "dice.fill")
            .font(.system(size: AppTypography.randomPanelDiceIconPointSize(), weight: .semibold))
            .foregroundStyle(AppTheme.readingProgressGaugeFill)
        #else
        Image(systemName: "dice.fill")
            .foregroundStyle(AppTheme.readingProgressGaugeFill)
        #endif
    }

    private func continueReadingOuterTitleFont() -> Font {
        #if canImport(UIKit)
        let pt = UIFont.preferredFont(forTextStyle: .caption1).pointSize
        return .system(size: pt + 1, weight: .heavy)
        #else
        return .caption.weight(.heavy)
        #endif
    }

    private func continueReadingCategoryFont() -> Font {
        #if canImport(UIKit)
        let pt = UIFont.preferredFont(forTextStyle: .subheadline).pointSize
        return .system(size: max(6, pt - 1), weight: .regular, design: .default)
        #else
        return .subheadline
        #endif
    }

    private func continueReadingTitleFont() -> Font {
        #if canImport(UIKit)
        let pt = UIFont.preferredFont(forTextStyle: .body).pointSize
        return .system(size: pt + 4, weight: .bold, design: .default)
        #else
        return .body.weight(.bold)
        #endif
    }

    private func continueReadingLine3Font() -> Font {
        #if canImport(UIKit)
        let pt = UIFont.preferredFont(forTextStyle: .body).pointSize
        return .system(size: max(8, pt), weight: .light, design: .default)
        #else
        return .callout
        #endif
    }

    private func continueReadingLine3TextColor() -> Color {
        switch colorScheme {
        case .dark: AppTheme.textPrimary
        case .light: Color.black
        @unknown default: Color.black
        }
    }

    @ViewBuilder
    private func continueReadingLine3Block(row: ContinueReadingRowDisplay) -> some View {
        let idFont = continueReadingLine3Font().monospaced()
        let suffixFont = continueReadingLine3Font()
        HStack(alignment: .firstTextBaseline, spacing: 6) {
            Text(row.line3Identifier)
                .font(idFont)
            if let oc = row.line3ObjectClass {
                Text(
                    String(
                        format: String(localized: String.LocalizationValue(LocalizationKey.homeContinueObjectClassFormat)),
                        oc
                    )
                )
                .font(suffixFont)
            }
        }
        .foregroundStyle(continueReadingLine3TextColor())
        .lineLimit(2)
        .minimumScaleFactor(0.78)
    }

    private func continueReadingPercentFont() -> Font {
        #if canImport(UIKit)
        let pt = UIFont.preferredFont(forTextStyle: .caption2).pointSize
        return .system(size: max(5, pt - 1), weight: .regular, design: .default)
        #else
        return .caption2
        #endif
    }

    private func randomPanelExploreTitleFont() -> Font {
        #if canImport(UIKit)
        let pt = UIFont.preferredFont(forTextStyle: .body).pointSize
        return .system(size: pt + 2, weight: .bold, design: .default)
        #else
        return .body.weight(.bold)
        #endif
    }

    private func homeDashboardMottoFont() -> Font {
        #if canImport(UIKit)
        let pt = UIFont.preferredFont(forTextStyle: .subheadline).pointSize
        return .system(size: max(8, pt - 4), weight: .medium, design: .monospaced)
        #else
        return .subheadline.weight(.medium)
        #endif
    }

    private func readingProgressGauge(progress: Double, locale: Locale) -> some View {
        let p = min(1, max(0, progress))
        return VStack(alignment: .trailing, spacing: 3) {
            GeometryReader { g in
                let w = max(0, g.size.width)
                ZStack(alignment: .leading) {
                    Rectangle()
                        .fill(AppTheme.readingProgressGaugeTrack)
                    Rectangle()
                        .fill(AppTheme.readingProgressGaugeFill)
                        .frame(width: w * p)
                }
            }
            .frame(height: 2.5)
            .frame(maxWidth: .infinity, alignment: .leading)
            Text(
                String(
                    format: String(localized: String.LocalizationValue(LocalizationKey.homeContinueGaugePercentFormat)),
                    locale: locale,
                    Int((p * 100).rounded())
                )
            )
            .font(continueReadingPercentFont())
            .foregroundStyle(AppTheme.textSecondary.opacity(0.9))
            .monospacedDigit()
            .frame(maxWidth: .infinity, alignment: .trailing)
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(String(localized: String.LocalizationValue(LocalizationKey.homeContinueReadingAccessibility)))
        .accessibilityValue(
            String(
                format: String(localized: String.LocalizationValue(LocalizationKey.homeContinueScrollPercentFormat)),
                locale: locale,
                Int((p * 100).rounded())
            )
        )
    }

    // MARK: - Split Hero（SCP-JP / SCP-en / SCP-int）

    /// 右列 本家翻訳（SCP / EN 本家訳）のみ。SCP-JP / 国際版は可変1行 `HomeHeroFittingLineTitle`。
    private func heroArchiveTitleFont(kind: SCPArticleFeedKind, isDoubleHeight: Bool, compact: Bool) -> Font {
        if kind == .en, !isDoubleHeight {
#if canImport(UIKit)
            let style: UIFont.TextStyle = compact ? .title2 : .title1
            let base = UIFont.preferredFont(forTextStyle: style)
            let heavy = UIFont.systemFont(ofSize: base.pointSize, weight: .heavy)
            let scaled = UIFontMetrics(forTextStyle: style).scaledFont(for: heavy)
            return Font(scaled)
#else
            return (compact ? .title2 : .title).weight(.heavy)
#endif
        }
        return isDoubleHeight
            ? (compact ? .headline.weight(.heavy) : .title2.weight(.heavy))
            : (compact ? .caption.weight(.heavy) : .subheadline.weight(.heavy))
    }

    /// Split Hero の SCP-JP / 本家翻訳 / 国際版：カタログ内の既読割合（％表記なし・点線風ダッシュ）。
    private func heroTrifoldCatalogReadGauge(
        readFraction: Double,
        readCount: Int,
        total: Int,
        locale: Locale
    ) -> some View {
        let p = min(1, max(0, readFraction))
        return GeometryReader { g in
            let midY = g.size.height / 2
            let w = g.size.width
            ZStack(alignment: .leading) {
                Path { path in
                    path.move(to: CGPoint(x: 0, y: midY))
                    path.addLine(to: CGPoint(x: w, y: midY))
                }
                .stroke(
                    AppTheme.readingProgressGaugeTrack.opacity(0.95),
                    style: StrokeStyle(lineWidth: 1.25, lineCap: .round, dash: [2, 5])
                )
                Path { path in
                    path.move(to: CGPoint(x: 0, y: midY))
                    path.addLine(to: CGPoint(x: w * p, y: midY))
                }
                .stroke(
                    AppTheme.readingProgressGaugeFill,
                    style: StrokeStyle(lineWidth: 2, lineCap: .round, dash: [2, 5])
                )
            }
        }
        .frame(height: 6)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(String(localized: String.LocalizationValue(LocalizationKey.homeHeroCatalogGaugeA11yLabel)))
        .accessibilityValue(
            String(
                format: String(localized: String.LocalizationValue(LocalizationKey.homeHeroCatalogGaugeA11yValueFormat)),
                locale: locale,
                readCount,
                total
            )
        )
    }

    private func sectionSplitHeroGrid(heroHeight: CGFloat) -> some View {
        let rightRowHeight = max(48, (heroHeight - homeGridSpacing) / 2)

        return HStack(alignment: .center, spacing: homeGridSpacing) {
            heroArchiveButton(kind: .jp, isDoubleHeight: true, compact: heroHeight < 150)
                .frame(maxWidth: .infinity)
                .frame(height: heroHeight)

            VStack(spacing: homeGridSpacing) {
                heroArchiveButton(kind: .en, isDoubleHeight: false, compact: heroHeight < 150)
                    .frame(maxWidth: .infinity)
                    .frame(height: rightRowHeight)
                heroArchiveButton(kind: .int, isDoubleHeight: false, compact: heroHeight < 150)
                    .frame(maxWidth: .infinity)
                    .frame(height: rightRowHeight)
            }
            .frame(maxWidth: .infinity)
            .frame(height: heroHeight)
        }
        .frame(height: heroHeight)
    }

    private func heroArchiveButton(kind: SCPArticleFeedKind, isDoubleHeight: Bool, compact: Bool) -> some View {
        let labels = splitHeroLabels(for: kind)
        let total = homeViewModel.totalCount(for: kind)
        let unread = homeViewModel.unreadCount(for: kind)
        let titleBottomSpacing: CGFloat = compact ? 5 : (isDoubleHeight ? 8 : 6)
        let titleFont: Font = heroArchiveTitleFont(kind: kind, isDoubleHeight: isDoubleHeight, compact: compact)
        let readCount = max(0, total - unread)
        let readFraction: Double = total > 0 ? Double(readCount) / Double(total) : 0
        let locale = homeViewModel.resolvedLocale

        return Button {
            Haptics.medium()
            navigationRouter.push(.scpArticleCatalogFeed(kind))
        } label: {
            VStack(alignment: .leading, spacing: 0) {
                if kind == .jp {
#if canImport(UIKit)
                    HomeHeroFittingLineTitle(rawTitle: labels.title, locale: locale)
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                        .padding(.bottom, titleBottomSpacing)
#else
                    Text(labels.title.uppercased(with: locale))
                        .font(isDoubleHeight ? .title.weight(.heavy) : .headline.weight(.heavy))
                        .foregroundStyle(AppTheme.textPrimary)
                        .lineLimit(1)
                        .minimumScaleFactor(0.2)
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                        .padding(.bottom, titleBottomSpacing)
#endif
                } else if kind == .int {
#if canImport(UIKit)
                    HomeHeroFittingLineTitle(rawTitle: labels.title, locale: locale)
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                        .padding(.bottom, titleBottomSpacing)
#else
                    Text(labels.title.uppercased(with: locale))
                        .font(.subheadline.weight(.heavy))
                        .foregroundStyle(AppTheme.textPrimary)
                        .lineLimit(1)
                        .minimumScaleFactor(0.2)
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                        .padding(.bottom, titleBottomSpacing)
#endif
                } else {
                    Text(labels.title.uppercased(with: locale))
                        .font(titleFont)
                        .foregroundStyle(AppTheme.textPrimary)
                        .multilineTextAlignment(.leading)
                        .lineLimit(3)
                        .minimumScaleFactor(0.6)
                        .padding(.bottom, titleBottomSpacing)
                    Spacer(minLength: 0)
                }

                if kind == .jp || kind == .en || kind == .int {
                    VStack(alignment: .leading, spacing: 4) {
                        heroTrifoldCatalogReadGauge(
                            readFraction: readFraction,
                            readCount: readCount,
                            total: total,
                            locale: homeViewModel.resolvedLocale
                        )
                        Text(metricsSummary(total: total, unread: unread))
                            .font(.caption2.weight(.semibold))
                            .foregroundStyle(AppTheme.terminalSilver.opacity(0.92))
                            .monospaced()
                            .lineLimit(1)
                            .minimumScaleFactor(0.7)
                    }
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
            .padding(compact ? 10 : 14)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
            .background(
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .fill(AppTheme.cardStandard)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .stroke(AppTheme.terminalSilver.opacity(0.9), lineWidth: 1)
            )
        }
        .buttonStyle(DashboardPressButtonStyle())
    }

    private func splitHeroLabels(for kind: SCPArticleFeedKind) -> (title: String, subtitle: String) {
        let branch = homeViewModel.selectedBranch
        switch kind {
        case .jp:
            let d = HomeCategory.jpArticles.gridDescriptor(for: branch)
            return (localized(d.titleLocalizationKey), localized(d.subtitleLocalizationKey))
        case .en:
            let d = HomeCategory.originalArticles.gridDescriptor(for: branch)
            return (localized(d.titleLocalizationKey), localized(d.subtitleLocalizationKey))
        case .int:
            return (
                String(localized: String.LocalizationValue(LocalizationKey.homeSectionInternationalTitle)),
                String(localized: String.LocalizationValue(LocalizationKey.homeSectionInternationalSubtitle))
            )
        case .tales, .gois, .canons, .jokes:
            return ("", "")
        }
    }

    private func metricsSummary(total: Int, unread: Int) -> String {
        String(
            format: String(localized: String.LocalizationValue(LocalizationKey.homeHeroMetricsFormat)),
            locale: homeViewModel.resolvedLocale,
            total,
            unread
        )
    }

    // MARK: - Support Hubs (2×2)

    private func sectionSupportHubs(fixedHeight: CGFloat) -> some View {
        let cellHeight = max(44, (fixedHeight - homeGridSpacing) / 2)
        return LazyVGrid(
            columns: [
                GridItem(.flexible(), spacing: homeGridSpacing),
                GridItem(.flexible(), spacing: homeGridSpacing)
            ],
            spacing: homeGridSpacing
        ) {
            ForEach([HomeCategory.tales, HomeCategory.gois, HomeCategory.canons, HomeCategory.jokes], id: \.self) { category in
                supportHubTile(category: category, minCellHeight: cellHeight)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
    }

    private func supportHubTile(category: HomeCategory, minCellHeight: CGFloat) -> some View {
        let item = homeViewModel.homeGridItems.first(where: { $0.category == category })
        let title = item.map { localized($0.titleLocalizationKey) } ?? ""
        return Button {
            Haptics.medium()
            handleCategoryTap(category)
        } label: {
            HStack(spacing: 10) {
                Image(systemName: item?.systemImageName ?? "square.grid.2x2")
                    .font(.body.weight(.semibold))
                    .foregroundStyle(AppTheme.terminalSilver.opacity(0.9))
                    .frame(width: 28, alignment: .center)
                Text(title)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(AppTheme.textPrimary)
                    .multilineTextAlignment(.leading)
                    .lineLimit(3)
                    .minimumScaleFactor(0.78)
                Spacer(minLength: 0)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 10)
            .frame(maxWidth: .infinity, minHeight: minCellHeight, maxHeight: .infinity, alignment: .leading)
            .background(
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .fill(AppTheme.cardStandard)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .stroke(AppTheme.terminalSilver.opacity(0.85), lineWidth: 1)
            )
        }
        .buttonStyle(DashboardPressButtonStyle())
    }

    // MARK: - Header (branch / motto / search / settings)

    private var dashboardHeaderCard: some View {
        HStack(alignment: .top, spacing: 12) {
            VStack(alignment: .leading, spacing: 4) {
                Menu {
                    ForEach(homeViewModel.availableBranches, id: \.id) { branch in
                        Button {
                            homeViewModel.selectBranch(id: branch.id)
                            Haptics.medium()
                        } label: {
                            Text(String(localized: String.LocalizationValue(branch.displayNameKey)))
                        }
                    }
                } label: {
                    HStack(alignment: .center, spacing: 8) {
                        Image("HomeBranchMark")
                            .resizable()
                            .renderingMode(.original)
                            .scaledToFit()
                            .frame(height: AppTypography.homeBranchMarkImageHeight())
                            .accessibilityHidden(true)
                        Text(homeViewModel.homeDashboardBranchTitle)
                            .font(AppTypography.homeBranchTitleFont())
                            .foregroundStyle(AppTheme.textPrimary)
                            .multilineTextAlignment(.leading)
                            .lineLimit(3)
                            .minimumScaleFactor(0.75)
                            .frame(minHeight: AppTypography.homeBranchTitleRowReservedHeight, alignment: .center)
                        Image(systemName: "chevron.up.chevron.down")
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(AppTheme.textSecondary)
                    }
                }
                .buttonStyle(.plain)

                Text(String(localized: String.LocalizationValue(LocalizationKey.homeDashboardMotto)))
                    .font(homeDashboardMottoFont())
                    .foregroundStyle(AppTheme.textSecondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            HStack(spacing: 0) {
                Button {
                    Haptics.light()
                    navigationRouter.push(.homeScpSearch)
                } label: {
                    Image(systemName: "magnifyingglass")
                        .font(.title3.weight(.semibold))
                        .foregroundStyle(AppTheme.brandAccent)
                        .frame(width: 44, height: 44, alignment: .center)
                        .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
                .accessibilityLabel(String(localized: String.LocalizationValue(LocalizationKey.homeSearchButtonAccessibility)))

                Button {
                    Haptics.light()
                    onOpenSettings()
                } label: {
                    Image(systemName: "gearshape")
                        .font(.title3.weight(.semibold))
                        .foregroundStyle(AppTheme.brandAccent)
                        .frame(width: 44, height: 44, alignment: .center)
                        .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
                .accessibilityLabel(String(localized: String.LocalizationValue(LocalizationKey.tabSettings)))
            }
        }
        .padding(.vertical, 2)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.clear)
    }

    // MARK: - Layout helpers

    private func terminalPanel<Content: View>(@ViewBuilder content: () -> Content) -> some View {
        content()
            .padding(14)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .fill(AppTheme.cardStandard)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .stroke(AppTheme.terminalSilver.opacity(0.9), lineWidth: 1)
            )
    }

    private func handleCategoryTap(_ category: HomeCategory) {
        switch category {
        case .jpArticles:
            navigationRouter.push(.scpJapanArchive(ScpArchiveListSeed()))
        case .originalArticles:
            navigationRouter.push(.scpEnglishArchive(ScpArchiveListSeed()))
        case .tales:
            navigationRouter.push(.scpArticleCatalogFeed(.tales))
        case .canons:
            navigationRouter.push(.scpArticleCatalogFeed(.canons))
        case .gois:
            navigationRouter.push(.scpArticleCatalogFeed(.gois))
        case .jokes:
            navigationRouter.push(.scpArticleCatalogFeed(.jokes))
        }
    }

    private func localized(_ key: String) -> String {
        String(localized: String.LocalizationValue(key))
    }
}

#Preview {
    @Previewable @State var router = NavigationRouter()
    @Previewable @State var vm = HomeViewModel(
        settingsRepository: SettingsRepository(),
        articleRepository: ArticleRepository()
    )
    @Previewable @State var repo = ArticleRepository()
    NavigationStack {
        HomeView(
            navigationRouter: router,
            homeViewModel: vm,
            articleRepository: repo,
            onOpenSettings: {}
        )
    }
}
