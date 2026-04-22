import SwiftUI

struct HomeView: View {
    @Bindable var navigationRouter: NavigationRouter
    private let homeViewModel: HomeViewModel
    private let japanSCPListMetadataStore: JapanSCPListMetadataStore
    @Bindable var articleRepository: ArticleRepository
    var onOpenSettings: () -> Void

    @Environment(\.scpHomeAdBottomReserve) private var homeAdBottomReserve

    private let homeGridSpacing: CGFloat = 12

    init(
        navigationRouter: NavigationRouter,
        homeViewModel: HomeViewModel,
        japanSCPListMetadataStore: JapanSCPListMetadataStore,
        articleRepository: ArticleRepository,
        onOpenSettings: @escaping () -> Void = {}
    ) {
        self.navigationRouter = navigationRouter
        self.homeViewModel = homeViewModel
        self.japanSCPListMetadataStore = japanSCPListMetadataStore
        self.articleRepository = articleRepository
        self.onOpenSettings = onOpenSettings
    }

    var body: some View {
        ScrollView {
            VStack(spacing: homeGridSpacing) {
                dashboardHeaderCard

                if let url = articleRepository.recentHistoryURLs(maxCount: 1).first {
                    continueReadingPanel(url: url)
                }

                randomAccessRow

                LazyVGrid(
                    columns: [
                        GridItem(.flexible(), spacing: homeGridSpacing),
                        GridItem(.flexible(), spacing: homeGridSpacing)
                    ],
                    spacing: homeGridSpacing
                ) {
                    ForEach(HomeCategory.allCases) { category in
                        homeCategoryTile(for: category)
                            .frame(minHeight: 112, alignment: .top)
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.top, 2)
            .padding(.bottom, 8 + homeAdBottomReserve)
        }
        .scrollIndicators(.hidden)
        .background(AppTheme.mainBackground)
        .toolbar(.hidden, for: .navigationBar)
        .tint(AppTheme.brandAccent)
    }

    /// 支部名・モットー・右上操作（検索・設定）。
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

    private func continueReadingPanel(url: URL) -> some View {
        let hint = japanSCPListMetadataStore.readingHint(for: url)
        let row = ContinueReadingSummaryBuilder.build(
            url: url,
            scrollProgress: articleRepository.readingScrollDepth(for: url),
            cachedPageTitle: articleRepository.cachedPageTitle(for: url),
            thumbnailURL: articleRepository.cachedFirstImageURL(for: url),
            japanListHint: hint,
            categoryLabel: { String(localized: String.LocalizationValue($0)) },
            objectClassFormat: { oc in
                String(
                    format: String(localized: String.LocalizationValue(LocalizationKey.homeContinueObjectClassFormat)),
                    locale: .current,
                    oc
                )
            }
        )

        return Button {
            Haptics.medium()
            navigationRouter.pushArticle(url: url)
        } label: {
            HStack(alignment: .center, spacing: 12) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(row.categoryLine)
                        .font(.caption.weight(.bold))
                        .foregroundStyle(AppTheme.brandAccent)

                    Text(row.identifierLine)
                        .font(.title3.weight(.bold))
                        .foregroundStyle(AppTheme.textPrimary)
                        .lineLimit(2)
                        .minimumScaleFactor(0.8)

                    Text(row.titleLine)
                        .font(.subheadline.weight(.medium))
                        .foregroundStyle(AppTheme.textPrimary)
                        .lineLimit(3)
                        .minimumScaleFactor(0.85)

                    if let ocLine = row.objectClassLine {
                        Text(ocLine)
                            .font(.caption.weight(.medium))
                            .foregroundStyle(AppTheme.textSecondary)
                            .lineLimit(2)
                    }

                    GeometryReader { geo in
                        ZStack(alignment: .leading) {
                            Capsule()
                                .fill(AppTheme.textSecondary.opacity(0.22))
                            Capsule()
                                .fill(AppTheme.brandAccent)
                                .frame(width: max(4, geo.size.width * row.scrollProgress))
                        }
                    }
                    .frame(height: 6)
                    .accessibilityHidden(true)
                }
                .frame(maxWidth: .infinity, alignment: .leading)

                if let thumb = row.thumbnailURL {
                    continueReadingThumbnail(url: thumb)
                }

                Image(systemName: "chevron.right")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(AppTheme.textSecondary.opacity(0.75))
            }
            .padding(14)
            .foundationCard(style: .standard)
        }
        .buttonStyle(DashboardPressButtonStyle())
        .accessibilityElement(children: .combine)
        .accessibilityLabel(String(localized: String.LocalizationValue(LocalizationKey.homeContinueReadingCaption)))
        .accessibilityValue(
            "\(row.titleLine), \(String(format: "%d%%", Int((row.scrollProgress * 100).rounded())))"
        )
    }

