import SwiftUI

private enum LibrarySegment: Int, CaseIterable, Identifiable {
    case bookmarks
    case history

    var id: Int { rawValue }
}

struct LibraryView: View {
    @Bindable var navigationRouter: NavigationRouter
    @Bindable var articleRepository: ArticleRepository
    let homeViewModel: HomeViewModel

    @State private var segment: LibrarySegment = .bookmarks

    private var urls: [URL] {
        switch segment {
        case .bookmarks:
            articleRepository.allBookmarks()
        case .history:
            articleRepository.allHistory()
        }
    }

    private var emptyTitle: String {
        switch segment {
        case .bookmarks:
            String(localized: String.LocalizationValue(LocalizationKey.libraryEmptyBookmarksTitle))
        case .history:
            String(localized: String.LocalizationValue(LocalizationKey.libraryEmptyHistoryTitle))
        }
    }

    private var emptyDescription: String {
        switch segment {
        case .bookmarks:
            String(localized: String.LocalizationValue(LocalizationKey.libraryEmptyBookmarksDescription))
        case .history:
            String(localized: String.LocalizationValue(LocalizationKey.libraryEmptyHistoryDescription))
        }
    }

    var body: some View {
        ZStack {
            AppTheme.mainBackground
                .ignoresSafeArea()

            List {
                Section {
                    Picker("", selection: $segment) {
                        Text(String(localized: String.LocalizationValue(LocalizationKey.librarySegmentBookmarks)))
                            .tag(LibrarySegment.bookmarks)
                        Text(String(localized: String.LocalizationValue(LocalizationKey.librarySegmentHistory)))
                            .tag(LibrarySegment.history)
                    }
                    .pickerStyle(.segmented)
                    .listRowBackground(AppTheme.mainBackground)
                }

                if urls.isEmpty {
                    Section {
                        ContentUnavailableView {
                            Label(emptyTitle, systemImage: segment == .bookmarks ? "bookmark" : "clock.arrow.circlepath")
                        } description: {
                            Text(emptyDescription)
                        }
                        .foregroundStyle(AppTheme.textSecondary)
                        .listRowBackground(AppTheme.mainBackground)
                    }
                } else {
                    Section {
                        ForEach(urls, id: \.self) { url in
                            Button {
                                navigationRouter.pushArticle(url: url)
                            } label: {
                                FoundationIndexRow(
                                    title: url.lastPathComponent.isEmpty ? (url.host ?? url.absoluteString) : url.lastPathComponent,
                                    subtitle: url.absoluteString,
                                    trailing: {
                                        ArticleRatingMeterView(ratingScore: articleRepository.ratingScore(for: url))
                                    }
                                )
                            }
                            .buttonStyle(.plain)
                            .indexListRowChrome()
                        }
                    }
                }
            }
            .scrollContentBackground(.hidden)
        }
        .navigationTitle(String(localized: String.LocalizationValue(LocalizationKey.libraryTitle)))
        .navigationBarTitleDisplayMode(.inline)
        .tint(AppTheme.textPrimary)
    }
}

#Preview {
    @Previewable @State var router = NavigationRouter()
    @Previewable @State var repo = ArticleRepository()
    @Previewable @State var vm = HomeViewModel(settingsRepository: SettingsRepository())
    NavigationStack {
        LibraryView(navigationRouter: router, articleRepository: repo, homeViewModel: vm)
    }
}
