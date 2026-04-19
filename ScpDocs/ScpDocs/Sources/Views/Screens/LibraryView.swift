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

    private var contentBranch: Branch {
        homeViewModel.selectedBranch
    }

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
            AppTheme.backgroundPrimary
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
                    .listRowBackground(AppTheme.backgroundPrimary)
                }

                if urls.isEmpty {
                    Section {
                        ContentUnavailableView {
                            Label(emptyTitle, systemImage: segment == .bookmarks ? "bookmark" : "clock.arrow.circlepath")
                        } description: {
                            Text(emptyDescription)
                        }
                        .foregroundStyle(AppTheme.accentPrimary.opacity(0.85))
                        .listRowBackground(AppTheme.backgroundPrimary)
                    }
                } else {
                    Section {
                        ForEach(urls, id: \.self) { url in
                            Button {
                                navigationRouter.pushArticle(url: url)
                            } label: {
                                HStack(alignment: .center, spacing: 12) {
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text(url.lastPathComponent.isEmpty ? (url.host ?? url.absoluteString) : url.lastPathComponent)
                                            .font(.body.weight(.medium))
                                            .foregroundStyle(AppTheme.accentPrimary)
                                            .lineLimit(2)
                                        Text(url.absoluteString)
                                            .font(.caption2)
                                            .foregroundStyle(AppTheme.accentPrimary.opacity(0.65))
                                            .lineLimit(1)
                                    }
                                    Spacer(minLength: 0)
                                    if articleRepository.isRead(url: url) {
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
            }
            .scrollContentBackground(.hidden)
        }
        .navigationTitle(String(localized: String.LocalizationValue(LocalizationKey.libraryTitle)))
        .navigationBarTitleDisplayMode(.inline)
        .preferredColorScheme(.dark)
        .tint(AppTheme.accentPrimary)
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
