import SwiftUI

struct ArticleView: View {
    let entryURL: URL
    @Bindable var homeViewModel: HomeViewModel
    @Bindable var navigationRouter: NavigationRouter
    @Bindable var articleRepository: ArticleRepository
    private let personnelReadingJournal: PersonnelReadingJournal?
    private let scpArticleFeedCacheRepository: SCPArticleFeedCacheRepository?

    @State private var webViewModel = WebViewModel()
    @State private var readerBottomNavExpanded = false
    @State private var showRatingBar = false
    @State private var articleDetailViewModel: ArticleDetailViewModel
    @State private var showAutoArchiveToast = false
    @State private var lastFirstImageProbeStorageKey: String?
    @State private var sessionStartedAt: Date?
    @State private var scrollDepthPersistTask: Task<Void, Never>?

    @Bindable var connectivity = ConnectivityMonitor.shared

    @AppStorage(WebViewDiagnostics.minimalConfigurationDefaultsKey) private var webViewDiagnosticMinimal = false

    init(
        entryURL: URL,
        homeViewModel: HomeViewModel,
        navigationRouter: NavigationRouter,
        articleRepository: ArticleRepository,
        personnelReadingJournal: PersonnelReadingJournal? = nil,
        scpArticleFeedCacheRepository: SCPArticleFeedCacheRepository? = nil
    ) {
        self.entryURL = entryURL
        self.homeViewModel = homeViewModel
        self.navigationRouter = navigationRouter
        self.articleRepository = articleRepository
        self.personnelReadingJournal = personnelReadingJournal
        self.scpArticleFeedCacheRepository = scpArticleFeedCacheRepository
        _webViewModel = State(initialValue: WebViewModel())
        _readerBottomNavExpanded = State(initialValue: false)
        _articleDetailViewModel = State(
            initialValue: ArticleDetailViewModel(
                articleRepository: articleRepository,
                articleURL: entryURL
            )
        )
    }

    private var shareURL: URL {
        webViewModel.currentURL ?? entryURL
    }

    private var articleRatingBinding: Binding<Double> {
        Binding(
            get: { articleRepository.ratingScore(for: shareURL) },
            set: { applyRatedValue($0) }
        )
    }

    private var navigationHeadline: String {
        if let title = webViewModel.pageTitle, !title.isEmpty {
            return title
        }
        return entryURL.lastPathComponent.isEmpty ? entryURL.host ?? entryURL.absoluteString : entryURL.lastPathComponent
    }

    private var showPostReadTacticalBar: Bool {
        articleRepository.isRead(url: shareURL)
            || webViewModel.scrollDepthFraction >= ArticleDetailViewModel.autoReadCompletionThreshold
    }

    private var canOfferCatalogHops: Bool {
        guard scpArticleFeedCacheRepository != nil else { return false }
        let active = personnelReadingJournal?.activeCatalogFeedKind()
        if let active {
            return active.isTrifoldSCPReportFeed || active.isMultiformArchiveFeed
        }
        return CatalogFeedNavigator.inferCatalogFeed(for: shareURL) != nil
    }

    /// `CatalogFeedNavigator.nextArticleURL` と同一条件。終端では `nil` のため NEXT を出さない（案C）。マルチフォームは常に `nil`（Step 4）。
    private var postReadCatalogNextURL: URL? {
        guard let feedCache = scpArticleFeedCacheRepository else { return nil }
        let kind = CatalogFeedNavigator.effectiveKind(
            active: personnelReadingJournal?.activeCatalogFeedKind(),
            for: shareURL
        )
        guard let k = kind, k.isTrifoldSCPReportFeed else { return nil }
        return CatalogFeedNavigator.nextArticleURL(after: shareURL, kind: k, feedCache: feedCache)
    }

