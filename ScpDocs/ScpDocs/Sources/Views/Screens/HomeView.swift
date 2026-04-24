import SwiftUI
#if canImport(UIKit)
import UIKit
#endif

/// 職員ダッシュボード。縦スクロールなしで表示領域に収め、`HomeViewModel` と `NavigationRouter` をバインドする。
struct HomeView: View {
    @Bindable var navigationRouter: NavigationRouter
    private let homeViewModel: HomeViewModel
    @Bindable var articleRepository: ArticleRepository
    var onOpenSettings: () -> Void

    @Environment(\.scpHomeAdBottomReserve) private var homeAdBottomReserve

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
            .padding(.top, 2)
            .padding(.bottom, bottomPad)
            .frame(height: geo.size.height, alignment: .top)
        }
        .scrollIndicators(.hidden)
        .background(AppTheme.mainBackground)
        .toolbar(.hidden, for: .navigationBar)
        .tint(AppTheme.brandAccent)
        .onAppear {
            homeViewModel.refreshTrifoldPersonnelDashboard()
        }
    }

    // MARK: - 可変縦スタック（続き → ランダム → SCP 3 系統 → 2×2）

    private func homeFlexColumn(availableHeight: CGFloat) -> some View {
        let sectionCount = 4
        let gapCount = max(0, sectionCount - 1)
        let gapsTotal = CGFloat(gapCount) * homeGridSpacing
        let usable = max(0, availableHeight - gapsTotal)
        let (hContinue, hRandom, hHero, hSupport) = flexSegmentHeights(usable: usable)

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
            sectionSplitHeroGrid(heroHeight: hHero)
                .frame(height: hHero)
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
                            VStack(alignment: .leading, spacing: 6) {
                                Text(row.branchNameLine)
                                    .font(.subheadline.weight(.semibold))
                                    .foregroundStyle(AppTheme.textPrimary)
                                    .lineLimit(1)
                                    .minimumScaleFactor(0.88)
                                Text(row.titleLine)
                                    .font(.body.weight(.semibold))
                                    .foregroundStyle(AppTheme.textPrimary)
                                    .lineLimit(3)
                                    .minimumScaleFactor(0.85)
                                Text(row.scpOrIdentifierLine)
                                    .font(.body.weight(.heavy))
                                    .foregroundStyle(AppTheme.textPrimary)
                                    .monospaced()
                                    .lineLimit(2)
                                    .minimumScaleFactor(0.78)
                                readingProgressGauge(progress: row.scrollProgress)
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
                    Text(String(localized: String.LocalizationValue(LocalizationKey.homeRandomPanelSubtitle)))
                        .font(.subheadline.weight(.medium))
                        .foregroundStyle(AppTheme.textSecondary)
                        .lineLimit(6)
                        .minimumScaleFactor(0.82)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .contentShape(Rectangle())
        }
        .buttonStyle(DashboardPressButtonStyle())
        .frame(maxWidth: .infinity, alignment: .top)
    }

    private func continueReadingOuterTitleFont() -> Font {
        #if canImport(UIKit)
        let pt = UIFont.preferredFont(forTextStyle: .caption1).pointSize
        return .system(size: pt + 1, weight: .heavy)
        #else
        return .caption.weight(.heavy)
        #endif
    }

    private func homeDashboardMottoFont() -> Font {
        #if canImport(UIKit)
        let pt = UIFont.preferredFont(forTextStyle: .subheadline).pointSize
        return .system(size: max(10, pt - 2), weight: .medium, design: .monospaced)
        #else
        return .subheadline.weight(.medium)
        #endif
    }

    private func readingProgressGauge(progress: Double) -> some View {
        let p = min(1, max(0, progress))
        return GeometryReader { g in
            let w = max(0, g.size.width)
            ZStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: 3, style: .continuous)
                    .fill(AppTheme.terminalSilver.opacity(0.22))
                RoundedRectangle(cornerRadius: 3, style: .continuous)
                    .fill(AppTheme.terminalSilver.opacity(0.9))
                    .frame(width: max(2, w * p))
            }
        }
        .frame(maxWidth: .infinity)
        .frame(height: 8)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(String(localized: String.LocalizationValue(LocalizationKey.homeContinueReadingAccessibility)))
        .accessibilityValue(
            String(
                format: String(localized: String.LocalizationValue(LocalizationKey.homeContinueScrollPercentFormat)),
                locale: homeViewModel.resolvedLocale,
                Int((p * 100).rounded())
            )
        )
    }

    // MARK: - Split Hero（SCP-JP / SCP-en / SCP-int）

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
        let innerSpacing: CGFloat = compact ? 5 : (isDoubleHeight ? 10 : 6)
        let titleFont: Font = isDoubleHeight
            ? (compact ? .headline.weight(.heavy) : .title2.weight(.heavy))
            : (compact ? .caption.weight(.heavy) : .subheadline.weight(.heavy))
        let subtitleFont: Font = isDoubleHeight
            ? (compact ? .caption2.weight(.semibold) : .caption.weight(.semibold))
            : (compact ? .caption2.weight(.medium) : .caption2.weight(.medium))

        return Button {
            Haptics.medium()
            selectBranch(for: kind)
            navigationRouter.push(.scpArticleCatalogFeed(kind))
        } label: {
            ZStack(alignment: .topTrailing) {
                VStack(alignment: .leading, spacing: innerSpacing) {
                    Text(labels.title.uppercased(with: homeViewModel.resolvedLocale))
                        .font(titleFont)
                        .foregroundStyle(AppTheme.textPrimary)
                        .multilineTextAlignment(.leading)
                        .lineLimit(isDoubleHeight ? 4 : 3)
                        .minimumScaleFactor(0.68)
                    Text(labels.subtitle)
                        .font(subtitleFont)
                        .foregroundStyle(AppTheme.textSecondary)
                        .lineLimit(isDoubleHeight ? 3 : 2)
                        .minimumScaleFactor(0.78)
                    Spacer(minLength: 0)
                    Text(metricsSummary(total: total, unread: unread))
                        .font(.caption2.weight(.semibold))
                        .foregroundStyle(AppTheme.terminalSilver.opacity(0.92))
                        .monospaced()
                        .lineLimit(1)
                        .minimumScaleFactor(0.7)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)

                if unread > 0 {
                    Circle()
                        .fill(AppTheme.terminalSilver.opacity(0.95))
                        .frame(width: 7, height: 7)
                        .padding(compact ? 6 : 10)
                        .accessibilityHidden(true)
                }
            }
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

    private func selectBranch(for kind: SCPArticleFeedKind) {
        switch kind {
        case .jp:
            homeViewModel.selectBranch(id: BranchIdentifier.scpJapan)
        case .en:
            homeViewModel.selectBranch(id: BranchIdentifier.scpWikiEN)
        case .int:
            homeViewModel.selectBranch(id: BranchIdentifier.scpInternational)
        case .tales, .gois, .canons, .jokes:
            break
        }
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
            VStack(alignment: .leading, spacing: 6) {
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
        .padding(.vertical, 4)
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
            homeViewModel.selectBranch(id: BranchIdentifier.scpJapan)
            navigationRouter.push(.scpJapanArchive(initialTagFilters: nil))
        case .originalArticles:
            homeViewModel.selectBranch(id: BranchIdentifier.scpJapan)
            navigationRouter.push(.scpEnglishArchive(initialTagFilters: nil))
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
