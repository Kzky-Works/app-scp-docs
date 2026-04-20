import SwiftUI

struct HomeView: View {
    @Bindable var navigationRouter: NavigationRouter
    private let homeViewModel: HomeViewModel
    private let japanSCPListMetadataStore: JapanSCPListMetadataStore

    @Environment(\.scpHomeAdBottomReserve) private var homeAdBottomReserve

    private let homeCategoryRowSpacing: CGFloat = 12

    init(
        navigationRouter: NavigationRouter,
        homeViewModel: HomeViewModel,
        japanSCPListMetadataStore: JapanSCPListMetadataStore
    ) {
        self.navigationRouter = navigationRouter
        self.homeViewModel = homeViewModel
        self.japanSCPListMetadataStore = japanSCPListMetadataStore
    }

    var body: some View {
        VStack(spacing: 0) {
            VStack(spacing: 8) {
                dashboardHeaderCard

                randomAccessRow

                GeometryReader { geometry in
                    let totalH = max(0, geometry.size.height)
                    let innerH = max(0, totalH - homeCategoryRowSpacing * 2)
                    let topRowH = innerH * 5 / 11
                    let midRowH = innerH * 3 / 11
                    let bottomRowH = innerH * 3 / 11
                    let rowWidth = geometry.size.width
                    let topInnerWidth = max(0, rowWidth - homeCategoryRowSpacing)
                    let jpWidth = topInnerWidth * 3 / 5
                    let mainWidth = topInnerWidth * 2 / 5

                    VStack(spacing: homeCategoryRowSpacing) {
                        HStack(spacing: homeCategoryRowSpacing) {
                            homeCategoryTile(for: .jpArticles)
                                .frame(width: jpWidth, height: topRowH)
                            homeCategoryTile(for: .originalArticles)
                                .frame(width: mainWidth, height: topRowH)
                        }
                        .frame(height: topRowH)

                        HStack(spacing: homeCategoryRowSpacing) {
                            homeCategoryTile(for: .tales)
                                .frame(maxWidth: .infinity, maxHeight: .infinity)
                            homeCategoryTile(for: .canons)
                                .frame(maxWidth: .infinity, maxHeight: .infinity)
                        }
                        .frame(height: midRowH)

                        HStack(spacing: homeCategoryRowSpacing) {
                            homeCategoryTile(for: .gois)
                                .frame(maxWidth: .infinity, maxHeight: .infinity)
                            homeCategoryTile(for: .jokes)
                                .frame(maxWidth: .infinity, maxHeight: .infinity)
                        }
                        .frame(height: bottomRowH)
                    }
                    .frame(width: rowWidth, height: totalH, alignment: .top)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            }
            .padding(.horizontal, 16)
            .padding(.top, 2)
            .padding(.bottom, 8 + homeAdBottomReserve)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        }
        .background(AppTheme.mainBackground)
        .toolbar(.hidden, for: .navigationBar)
        .tint(AppTheme.brandAccent)
    }

    /// 支部名をナビの大タイトル風に背景へ直書き（カード面・線なし。レイアウト用に透明の箱のみ）。
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
        }
        .padding(.vertical, 4)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.clear)
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
                Image(systemName: "dice.fill")
                    .font(.title3.weight(.semibold))
                    .foregroundStyle(AppTheme.brandAccent)
                    .frame(width: 28, alignment: .center)

                VStack(alignment: .leading, spacing: 4) {
                    Text(String(localized: String.LocalizationValue(LocalizationKey.homeRandomAccessCaption)))
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(AppTheme.textSecondary)
                        .monospaced()
                        .textCase(.uppercase)
                    Text(localized(LocalizationKey.homeRandomCurrentBranchTitle))
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(AppTheme.textPrimary)
                        .multilineTextAlignment(.leading)
                        .lineLimit(3)
                        .minimumScaleFactor(0.85)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
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
                leading: .none,
                emphasizeTitle: true,
                isWide: false,
                style: item.category == .jpArticles ? .inverted : .standard,
                scpJapanSpecialChrome: item.category == .jpArticles,
                badge: String(localized: String.LocalizationValue(item.badgeLocalizationKey)),
                stretchVertically: true,
                showsTrailingChevron: false,
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
            navigationRouter.push(.libraryList(.tales))
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
    NavigationStack {
        HomeView(
            navigationRouter: router,
            homeViewModel: vm,
            japanSCPListMetadataStore: JapanSCPListMetadataStore(cacheRepository: SCPListCacheRepository())
        )
    }
}