    var body: some View {
        ZStack {
            AppTheme.backgroundPrimary
                .ignoresSafeArea()

            SCPWebView(
                viewModel: webViewModel,
                navigationRouter: navigationRouter,
                showsNativeVerticalScrollIndicator: false,
                onReaderChromeDismissTap: readerBottomNavExpanded
                    ? {
                        readerBottomNavExpanded = false
                        showRatingBar = false
                    }
                    : nil
            )
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .ignoresSafeArea(edges: [.horizontal, .bottom])

            WebViewTrailingScrollIndicator(viewModel: webViewModel)
                .allowsHitTesting(false)
                .ignoresSafeArea(edges: [.horizontal, .bottom])

            if webViewModel.isLoading {
                ProgressView()
                    .tint(AppTheme.brandAccent)
                    .scaleEffect(1.15)
            }

            if showAutoArchiveToast {
                Text(
                    String(
                        format: String(localized: String.LocalizationValue(LocalizationKey.articleAutoArchiveToastFormat)),
                        locale: .current,
                        3.0
                    )
                )
                .font(.caption.weight(.semibold))
                .foregroundStyle(AppTheme.textSecondary.opacity(0.92))
                .padding(.horizontal, 14)
                .padding(.vertical, 8)
                .background(.ultraThinMaterial.opacity(0.65))
                .clipShape(Capsule())
                .transition(.opacity)
                .allowsHitTesting(false)
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
            VStack(spacing: 8) {
                if showPostReadTacticalBar, canOfferCatalogHops {
                    postReadTacticalRow
                }
                if showRatingBar {
                    RatingControlView(rating: articleRatingBinding)
                        .transition(.opacity.combined(with: .move(edge: .bottom)))
                }
                readerBottomChrome
            }
            .animation(.easeInOut(duration: 0.22), value: showRatingBar)
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar(.visible, for: .navigationBar)
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text(navigationHeadline)
                    .font(.headline)
                    .foregroundStyle(AppTheme.accentPrimary)
                    .lineLimit(1)
                    .frame(maxWidth: .infinity)
                    .contentShape(Rectangle())
                    .onTapGesture {
                        collapseReaderChromeIfExpanded()
                    }
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                if !connectivity.isPathSatisfied, articleRepository.isOfflineReady(url: entryURL) {
                    Image(systemName: "icloud.slash")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(AppTheme.accentPrimary.opacity(0.9))
                        .accessibilityLabel(String(localized: String.LocalizationValue(LocalizationKey.articleOfflineBadge)))
                        .contentShape(Rectangle())
                        .onTapGesture {
                            collapseReaderChromeIfExpanded()
                        }
                }
            }
        }
        .toolbar(.hidden, for: .tabBar)
        .task(id: ArticleRepository.storageKey(for: entryURL)) {
            webViewModel.readerFontSizeMultiplier = homeViewModel.fontSizeMultiplier
            articleRepository.recordHistory(url: entryURL)
            sessionStartedAt = Date()
            personnelReadingJournal?.ensureActiveCatalogFeedIfNeeded(for: entryURL)
            webViewModel.prepareScrollRestoreFromPersistedDepth(articleRepository.readingScrollDepth(for: entryURL))
            webViewModel.load(url: entryURL)
        }
        .onDisappear {
            scrollDepthPersistTask?.cancel()
            articleRepository.updateReadingScrollDepth(webViewModel.scrollDepthFraction, for: shareURL)
            let key = ArticleRepository.storageKey(for: shareURL)
            let scroll = articleRepository.readingScrollDepth(for: shareURL)
            let secs = sessionStartedAt.map { Date().timeIntervalSince($0) } ?? 0
            try? personnelReadingJournal?.persistVisitEnd(
                normalizedURLKey: key,
                scrollProgress: scroll,
                addedReadingSeconds: secs
            )
        }
        .onChange(of: webViewModel.scrollDepthFraction) { _, fraction in
            articleDetailViewModel.handleScrollDepthFraction(fraction)
            scheduleScrollDepthPersist(fraction)
        }
        .onChange(of: webViewModel.pageTitle) { _, newTitle in
            articleRepository.updateCachedPageTitle(newTitle, for: shareURL)
        }
        .onChange(of: webViewModel.isLoading) { _, loading in
            guard !loading else { return }
            let key = ArticleRepository.storageKey(for: shareURL)
            guard lastFirstImageProbeStorageKey != key else { return }
            lastFirstImageProbeStorageKey = key
            if articleRepository.cachedFirstImageURL(for: shareURL) != nil { return }
            webViewModel.probeFirstContentImageURL { url in
                articleRepository.updateCachedFirstImageURL(url, for: shareURL)
            }
        }
        .onChange(of: articleDetailViewModel.transientToastToken) { _, _ in
            showAutoArchiveToast = true
            Task {
                try? await Task.sleep(for: .milliseconds(1500))
                await MainActor.run {
                    showAutoArchiveToast = false
                }
            }
        }
        .onChange(of: articleDetailViewModel.ratingBarRevealToken) { _, _ in
            showRatingBar = true
        }
        .onChange(of: homeViewModel.fontSizeMultiplier) { _, newValue in
            webViewModel.readerFontSizeMultiplier = newValue
            webViewModel.applyReaderFontPresentation()
        }
        .tint(AppTheme.brandAccent)
    }

