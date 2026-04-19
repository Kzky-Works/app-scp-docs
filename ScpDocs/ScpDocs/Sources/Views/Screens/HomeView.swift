import SwiftUI

struct HomeView: View {
    @Bindable var navigationRouter: NavigationRouter
    private let homeViewModel: HomeViewModel
    @Bindable var purchaseRepository: PurchaseRepository

    @State private var searchText = ""

    private let gridColumns = [
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12)
    ]

    init(
        navigationRouter: NavigationRouter,
        homeViewModel: HomeViewModel,
        purchaseRepository: PurchaseRepository
    ) {
        self.navigationRouter = navigationRouter
        self.homeViewModel = homeViewModel
        self._purchaseRepository = Bindable(purchaseRepository)
    }

    var body: some View {
        VStack(spacing: 0) {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    branchHeader

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

    @ViewBuilder
    private func dashboardTile(for section: HomeSection) -> some View {
        let branch = homeViewModel.selectedBranch
        switch section {
        case .archive:
            SectionTile(
                title: localized(section.titleLocalizationKey),
                subtitle: localized(section.subtitleLocalizationKey),
                systemImageName: section.systemImageName,
                onTap: {
                    Haptics.medium()
                    navigationRouter.push(.archiveIndex(branchId: homeViewModel.selectedBranch.id))
                }
            )
        case .scpLibrary:
            SectionTile(
                title: localized(section.titleLocalizationKey),
                subtitle: localized(section.subtitleLocalizationKey),
                systemImageName: section.systemImageName,
                onTap: {
                    Haptics.medium()
                    navigationRouter.push(.libraryIndex)
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
                    navigationRouter.push(.category(Branch.international.siteTopHubURL()))
                }
            )
        case .goiAndPersonnel:
            SectionTile(
                title: localized(section.titleLocalizationKey),
                subtitle: localized(section.subtitleLocalizationKey),
                systemImageName: section.systemImageName,
                onTap: {
                    Haptics.medium()
                    navigationRouter.push(.goiPortal)
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
            purchaseRepository: purchases
        )
    }
}
