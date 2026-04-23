import SwiftUI

private enum LibrarySegment: Int, CaseIterable, Identifiable {
    /// レーティング L≥4.0（旧お気に入り／オフライン優先リスト相当）。
    case highRated
    case readLater
    case history

    var id: Int { rawValue }
}

struct LibraryView: View {
    @Bindable var navigationRouter: NavigationRouter
    @Bindable var articleRepository: ArticleRepository
    let homeViewModel: HomeViewModel

    @State private var segment: LibrarySegment = .highRated

    private var urls: [URL] {
        switch segment {
        case .highRated:
            articleRepository.urlsWithRating(atLeast: ArticleRepository.libraryHighRatedThreshold)
        case .readLater:
            articleRepository.allReadLater()
        case .history:
            articleRepository.allHistory()
        }
    }

    private var emptyTitle: String {
        switch segment {
        case .highRated:
            String(localized: String.LocalizationValue(LocalizationKey.libraryEmptyBookmarksTitle))
        case .readLater:
            String(localized: String.LocalizationValue(LocalizationKey.libraryEmptyReadLaterTitle))
        case .history:
            String(localized: String.LocalizationValue(LocalizationKey.libraryEmptyHistoryTitle))
        }
    }

    private var emptyDescription: String {
        switch segment {
        case .highRated:
            String(localized: String.LocalizationValue(LocalizationKey.libraryEmptyBookmarksDescription))
        case .readLater:
            String(localized: String.LocalizationValue(LocalizationKey.libraryEmptyReadLaterDescription))
        case .history:
            String(localized: String.LocalizationValue(LocalizationKey.libraryEmptyHistoryDescription))
        }
    }

    private var emptyStateIcon: String {
        switch segment {
        case .highRated:
            "gauge.with.dots.needle.bottom.67percent"
        case .readLater:
            "tray"
        case .history:
            "clock.arrow.circlepath"
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
                            .tag(LibrarySegment.highRated)
                        Text(String(localized: String.LocalizationValue(LocalizationKey.librarySegmentReadLater)))
                            .tag(LibrarySegment.readLater)
                        Text(String(localized: String.LocalizationValue(LocalizationKey.librarySegmentHistory)))
                            .tag(LibrarySegment.history)
                    }
                    .pickerStyle(.segmented)
                    .listRowBackground(AppTheme.mainBackground)
                }

                if urls.isEmpty {
                    Section {
                        ContentUnavailableView {
                            Label(emptyTitle, systemImage: emptyStateIcon)
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
    @Previewable @State var vm = HomeViewModel(
        settingsRepository: SettingsRepository(),
        articleRepository: ArticleRepository()
    )
    NavigationStack {
        LibraryView(navigationRouter: router, articleRepository: repo, homeViewModel: vm)
    }
}
