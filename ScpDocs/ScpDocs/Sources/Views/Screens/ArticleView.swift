import SwiftUI

struct ArticleView: View {
    let entryURL: URL
    @Bindable var homeViewModel: HomeViewModel
    @Bindable var navigationRouter: NavigationRouter
    @Bindable var articleRepository: ArticleRepository

    @State private var webViewModel = WebViewModel()
    @State private var readerBottomNavExpanded = false

    @Bindable var connectivity = ConnectivityMonitor.shared

    @AppStorage(WebViewDiagnostics.minimalConfigurationDefaultsKey) private var webViewDiagnosticMinimal = false

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
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                // 下部ナビ・広告帯の下まで本文を伸ばし、透過 UI の背後に記事が見えるようにする。
                .ignoresSafeArea(edges: [.horizontal, .bottom])

            if webViewModel.isLoading {
                ProgressView()
                    .tint(AppTheme.brandAccent)
                    .scaleEffect(1.15)
            }

            if let failure = webViewModel.loadFailureMessage {
                VStack(spacing: 16) {
                    Text(failure)
                        .font(.subheadline)
                        .foregroundStyle(AppTheme.accentPrimary.opacity(0.95))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 24)
                    Button {
                        webViewModel.load(url: entryURL)
                    } label: {
                        Text(String(localized: String.LocalizationValue(LocalizationKey.articleLoadRetry)))
                            .font(.body.weight(.semibold))
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(AppTheme.brandAccent)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(AppTheme.backgroundPrimary.opacity(0.94))
            }
        }
        .overlay(alignment: .top) {
            if webViewDiagnosticMinimal {
                Text(String(localized: String.LocalizationValue(LocalizationKey.articleDiagnosticMinimalBanner)))
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(AppTheme.accentPrimary)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .frame(maxWidth: .infinity)
                    .background(AppTheme.backgroundPrimary.opacity(0.92))
            }
        }
        .safeAreaInset(edge: .bottom, spacing: 0) {
            readerBottomChrome
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text(navigationHeadline)
                    .font(.headline)
                    .foregroundStyle(AppTheme.accentPrimary)
                    .lineLimit(1)
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                if !connectivity.isPathSatisfied, articleRepository.isOfflineReady(url: entryURL) {
                    Image(systemName: "icloud.slash")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(AppTheme.accentPrimary.opacity(0.9))
                        .accessibilityLabel(String(localized: String.LocalizationValue(LocalizationKey.articleOfflineBadge)))
                }
            }
        }
        .toolbar(.hidden, for: .tabBar)
        .task(id: ArticleRepository.storageKey(for: entryURL)) {
            webViewModel.readerFontSizeMultiplier = homeViewModel.fontSizeMultiplier
            articleRepository.markAsRead(url: entryURL)
            articleRepository.recordHistory(url: entryURL)
            webViewModel.load(url: entryURL)
        }
        .onChange(of: homeViewModel.fontSizeMultiplier) { _, newValue in
            webViewModel.readerFontSizeMultiplier = newValue
            webViewModel.applyReaderFontPresentation()
        }
        .preferredColorScheme(.dark)
        .tint(AppTheme.brandAccent)
    }

    // MARK: - Bottom reader navigation（タブバー非表示時・広告枠の上）

    private var readerBottomChrome: some View {
        Group {
            if readerBottomNavExpanded {
                expandedReaderNavigationBar
            } else {
                collapsedReaderNavHint
            }
        }
        .padding(.horizontal, 16)
        .padding(.bottom, 8)
    }

    private var collapsedReaderNavHint: some View {
        Button {
            Haptics.light()
            readerBottomNavExpanded = true
        } label: {
            Text(String(localized: String.LocalizationValue(LocalizationKey.articleReaderNavTapHint)))
                .font(.caption2.weight(.semibold))
                .foregroundStyle(AppTheme.textPrimary.opacity(0.92))
                .padding(.horizontal, 14)
                .padding(.vertical, 7)
                .background(.ultraThinMaterial.opacity(0.55))
                .clipShape(Capsule())
        }
        .buttonStyle(.plain)
        .frame(maxWidth: .infinity)
    }

    private var expandedReaderNavigationBar: some View {
        VStack(spacing: 10) {
            Button {
                Haptics.light()
                readerBottomNavExpanded = false
            } label: {
                Capsule()
                    .fill(AppTheme.textSecondary.opacity(0.4))
                    .frame(width: 36, height: 5)
            }
            .buttonStyle(.plain)
            .accessibilityLabel(String(localized: String.LocalizationValue(LocalizationKey.articleReaderNavCollapseA11y)))

            HStack(spacing: 4) {
                Button {
                    Haptics.medium()
                    navigationRouter.pop()
                } label: {
                    Image(systemName: "chevron.backward")
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundStyle(AppTheme.textPrimary)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 10)
                }
                .buttonStyle(.plain)
                .accessibilityLabel(String(localized: String.LocalizationValue(LocalizationKey.articleReaderNavBackA11y)))

                readerFontMenuCompact
                bookmarkNavButton
                shareNavButton
            }
        }
        .padding(.vertical, 12)
        .padding(.horizontal, 8)
        .background(.ultraThinMaterial.opacity(0.72))
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .stroke(AppTheme.borderSubtle.opacity(0.35), lineWidth: AppTheme.borderWidthHairline)
        )
    }

    private var readerFontMenuCompact: some View {
        Menu {
            Text("\(Int((homeViewModel.fontSizeMultiplier * 100).rounded()))%")
                .font(.body.monospacedDigit())
            Button {
                adjustReaderFont(by: -0.05)
            } label: {
                Label(
                    String(localized: String.LocalizationValue(LocalizationKey.articleQuickReaderSmaller)),
                    systemImage: "minus.circle"
                )
            }
            Button {
                adjustReaderFont(by: 0.05)
            } label: {
                Label(
                    String(localized: String.LocalizationValue(LocalizationKey.articleQuickReaderLarger)),
                    systemImage: "plus.circle"
                )
            }
            Slider(
                value: Binding(
                    get: { homeViewModel.fontSizeMultiplier },
                    set: { newValue in
                        let before = homeViewModel.fontSizeMultiplier
                        homeViewModel.updateFontSizeMultiplier(newValue)
                        guard homeViewModel.fontSizeMultiplier != before else { return }
                        Haptics.light()
                    }
                ),
                in: 0.75 ... 2.0,
                step: 0.05
            )
            .tint(AppTheme.brandAccent)
        } label: {
            Image(systemName: "textformat.size")
                .font(.system(size: 20, weight: .semibold))
                .foregroundStyle(AppTheme.textPrimary)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 10)
                .contentShape(Rectangle())
        }
        .menuActionDismissBehavior(.disabled)
        .accessibilityLabel(String(localized: String.LocalizationValue(LocalizationKey.articleQuickReaderAccessibility)))
    }

    private var bookmarkNavButton: some View {
        Button {
            let added = articleRepository.toggleBookmark(url: shareURL)
            if added {
                webViewModel.captureSnapshot(for: shareURL)
                Haptics.medium()
            } else {
                Haptics.light()
            }
        } label: {
            Image(systemName: articleRepository.isBookmarked(url: shareURL) ? "bookmark.fill" : "bookmark")
                .font(.system(size: 20, weight: .semibold))
                .foregroundStyle(AppTheme.textPrimary)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 10)
                .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityLabel(String(localized: String.LocalizationValue(LocalizationKey.articleToolbarBookmark)))
    }

    private var shareNavButton: some View {
        ShareLink(item: shareURL) {
            Image(systemName: "square.and.arrow.up")
                .font(.system(size: 20, weight: .semibold))
                .foregroundStyle(AppTheme.textPrimary)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 10)
                .contentShape(Rectangle())
        }
        .accessibilityLabel(String(localized: String.LocalizationValue(LocalizationKey.articleToolbarShare)))
    }

    private func adjustReaderFont(by delta: Double) {
        let before = homeViewModel.fontSizeMultiplier
        homeViewModel.updateFontSizeMultiplier(before + delta)
        guard homeViewModel.fontSizeMultiplier != before else { return }
        Haptics.medium()
    }
}
