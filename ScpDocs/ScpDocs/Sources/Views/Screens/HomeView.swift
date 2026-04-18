import SwiftUI

struct HomeView: View {
    @Bindable var navigationRouter: NavigationRouter
    @Bindable var articleRepository: ArticleRepository
    private let homeViewModel: HomeViewModel

    @State private var searchText = ""

    init(
        navigationRouter: NavigationRouter,
        articleRepository: ArticleRepository,
        homeViewModel: HomeViewModel
    ) {
        self.navigationRouter = navigationRouter
        self.articleRepository = articleRepository
        self.homeViewModel = homeViewModel
    }

    var body: some View {
        ZStack {
            AppTheme.backgroundPrimary
                .ignoresSafeArea()

            List {
                Section {
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
                    .listRowBackground(AppTheme.backgroundPrimary)
                } header: {
                    Text(homeViewModel.screenTitle)
                        .font(.largeTitle.weight(.semibold))
                        .foregroundStyle(AppTheme.accentPrimary)
                        .textCase(nil)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.vertical, 4)
                }

                Section {
                    ForEach(homeViewModel.selectedBranch.homeCategories) { entry in
                        Button {
                            navigationRouter.push(.category(entry.url))
                        } label: {
                            HStack(spacing: 12) {
                                Text(String(localized: String.LocalizationValue(entry.titleLocalizationKey)))
                                    .foregroundStyle(AppTheme.accentPrimary)
                                Spacer(minLength: 0)
                                if articleRepository.isRead(url: entry.url) {
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundStyle(AppTheme.accentPrimary)
                                        .imageScale(.medium)
                                }
                            }
                        }
                        .listRowBackground(AppTheme.backgroundPrimary)
                    }
                }
            }
            .scrollContentBackground(.hidden)
        }
        .searchable(
            text: $searchText,
            prompt: String(localized: String.LocalizationValue(LocalizationKey.searchJumpToSCP))
        )
        .onSubmit(of: .search) {
            navigationRouter.pushJumpToSCPIfPossible(query: searchText, branchBaseURL: homeViewModel.selectedBranch.baseURL)
            searchText = ""
        }
        .preferredColorScheme(.dark)
        .tint(AppTheme.accentPrimary)
    }
}

#Preview {
    @Previewable @State var router = NavigationRouter()
    @Previewable @State var repo = ArticleRepository()
    @Previewable @State var vm = HomeViewModel(settingsRepository: SettingsRepository())
    HomeView(navigationRouter: router, articleRepository: repo, homeViewModel: vm)
}
