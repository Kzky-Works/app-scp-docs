import SwiftUI

struct ArticleView: View {
    let entryURL: URL
    @Bindable var navigationRouter: NavigationRouter
    @Bindable var articleRepository: ArticleRepository

    @State private var webViewModel = WebViewModel()
    @Bindable var connectivity = ConnectivityMonitor.shared

    private var shareURL: URL {
        webViewModel.currentURL ?? entryURL
    }

    private var navigationHeadline: String {
        if let title = webViewModel.pageTitle, !title.isEmpty {
            return title
        }
        return entryURL.lastPathComponent.isEmpty ? entryURL.host ?? entryURL.absoluteString : entryURL.lastPathComponent
    }

    var body: some View {
        ZStack {
            AppTheme.backgroundPrimary
                .ignoresSafeArea()

            SCPWebView(viewModel: webViewModel, navigationRouter: navigationRouter)
                .ignoresSafeArea(edges: .bottom)

            if webViewModel.isLoading {
                ProgressView()
                    .tint(AppTheme.accentPrimary)
                    .scaleEffect(1.15)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text(navigationHeadline)
                    .font(.headline)
                    .foregroundStyle(AppTheme.accentPrimary)
                    .lineLimit(1)
            }
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    let added = articleRepository.toggleBookmark(url: shareURL)
                    if added {
                        webViewModel.captureSnapshot(for: shareURL)
                    }
                } label: {
                    Image(systemName: articleRepository.isBookmarked(url: shareURL) ? "bookmark.fill" : "bookmark")
                        .foregroundStyle(AppTheme.accentPrimary)
                }
                .accessibilityLabel(String(localized: String.LocalizationValue(LocalizationKey.articleToolbarBookmark)))
            }
            ToolbarItem(placement: .topBarTrailing) {
                if !connectivity.isPathSatisfied, articleRepository.isOfflineReady(url: entryURL) {
                    Image(systemName: "icloud.slash")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(AppTheme.accentPrimary.opacity(0.9))
                        .accessibilityLabel(String(localized: String.LocalizationValue(LocalizationKey.articleOfflineBadge)))
                }
            }
            ToolbarItem(placement: .topBarTrailing) {
                ShareLink(item: shareURL) {
                    Image(systemName: "square.and.arrow.up")
                        .foregroundStyle(AppTheme.accentPrimary)
                }
            }
        }
        .task(id: ArticleRepository.storageKey(for: entryURL)) {
            articleRepository.markAsRead(url: entryURL)
            articleRepository.recordHistory(url: entryURL)
            webViewModel.load(url: entryURL)
        }
        .preferredColorScheme(.dark)
        .tint(AppTheme.accentPrimary)
    }
}
