import SwiftUI

struct ArticleView: View {
    let entryURL: URL
    @Bindable var homeViewModel: HomeViewModel
    @Bindable var navigationRouter: NavigationRouter
    @Bindable var articleRepository: ArticleRepository

    @State private var webViewModel = WebViewModel()
    @State private var articleToolsPresented = false
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
                // 下部ナビバー（ツールバー）とタブバーの上に本文が収まるよう、下端はセーフエリアを尊重する。
                .ignoresSafeArea(edges: .horizontal)

            if webViewModel.isLoading {
                ProgressView()
                    .tint(AppTheme.accentPrimary)
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
                    .tint(AppTheme.accentPrimary)
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
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text(navigationHeadline)
                    .font(.headline)
                    .foregroundStyle(AppTheme.accentPrimary)
                    .lineLimit(1)
            }
            /// タブバーの直上（ナビの下部バー）。右から2番目＝ツールハブ、右端＝オフライン表示。
            ToolbarItem(placement: .bottomBar) {
                HStack(spacing: 14) {
                    Spacer(minLength: 0)
                    Button {
                        articleToolsPresented = true
                    } label: {
                        Image(systemName: "slider.horizontal.3")
                            .font(.body.weight(.semibold))
                            .foregroundStyle(AppTheme.accentPrimary)
                    }
                    .accessibilityLabel(String(localized: String.LocalizationValue(LocalizationKey.articleToolbarActionsHub)))
                    .popover(isPresented: $articleToolsPresented, attachmentAnchor: .point(.top)) {
                        HStack(spacing: 28) {
                            readerFontMenu
                            bookmarkToolbarButton
                            shareToolbarControl
                        }
                        .padding(.horizontal, 22)
                        .padding(.vertical, 16)
                        .frame(minWidth: 260)
                        .background(AppTheme.backgroundPrimary)
                        .presentationCompactAdaptation(.popover)
                    }
                    if !connectivity.isPathSatisfied, articleRepository.isOfflineReady(url: entryURL) {
                        Image(systemName: "icloud.slash")
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(AppTheme.accentPrimary.opacity(0.9))
                            .accessibilityLabel(String(localized: String.LocalizationValue(LocalizationKey.articleOfflineBadge)))
                    }
                }
                .frame(maxWidth: .infinity)
            }
        }
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
        .tint(AppTheme.accentPrimary)
    }

    private func adjustReaderFont(by delta: Double) {
        let before = homeViewModel.fontSizeMultiplier
        homeViewModel.updateFontSizeMultiplier(before + delta)
        guard homeViewModel.fontSizeMultiplier != before else { return }
        Haptics.medium()
    }

    private var readerFontMenu: some View {
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
            .tint(AppTheme.accentPrimary)
        } label: {
            Image(systemName: "textformat.size")
                .font(.title2)
                .foregroundStyle(AppTheme.accentPrimary)
                .frame(width: 44, height: 44)
                .contentShape(Rectangle())
        }
        .menuActionDismissBehavior(.disabled)
        .accessibilityLabel(String(localized: String.LocalizationValue(LocalizationKey.articleQuickReaderAccessibility)))
    }

    private var bookmarkToolbarButton: some View {
        Button {
            let added = articleRepository.toggleBookmark(url: shareURL)
            if added {
                webViewModel.captureSnapshot(for: shareURL)
                Haptics.medium()
            } else {
                Haptics.light()
            }
            articleToolsPresented = false
        } label: {
            Image(systemName: articleRepository.isBookmarked(url: shareURL) ? "bookmark.fill" : "bookmark")
                .font(.title2)
                .foregroundStyle(AppTheme.accentPrimary)
                .frame(width: 44, height: 44)
                .contentShape(Rectangle())
        }
        .accessibilityLabel(String(localized: String.LocalizationValue(LocalizationKey.articleToolbarBookmark)))
    }

    private var shareToolbarControl: some View {
        ShareLink(item: shareURL) {
            Image(systemName: "square.and.arrow.up")
                .font(.title2)
                .foregroundStyle(AppTheme.accentPrimary)
                .frame(width: 44, height: 44)
                .contentShape(Rectangle())
        }
        .accessibilityLabel(String(localized: String.LocalizationValue(LocalizationKey.articleToolbarShare)))
    }
}