    private func continueReadingThumbnail(url: URL) -> some View {
        AsyncImage(url: url) { phase in
            switch phase {
            case .success(let image):
                image
                    .resizable()
                    .scaledToFill()
            default:
                Color.clear
            }
        }
        .frame(width: 64, height: 88)
        .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .stroke(AppTheme.cardBorder.opacity(0.5), lineWidth: AppTheme.borderWidthHairline)
        )
    }

    private var randomAccessRow: some View {
        let poolCount = japanSCPListMetadataStore.officialJapaneseTranslationRandomPool.count
        return Button {
            Haptics.medium()
            let branch = homeViewModel.selectedBranch
            if branch.id == BranchIdentifier.scpJapan {
                if let url = japanSCPListMetadataStore.randomOfficialJapaneseTranslationURL() {
                    navigationRouter.pushArticle(url: url)
                } else {
                    navigationRouter.pushArticle(url: branch.randomSCPURL)
                }
            } else {
                navigationRouter.pushArticle(url: branch.randomSCPURL)
            }
        } label: {
            HStack(alignment: .center, spacing: 12) {
                Image(systemName: "square.grid.3x3.fill")
                    .font(.title3.weight(.semibold))
                    .foregroundStyle(AppTheme.brandAccent)
                    .frame(width: 28, alignment: .center)

                VStack(alignment: .leading, spacing: 4) {
                    Text(String(localized: String.LocalizationValue(LocalizationKey.homeRandomCurrentBranchTitle)))
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(AppTheme.textPrimary)
                        .multilineTextAlignment(.leading)
                        .lineLimit(3)
                        .minimumScaleFactor(0.85)
                    Text(String(localized: String.LocalizationValue(LocalizationKey.homeRandomPanelSubtitle)))
                        .font(.caption.weight(.medium))
                        .foregroundStyle(AppTheme.textSecondary)
                        .multilineTextAlignment(.leading)
                        .lineLimit(2)
                }
                .frame(maxWidth: .infinity, alignment: .leading)

                Image(systemName: "chevron.right")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(AppTheme.textSecondary.opacity(0.75))
            }
            .padding(14)
            .foundationCard(style: .standard)
        }
        .buttonStyle(DashboardPressButtonStyle())
        .id(poolCount)
    }

    @ViewBuilder
    private func homeCategoryTile(for category: HomeCategory) -> some View {
        if let item = homeViewModel.homeGridItems.first(where: { $0.category == category }) {
            SectionTile(
                title: localized(item.titleLocalizationKey),
                subtitle: localized(item.subtitleLocalizationKey),
                leading: .systemSymbol(item.systemImageName),
                emphasizeTitle: true,
                isWide: false,
                style: item.category == .jpArticles ? .inverted : .standard,
                scpJapanSpecialChrome: item.category == .jpArticles,
                badge: nil,
                stretchVertically: true,
                showsTrailingChevron: true,
                titleFontOverride: AppTypography.homePillarTitleFont(),
                onTap: {
                    Haptics.medium()
                    handleCategoryTap(item.category)
                }
            )
        }
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
            if homeViewModel.selectedBranch.id == BranchIdentifier.scpJapan {
                navigationRouter.push(.foundationTalesJPAuthorIndex)
            } else {
                navigationRouter.push(.libraryList(.tales))
            }
        case .canons:
            navigationRouter.push(.libraryList(.canons))
        case .gois:
            navigationRouter.push(.libraryList(.goi))
        case .jokes:
            navigationRouter.push(.category(Branch.japan.jokeScpHubURL()))
        }
    }

    private func localized(_ key: String) -> String {
        String(localized: String.LocalizationValue(key))
    }
}

#Preview {
    @Previewable @State var router = NavigationRouter()
    @Previewable @State var vm = HomeViewModel(settingsRepository: SettingsRepository())
    @Previewable @State var repo = ArticleRepository()
    NavigationStack {
        HomeView(
            navigationRouter: router,
            homeViewModel: vm,
            japanSCPListMetadataStore: JapanSCPListMetadataStore(cacheRepository: SCPListCacheRepository()),
            articleRepository: repo,
            onOpenSettings: {}
        )
    }
}
