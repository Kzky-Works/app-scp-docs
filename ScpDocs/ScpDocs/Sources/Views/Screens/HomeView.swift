import SwiftUI

struct HomeView: View {
    @Bindable var navigationRouter: NavigationRouter
    private let homeViewModel: HomeViewModel
    @Bindable var purchaseRepository: PurchaseRepository
    private let onOpenScpLibrary: () -> Void

    @State private var searchText = ""

    private let gridColumns = [
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12)
    ]

    init(
        navigationRouter: NavigationRouter,
        homeViewModel: HomeViewModel,
        purchaseRepository: PurchaseRepository,
        onOpenScpLibrary: @escaping () -> Void
    ) {
        self.navigationRouter = navigationRouter
        self.homeViewModel = homeViewModel
        self._purchaseRepository = Bindable(purchaseRepository)
        self.onOpenScpLibrary = onOpenScpLibrary
    }

    var body: some View {
        VStack(spacing: 0) {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    branchHeader

                    randomAccessRow

                    LazyVGrid(columns: gridColumns, spacing: 12) {
                        ForEach(HomeSection.dashboard) { section in
                            dashboardTile(for: section)
                        }
                    }
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 24)
            }

            if !purchaseRepository.isAdRemovalActive {
                AdBannerView()
                    .frame(height: 50)
                    .frame(maxWidth: .infinity)
            }
        }
        .background(AppTheme.backgroundPrimary)
        .navigationTitle(homeViewModel.screenTitle)
        .navigationBarTitleDisplayMode(.large)
        .searchable(
            text: $searchText,
            prompt: String(localized: String.LocalizationValue(LocalizationKey.searchJumpToSCP))
        )
        .onSubmit(of: .search) {
            if navigationRouter.pushJumpToSCPIfPossible(
                query: searchText,
                branchBaseURL: homeViewModel.selectedBranch.baseURL
            ) {
                Haptics.medium()
            }
            searchText = ""
        }
        .preferredColorScheme(.dark)
        .tint(AppTheme.accentPrimary)
    }

    private var branchHeader: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(homeViewModel.branchDisplayTitle)
                .font(.title3.weight(.medium))
                .foregroundStyle(AppTheme.accentPrimary)

            Text(homeViewModel.branchURLLabel)
                .font(.caption.weight(.semibold))
                .foregroundStyle(AppTheme.accentPrimary.opacity(0.85))

            Text(homeViewModel.branchBaseURLDisplay)
                .font(.body.monospaced())
                .foregroundStyle(AppTheme.accentPrimary.opacity(0.95))
                .textSelection(.enabled)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.vertical, 4)
    }

    private var randomAccessRow: some View {
        HStack(alignment: .top, spacing: 12) {
            randomAccessCard(
                title: localized(LocalizationKey.homeRandomCurrentBranchTitle),
                systemImageName: "shuffle",
                action: {
                    Haptics.medium()
                    navigationRouter.pushArticle(url: homeViewModel.selectedBranch.randomSCPURL)
                }
            )
            randomAccessCard(
                title: localized(LocalizationKey.homeRandomInternationalTitle),
                systemImageName: "globe",
                action: {
                    Haptics.medium()
                    navigationRouter.pushArticle(url: Branch.internationalHubRandomSCPURL)
                }
            )
        }
    }

    private func randomAccessCard(title: String, systemImageName: String, action: @escaping () -> Void) -> some View {
        let cornerRadius: CGFloat = 6
        return Button(action: action) {
            HStack(alignment: .center, spacing: 10) {
                Image(systemName: systemImageName)
                    .font(.title3.weight(.semibold))
                    .foregroundStyle(AppTheme.accentPrimary)
                    .frame(width: 26, alignment: .center)

                Text(title)
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(AppTheme.accentPrimary)
                    .multilineTextAlignment(.leading)
                    .lineLimit(3)
                    .minimumScaleFactor(0.85)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding(12)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(AppTheme.backgroundPrimary)
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .stroke(AppTheme.accentPrimary.opacity(0.55), lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }

    @ViewBuilder
    private func dashboardTile(for section: HomeSection) -> some View {
        let branch = homeViewModel.selectedBranch
        switch section {
        case .jpArchive:
            SectionTile(
                title: localized(section.titleLocalizationKey),
                subtitle: localized(section.subtitleLocalizationKey),
                systemImageName: section.systemImageName,
                onTap: {
                    Haptics.medium()
                    homeViewModel.selectBranch(id: BranchIdentifier.scpJapan)
                    navigationRouter.push(.scpJapanArchiveSeries)
                }
            )
        case .enArchive:
            SectionTile(
                title: localized(section.titleLocalizationKey),
                subtitle: localized(section.subtitleLocalizationKey),
                systemImageName: section.systemImageName,
                onTap: {
                    Haptics.medium()
                    homeViewModel.selectBranch(id: BranchIdentifier.scpWikiEN)
                    navigationRouter.push(.archiveIndex(branchId: BranchIdentifier.scpWikiEN))
                }
            )
        case .scpLibrary:
            SectionTile(
                title: localized(section.titleLocalizationKey),
                subtitle: localized(section.subtitleLocalizationKey),
                systemImageName: section.systemImageName,
                onTap: {
                    Haptics.medium()
                    onOpenScpLibrary()
                }
            )
        case .international:
            SectionTile(
                title: localized(section.titleLocalizationKey),
                subtitle: localized(section.subtitleLocalizationKey),
                systemImageName: section.systemImageName,
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
                systemImageName: section.systemImageName,
                onTap: {
                    Haptics.medium()
                    navigationRouter.push(.category(branch.guideHubURL()))
                }
            )
        case .events:
            SectionTile(
                title: localized(section.titleLocalizationKey),
                subtitle: localized(section.subtitleLocalizationKey),
                systemImageName: section.systemImageName,
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
    @Previewable @State var purchases = PurchaseRepository()
    NavigationStack {
        HomeView(
            navigationRouter: router,
            homeViewModel: vm,
            purchaseRepository: purchases,
            onOpenScpLibrary: {}
        )
    }
}
