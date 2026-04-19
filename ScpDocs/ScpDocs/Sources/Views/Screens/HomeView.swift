import SwiftUI

struct HomeView: View {
    @Bindable var navigationRouter: NavigationRouter
    private let homeViewModel: HomeViewModel
    private let japanSCPListMetadataStore: JapanSCPListMetadataStore
    private let onOpenScpLibrary: () -> Void

    @State private var searchText = ""

    init(
        navigationRouter: NavigationRouter,
        homeViewModel: HomeViewModel,
        japanSCPListMetadataStore: JapanSCPListMetadataStore,
        onOpenScpLibrary: @escaping () -> Void
    ) {
        self.navigationRouter = navigationRouter
        self.homeViewModel = homeViewModel
        self.japanSCPListMetadataStore = japanSCPListMetadataStore
        self.onOpenScpLibrary = onOpenScpLibrary
    }

    var body: some View {
        VStack(spacing: 0) {
            VStack(spacing: 8) {
                dashboardHeaderCard

                homeSearchField

                randomAccessRow

                GeometryReader { geo in
                    let rowGap: CGFloat = 8
                    let hStackGap: CGFloat = 12
                    let innerW = geo.size.width
                    let totalH = geo.size.height

                    if innerW.isFinite, totalH.isFinite, innerW > 0, totalH > 0 {
                        let bigH = max(0, (totalH - 2 * rowGap) / 2)
                        let smallH = max(0, bigH / 2)
                        let jpW = max(0, (innerW - hStackGap) * 3 / 5)
                        let enW = max(0, (innerW - hStackGap) * 2 / 5)

                        VStack(spacing: rowGap) {
                            HStack(spacing: hStackGap) {
                                dashboardTile(for: .jpArchive, stretchVertically: true)
                                    .frame(width: jpW, height: bigH)
                                dashboardTile(for: .enArchive, stretchVertically: true)
                                    .frame(width: enW, height: bigH)
                            }
                            .frame(height: bigH)

                            HStack(spacing: hStackGap) {
                                dashboardTile(for: .scpLibrary, stretchVertically: true)
                                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                                dashboardTile(for: .international, stretchVertically: true)
                                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                            }
                            .frame(height: smallH)

                            HStack(spacing: hStackGap) {
                                dashboardTile(for: .guide, stretchVertically: true)
                                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                                dashboardTile(for: .events, stretchVertically: true)
                                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                            }
                            .frame(height: smallH)
                        }
                        .frame(width: innerW, height: totalH, alignment: .top)
                    } else {
                        Color.clear
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                    }
                }
                .frame(maxHeight: .infinity)
            }
            .padding(.horizontal, 16)
            .padding(.top, 2)
            .padding(.bottom, 8)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        }
        .background(AppTheme.backgroundPrimary)
        .toolbar(.hidden, for: .navigationBar)
        .tint(AppTheme.brandAccent)
    }

