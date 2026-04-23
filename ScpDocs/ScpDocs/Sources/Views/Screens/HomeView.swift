import SwiftUI

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

    private var hasContinueReading: Bool {
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
    }

    // MARK: - 可変縦スタック（続き → ランダム → SCP 3 系統 → 2×2）

    private func homeFlexColumn(availableHeight: CGFloat) -> some View {
        let sectionCount = hasContinueReading ? 4 : 3
        let gapCount = max(0, sectionCount - 1)
        let gapsTotal = CGFloat(gapCount) * homeGridSpacing
        let usable = max(0, availableHeight - gapsTotal)
        let (hContinue, hRandom, hHero, hSupport) = flexSegmentHeights(usable: usable)

        return VStack(spacing: homeGridSpacing) {
            if hasContinueReading, let url = homeViewModel.continueReadingTargetURL, let row = homeViewModel.continueReadingRow {
                sectionContinueReading(url: url, row: row)
                    .frame(height: hContinue, alignment: .top)
            }
            randomArticleSection
                .frame(height: hRandom, alignment: .top)
            sectionSplitHeroGrid(heroHeight: hHero)
                .frame(height: hHero)
            sectionSupportHubs(fixedHeight: hSupport)
                .frame(height: hSupport, alignment: .top)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
    }

    private func flexSegmentHeights(usable: CGFloat) -> (CGFloat, CGFloat, CGFloat, CGFloat) {
        let wContinue: CGFloat
        let wRandom: CGFloat
        let wHero: CGFloat
        let wSupport: CGFloat
        if hasContinueReading {
            wContinue = 0.30
            wRandom = 0.12
            wHero = 0.38
            wSupport = 0.20
        } else {
            wContinue = 0
            wRandom = 0.14
            wHero = 0.42
            wSupport = 0.44
        }
        let hc = hasContinueReading ? usable * wContinue : 0
        let hr = usable * wRandom
        let hh = usable * wHero
        let hs = usable * wSupport
        return (hc, hr, hh, hs)
    }

    // MARK: - Continue reading

    private func sectionContinueReading(url: URL, row: ContinueReadingRowDisplay) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(alignment: .firstTextBaseline, spacing: 10) {
                Text(String(localized: String.LocalizationValue(LocalizationKey.homeContinueReadingCaption)))
                    .font(.caption.weight(.heavy))
                    .foregroundStyle(AppTheme.terminalSilver)
                    .tracking(1.1)
                Text(row.identifierLine)
                    .font(.body.weight(.bold))
                    .foregroundStyle(AppTheme.textPrimary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.72)
                Spacer(minLength: 0)
            }

            Button {
                Haptics.medium()
                navigationRouter.pushArticle(url: url)
            } label: {
                terminalPanel {
                    VStack(alignment: .leading, spacing: 6) {
                        Text(row.categoryLine)
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(AppTheme.textPrimary)
                            .lineLimit(2)
                            .minimumScaleFactor(0.85)
                        Text(row.identifierLine)
                            .font(.body.weight(.heavy))
                            .foregroundStyle(AppTheme.textPrimary)
                            .monospaced()
                            .lineLimit(2)
                            .minimumScaleFactor(0.78)
                        Text(row.titleLine)
                            .font(.subheadline.weight(.medium))
                            .foregroundStyle(AppTheme.textSecondary)
                            .lineLimit(3)
                            .minimumScaleFactor(0.82)
                        readingProgressGauge(progress: row.scrollProgress)
                    }
                    HStack {
                        Spacer()
                        Image(systemName: "chevron.right")
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(AppTheme.terminalSilver.opacity(0.75))
                    }
                }
            }
            .buttonStyle(DashboardPressButtonStyle())
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
    }

    // MARK: - Random article（常時）

    private var randomArticleSection: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(alignment: .firstTextBaseline, spacing: 10) {
                Text(String(localized: String.LocalizationValue(LocalizationKey.homeRandomArticleReadSectionTitle)))
                    .font(.caption.weight(.heavy))
                    .foregroundStyle(AppTheme.terminalSilver)
                    .tracking(1.1)
                Spacer(minLength: 0)
            }

            Button {
                Haptics.medium()
                if let u = homeViewModel.randomDiscoveryURL {
                    navigationRouter.pushArticle(url: u)
                } else {
                    navigationRouter.pushArticle(url: homeViewModel.selectedBranch.randomSCPURL)
                }
            } label: {
                terminalPanel {
                    VStack(alignment: .leading, spacing: 6) {
                        Text(String(localized: String.LocalizationValue(LocalizationKey.homeRandomPanelSubtitle)))
                            .font(.subheadline.weight(.medium))
                            .foregroundStyle(AppTheme.textSecondary)
                            .lineLimit(4)
                            .minimumScaleFactor(0.82)
                    }
                    HStack {
                        Spacer()
                        Image(systemName: "shuffle")
                            .font(.title3.weight(.semibold))
                            .foregroundStyle(AppTheme.terminalSilver.opacity(0.85))
                    }
                }
            }
            .buttonStyle(DashboardPressButtonStyle())
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
    }

    private func readingProgressGauge(progress: Double) -> some View {
        let p = min(1, max(0, progress))
        return GeometryReader { g in
            ZStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: 3, style: .continuous)
                    .fill(AppTheme.terminalSilver.opacity(0.22))
                RoundedRectangle(cornerRadius: 3, style: .continuous)
                    .fill(AppTheme.terminalSilver.opacity(0.9))
                    .frame(width: max(2, g.size.width * p))
            }
        }
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
                        .lineLimit(isDoubleHeight ? 3 : 2)
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
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(AppTheme.textSecondary)
                    .monospaced()
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