    private func applyRatedValue(_ raw: Double) {
        let clamped = UserArticleData.clampedRating(raw)
        let url = shareURL
        let prev = articleRepository.ratingScore(for: url)
        articleRepository.setRatingScore(clamped, for: url)
        let hi = ArticleRepository.libraryHighRatedThreshold
        if clamped >= hi, prev < hi {
            webViewModel.captureSnapshot(for: url)
        }
        if clamped < hi, prev >= hi {
            OfflineStore.shared.deleteHTML(for: url)
        }
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
                showRatingBar = false
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
                ratingNavButton
                readLaterNavButton
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

    private var ratingNavButton: some View {
        Button {
            Haptics.medium()
            showRatingBar.toggle()
        } label: {
            Image(systemName: showRatingBar ? "gauge.with.dots.needle.bottom.67percent" : "gauge.with.dots.needle.bottom.50percent")
                .font(.system(size: 20, weight: .semibold))
                .foregroundStyle(showRatingBar ? AppTheme.brandAccent : AppTheme.textPrimary)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 10)
                .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityLabel(String(localized: String.LocalizationValue(LocalizationKey.articleRatingNavAccessibility)))
    }

    /// 右端から共有・ここ・評価…の順のため、共有の左隣に配置。
    private var readLaterNavButton: some View {
        Button {
            Haptics.medium()
            articleRepository.toggleReadLater(url: shareURL)
        } label: {
            Image(systemName: articleRepository.isReadLater(url: shareURL) ? "tray.full" : "tray")
                .font(.system(size: 20, weight: .semibold))
                .foregroundStyle(articleRepository.isReadLater(url: shareURL) ? AppTheme.brandAccent : AppTheme.textPrimary)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 10)
                .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityLabel(String(localized: String.LocalizationValue(LocalizationKey.articleReadLaterNavAccessibility)))
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

    private func collapseReaderChromeIfExpanded() {
        guard readerBottomNavExpanded else { return }
        readerBottomNavExpanded = false
        showRatingBar = false
    }

    // MARK: - Step 3: スクロール永続化（スロットリング）とポスト・リーディング

    private func scheduleScrollDepthPersist(_ fraction: Double) {
        scrollDepthPersistTask?.cancel()
        scrollDepthPersistTask = Task { @MainActor in
            try? await Task.sleep(for: .milliseconds(120))
            guard !Task.isCancelled else { return }
            articleRepository.updateReadingScrollDepth(fraction, for: shareURL)
        }
    }

    private var postReadTacticalRow: some View {
        HStack(spacing: 10) {
            if postReadCatalogNextURL != nil {
                Button {
                    Haptics.medium()
                    postReadNavigateNext()
                } label: {
                    Text(String(localized: String.LocalizationValue(LocalizationKey.articlePostReadNextCase)))
                        .font(.caption2.weight(.heavy))
                        .tracking(0.8)
                        .foregroundStyle(AppTheme.brandAccent)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 11)
                        .background(AppTheme.cardStandard)
                        .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                        .overlay(
                            RoundedRectangle(cornerRadius: 10, style: .continuous)
                                .stroke(AppTheme.brandAccent.opacity(0.95), lineWidth: 1.5)
                        )
                }
                .buttonStyle(.plain)
            }

            if postReadIsMultiformRandomOnlyLayout {
                Spacer(minLength: 0)
            }
            Button {
                Haptics.medium()
                postReadNavigateRandom()
            } label: {
                Text(String(localized: String.LocalizationValue(LocalizationKey.articlePostReadRandomCase)))
                    .font(.caption2.weight(.heavy))
                    .tracking(0.8)
                    .foregroundStyle(AppTheme.terminalSilver)
                    .frame(maxWidth: postReadIsMultiformRandomOnlyLayout ? 260 : .infinity)
                    .padding(.vertical, 11)
                    .background(AppTheme.cardStandard)
                    .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                    .overlay(
                        RoundedRectangle(cornerRadius: 10, style: .continuous)
                            .stroke(AppTheme.terminalSilver.opacity(0.9), lineWidth: 1)
                    )
            }
            .buttonStyle(.plain)
            if postReadIsMultiformRandomOnlyLayout {
                Spacer(minLength: 0)
            }
        }
        .padding(.horizontal, 4)
    }

    /// Step 4: マルチフォーム閲覧中は NEXT を出さず RANDOM を視覚的に中央寄せする。
    private var postReadIsMultiformRandomOnlyLayout: Bool {
        guard let k = CatalogFeedNavigator.effectiveKind(
            active: personnelReadingJournal?.activeCatalogFeedKind(),
            for: shareURL
        ) else { return false }
        return k.isMultiformArchiveFeed
    }

    private func postReadNavigateNext() {
        guard let next = postReadCatalogNextURL else { return }
        navigationRouter.replaceTopArticle(with: next)
    }

    private func postReadNavigateRandom() {
        guard let feedCache = scpArticleFeedCacheRepository else { return }
        let kind = CatalogFeedNavigator.effectiveKind(
            active: personnelReadingJournal?.activeCatalogFeedKind(),
            for: shareURL
        )
        guard let k = kind else { return }
        let url: URL?
        if k.isMultiformArchiveFeed {
            url = CatalogFeedNavigator.randomGeneralContentURL(
                excluding: shareURL,
                kind: k,
                feedCache: feedCache,
                articleRepository: articleRepository
            )
        } else {
            url = CatalogFeedNavigator.randomArticleURL(
                excluding: shareURL,
                kind: k,
                feedCache: feedCache,
                articleRepository: articleRepository
            )
        }
        guard let url else { return }
        navigationRouter.replaceTopArticle(with: url)
    }
}