    private var homeSearchField: some View {
        HStack(spacing: 10) {
            Image(systemName: "magnifyingglass")
                .font(.body.weight(.semibold))
                .foregroundStyle(AppTheme.textSecondary)
                .frame(width: 22, alignment: .center)

            TextField(
                "",
                text: $searchText,
                prompt: Text(String(localized: String.LocalizationValue(LocalizationKey.searchJumpToSCP)))
                    .foregroundStyle(AppTheme.textSecondary)
            )
            .textInputAutocapitalization(.never)
            .autocorrectionDisabled()
            .submitLabel(.search)
            .onSubmit(performSearchSubmit)
            .foregroundStyle(AppTheme.textPrimary)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .background(AppTheme.surfaceCard)
        .clipShape(RoundedRectangle(cornerRadius: AppTheme.cornerRadiusCard, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: AppTheme.cornerRadiusCard, style: .continuous)
                .stroke(AppTheme.borderSubtle, lineWidth: AppTheme.borderWidthHairline)
        )
    }

    private func performSearchSubmit() {
        if navigationRouter.pushJumpToSCPIfPossible(
            query: searchText,
            branchBaseURL: homeViewModel.selectedBranch.baseURL
        ) {
            Haptics.medium()
        }
        searchText = ""
    }

    private var dashboardHeaderCard: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: "shield.checkered")
                .font(.title2.weight(.semibold))
                .foregroundStyle(AppTheme.brandAccent)

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
                    HStack(spacing: 6) {
                        Text(homeViewModel.branchDisplayTitle)
                            .font(.title3.weight(.semibold))
                            .foregroundStyle(AppTheme.textPrimary)
                        Image(systemName: "chevron.up.chevron.down")
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(AppTheme.textSecondary)
                    }
                }
                .buttonStyle(.plain)

                Text(String(localized: String.LocalizationValue(LocalizationKey.homeDashboardMotto)))
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(AppTheme.textSecondary)
                    .monospaced()
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            Spacer(minLength: 0)
        }
        .padding(12)
        .foundationCard(style: .standard)
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

                Image(systemName: "arrow.right")
                    .font(.body.weight(.semibold))
                    .foregroundStyle(AppTheme.brandAccent)
            }
            .padding(14)
            .foundationCard(style: .standard)
        }
        .buttonStyle(DashboardPressButtonStyle())
        .id(poolCount)
    }

    @ViewBuilder
    private func dashboardTile(for section: HomeSection, stretchVertically: Bool = false) -> some View {
        let branch = homeViewModel.selectedBranch
        let badge = String(localized: String.LocalizationValue(section.badgeLocalizationKey))
        let style: FoundationCardStyle = switch section {
        case .jpArchive: .inverted
        case .events: .danger
        default: .standard
        }
        let isWide = section == .jpArchive

        switch section {
        case .jpArchive:
            SectionTile(
                title: localized(section.titleLocalizationKey),
                subtitle: localized(section.subtitleLocalizationKey),
                leading: .asset("HomeScpLogo"),
                emphasizeTitle: true,
                isWide: isWide,
                style: style,
                badge: badge,
                stretchVertically: stretchVertically,
                onTap: {
                    Haptics.medium()
                    homeViewModel.selectBranch(id: BranchIdentifier.scpJapan)
                    navigationRouter.push(.scpJapanArchive)
                }
            )
        case .enArchive:
            SectionTile(
                title: localized(section.titleLocalizationKey),
                subtitle: localized(section.subtitleLocalizationKey),
                leading: .none,
                emphasizeTitle: true,
                isWide: false,
                style: style,
                badge: badge,
                stretchVertically: stretchVertically,
                onTap: {
                    Haptics.medium()
                    homeViewModel.selectBranch(id: BranchIdentifier.scpWikiEN)
                    navigationRouter.push(.scpEnglishArchive)
                }
            )
        case .scpLibrary:
            SectionTile(
                title: localized(section.titleLocalizationKey),
                subtitle: localized(section.subtitleLocalizationKey),
                leading: .none,
                isWide: isWide,
                style: style,
                badge: badge,
                stretchVertically: stretchVertically,
                onTap: {
                    Haptics.medium()
                    onOpenScpLibrary()
                }
            )
        case .international:
            SectionTile(
                title: localized(section.titleLocalizationKey),
                subtitle: localized(section.subtitleLocalizationKey),
                leading: .none,
                isWide: isWide,
                style: style,
                badge: badge,
                stretchVertically: stretchVertically,
                onTap: {
                    Haptics.medium()
                    homeViewModel.selectBranch(id: BranchIdentifier.scpInternational)
                    navigationRouter.push(.category(Branch.international.internationalBranchesPortalURL()))
                }
            )
        case .guide:
            SectionTile(
                title: localized(section.titleLocalizationKey),
                subtitle: localized(section.subtitleLocalizationKey),
                leading: .none,
                isWide: isWide,
                style: style,
                badge: badge,
                stretchVertically: stretchVertically,
                onTap: {
                    Haptics.medium()
                    navigationRouter.push(.staffGuideIndex)
                }
            )
        case .events:
            SectionTile(
                title: localized(section.titleLocalizationKey),
                subtitle: localized(section.subtitleLocalizationKey),
                leading: .none,
                isWide: isWide,
                style: style,
                badge: badge,
                stretchVertically: stretchVertically,
                onTap: {
                    Haptics.medium()
                    navigationRouter.push(.category(branch.eventsHubURL()))
                }
            )
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
            japanSCPListMetadataStore: JapanSCPListMetadataStore(cacheRepository: SCPListCacheRepository()),
            onOpenScpLibrary: {}
        )
    }
}
