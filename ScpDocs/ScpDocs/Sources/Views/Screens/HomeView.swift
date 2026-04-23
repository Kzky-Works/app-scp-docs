import SwiftUI

/// 職員ダッシュボード（Split Hero Grid）。`HomeViewModel` のメトリクスと `NavigationRouter` をバインドする。
struct HomeView: View {
    @Bindable var navigationRouter: NavigationRouter
    private let homeViewModel: HomeViewModel
    @Bindable var articleRepository: ArticleRepository
    var onOpenSettings: () -> Void

    @Environment(\.scpHomeAdBottomReserve) private var homeAdBottomReserve

    private let homeGridSpacing: CGFloat = 12
    /// 右列 1 段の高さ。左列は `2 * splitRowHeight + homeGridSpacing` に合わせる。
    private let splitRowHeight: CGFloat = 78

    init(
        navigationRouter: NavigationRouter,
        homeViewModel: HomeViewModel,
        articleRepository: ArticleRepository,
        onOpenSettings: @escaping () -> Void = {}
    ) {
        self.navigationRouter = navigationRouter
        self.homeViewModel = homeViewModel
        self.articleRepository = articleRepository
        self.onOpenSettings = onOpenSettings
    }

    var body: some View {
        ScrollView {
            VStack(spacing: homeGridSpacing) {
                dashboardHeaderCard

                sectionPersonnelStatus

                sectionSplitHeroGrid

                sectionDailyAssignment

                sectionSupportHubs
            }
            .padding(.horizontal, 16)
            .padding(.top, 2)
            .padding(.bottom, 8 + homeAdBottomReserve)
        }
        .scrollIndicators(.hidden)
        .background(AppTheme.mainBackground)
        .toolbar(.hidden, for: .navigationBar)
        .tint(AppTheme.brandAccent)
    }

    // MARK: - Section A: Personnel Status

    private var sectionPersonnelStatus: some View {
        Group {
            if let resumeURL = homeViewModel.continueReadingFromPersonnelURL {
                Button {
                    Haptics.medium()
                    navigationRouter.pushArticle(url: resumeURL)
                } label: {
                    terminalPanel {
                        VStack(alignment: .leading, spacing: 6) {
                            Text(String(localized: String.LocalizationValue(LocalizationKey.homePersonnelResumeMission)))
                                .font(.caption.weight(.heavy))
                                .foregroundStyle(AppTheme.terminalSilver)
                                .tracking(1.2)
                            Text(homeViewModel.resumeMissionIdentifier.uppercased(with: homeViewModel.resolvedLocale))
                                .font(.title3.weight(.bold))
                                .foregroundStyle(AppTheme.textPrimary)
                                .lineLimit(2)
                                .minimumScaleFactor(0.75)
                            Text(homeViewModel.resumeMissionTitle)
                                .font(.subheadline.weight(.medium))
                                .foregroundStyle(AppTheme.textSecondary)
                                .lineLimit(3)
                                .minimumScaleFactor(0.85)
                        }
                        HStack {
                            Spacer()
                            Image(systemName: "chevron.right")
                                .font(.caption.weight(.semibold))
                                .foregroundStyle(AppTheme.terminalSilver.opacity(0.75))
                        }
                    }
                }
                .buttonStyle(DashboardPressButtonStyle())
            } else {
                Button {
                    Haptics.medium()
                    if let u = homeViewModel.randomDiscoveryURL {
                        navigationRouter.pushArticle(url: u)
                    } else {
                        navigationRouter.pushArticle(url: homeViewModel.selectedBranch.randomSCPURL)
                    }
                } label: {
                    terminalPanel {
                        VStack(alignment: .leading, spacing: 6) {
                            Text(String(localized: String.LocalizationValue(LocalizationKey.homePersonnelRandomDiscovery)))
                                .font(.caption.weight(.heavy))
                                .foregroundStyle(AppTheme.terminalSilver)
                                .tracking(1.2)
                            Text(String(localized: String.LocalizationValue(LocalizationKey.homeRandomPanelSubtitle)))
                                .font(.subheadline.weight(.medium))
                                .foregroundStyle(AppTheme.textSecondary)
                                .lineLimit(3)
                        }
                        HStack {
                            Spacer()
                            Image(systemName: "shuffle")
                                .font(.title3.weight(.semibold))
                                .foregroundStyle(AppTheme.terminalSilver.opacity(0.85))
                        }
                    }
                }
                .buttonStyle(DashboardPressButtonStyle())
            }
        }
    }

    // MARK: - Section B: Split Hero

    private var sectionSplitHeroGrid: some View {
        let leftHeight = splitRowHeight * 2 + homeGridSpacing
        return HStack(alignment: .center, spacing: homeGridSpacing) {
            heroArchiveButton(kind: .jp, isDoubleHeight: true)
                .frame(maxWidth: .infinity)
                .frame(height: leftHeight)

            VStack(spacing: homeGridSpacing) {
                heroArchiveButton(kind: .en, isDoubleHeight: false)
                    .frame(maxWidth: .infinity)
                    .frame(height: splitRowHeight)
                heroArchiveButton(kind: .int, isDoubleHeight: false)
                    .frame(maxWidth: .infinity)
                    .frame(height: splitRowHeight)
            }
            .frame(maxWidth: .infinity)
        }
    }

    private func heroArchiveButton(kind: SCPArticleFeedKind, isDoubleHeight: Bool) -> some View {
        let labels = splitHeroLabels(for: kind)
        let total = homeViewModel.totalCount(for: kind)
        let unread = homeViewModel.unreadCount(for: kind)

        return Button {
            Haptics.medium()
            selectBranch(for: kind)
            navigationRouter.push(.scpArticleCatalogFeed(kind))
        } label: {
            ZStack(alignment: .topTrailing) {
                VStack(alignment: .leading, spacing: isDoubleHeight ? 10 : 6) {
                    Text(labels.title.uppercased(with: homeViewModel.resolvedLocale))
                        .font(isDoubleHeight ? .title2.weight(.heavy) : .subheadline.weight(.heavy))
                        .foregroundStyle(AppTheme.textPrimary)
                        .lineLimit(isDoubleHeight ? 3 : 2)
                        .minimumScaleFactor(0.72)
                    Text(labels.subtitle)
                        .font(isDoubleHeight ? .caption.weight(.semibold) : .caption2.weight(.medium))
                        .foregroundStyle(AppTheme.textSecondary)
                        .lineLimit(isDoubleHeight ? 3 : 2)
                        .minimumScaleFactor(0.8)
                    Spacer(minLength: 0)
                    Text(metricsSummary(total: total, unread: unread))
                        .font(.caption2.weight(.semibold))
                        .foregroundStyle(AppTheme.terminalSilver.opacity(0.92))
                        .monospaced()
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)

                if unread > 0 {
                    Circle()
                        .fill(AppTheme.terminalSilver.opacity(0.95))
                        .frame(width: 7, height: 7)
                        .padding(10)
                        .accessibilityHidden(true)
                }
            }
            .padding(14)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
            .background(
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .fill(AppTheme.cardStandard)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .stroke(AppTheme.terminalSilver.opacity(0.9), lineWidth: 1)
            )
        }
        .buttonStyle(DashboardPressButtonStyle())
    }

    // MARK: - Section C: Daily Assignment

    private var sectionDailyAssignment: some View {
        Group {
            if let url = homeViewModel.dailyAssignmentURL {
                Button {
                    Haptics.medium()
                    navigationRouter.pushArticle(url: url)
                } label: {
                    terminalPanel {
                        HStack(alignment: .center, spacing: 12) {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(String(localized: String.LocalizationValue(LocalizationKey.homePersonnelDailyAssignment)))
                                    .font(.caption2.weight(.heavy))
                                    .foregroundStyle(AppTheme.terminalSilver)
                                    .tracking(1.1)
                                Text(homeViewModel.dailyAssignmentIdentifier.uppercased(with: homeViewModel.resolvedLocale))
                                    .font(.footnote.weight(.bold))
                                    .foregroundStyle(AppTheme.textPrimary)
                                    .lineLimit(1)
                                Text(homeViewModel.dailyAssignmentTitle)
                                    .font(.subheadline.weight(.medium))
                                    .foregroundStyle(AppTheme.textSecondary)
                                    .lineLimit(2)
                                    .minimumScaleFactor(0.85)
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                            Image(systemName: "arrow.right.circle")
                                .font(.title3.weight(.semibold))
                                .foregroundStyle(AppTheme.terminalSilver.opacity(0.85))
                        }
                    }
                }
                .buttonStyle(DashboardPressButtonStyle())
            } else {
                terminalPanel {
                    HStack(alignment: .top, spacing: 12) {
                        VStack(alignment: .leading, spacing: 6) {
                            Text(String(localized: String.LocalizationValue(LocalizationKey.homePersonnelDailyAssignment)))
                                .font(.caption2.weight(.heavy))
                                .foregroundStyle(AppTheme.terminalSilver)
                                .tracking(1.1)
                            Text(String(localized: String.LocalizationValue(LocalizationKey.homePersonnelDailyAssignmentEmptyTitle)))
                                .font(.subheadline.weight(.heavy))
                                .foregroundStyle(AppTheme.brandAccent)
                                .tracking(0.6)
                                .lineLimit(3)
                                .minimumScaleFactor(0.78)
                            Text(String(localized: String.LocalizationValue(LocalizationKey.homePersonnelDailyAssignmentEmptySubtitle)))
                                .font(.caption.weight(.medium))
                                .foregroundStyle(AppTheme.textSecondary)
                                .lineLimit(4)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        Image(systemName: "exclamationmark.triangle")
                            .font(.title3.weight(.semibold))
                            .foregroundStyle(AppTheme.brandAccent.opacity(0.9))
                    }
                }
                .accessibilityElement(children: .combine)
            }
        }
    }

    // MARK: - Section D: Support Hubs (2×2)

    private var sectionSupportHubs: some View {
        LazyVGrid(
            columns: [
                GridItem(.flexible(), spacing: homeGridSpacing),
                GridItem(.flexible(), spacing: homeGridSpacing)
            ],
            spacing: homeGridSpacing
        ) {
            ForEach([HomeCategory.tales, HomeCategory.gois, HomeCategory.canons, HomeCategory.jokes], id: \.self) { category in
                supportHubTile(category: category)
            }
        }
    }

    private func supportHubTile(category: HomeCategory) -> some View {
        let item = homeViewModel.homeGridItems.first(where: { $0.category == category })
        let title = item.map { localized($0.titleLocalizationKey) } ?? ""
        return Button {
            Haptics.medium()
            handleCategoryTap(category)
        } label: {
            HStack(spacing: 10) {
                Image(systemName: item?.systemImageName ?? "square.grid.2x2")
                    .font(.body.weight(.semibold))
                    .foregroundStyle(AppTheme.terminalSilver.opacity(0.9))
                    .frame(width: 28, alignment: .center)
                Text(title)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(AppTheme.textPrimary)
                    .multilineTextAlignment(.leading)
                    .lineLimit(2)
                    .minimumScaleFactor(0.8)
                Spacer(minLength: 0)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 12)
            .frame(maxWidth: .infinity, minHeight: 64, alignment: .leading)
            .background(
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .fill(AppTheme.cardStandard)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .stroke(AppTheme.terminalSilver.opacity(0.85), lineWidth: 1)
            )
        }
        .buttonStyle(DashboardPressButtonStyle())
    }

    // MARK: - Header (branch / motto / search / settings)

    private var dashboardHeaderCard: some View {
        HStack(alignment: .top, spacing: 12) {
            VStack(alignment: .leading, spacing: 6) {
                Menu {
                    ForEach(homeViewModel.availableBranches, id: \.id) { branch in
                        Button {
                            homeViewModel.selectBranch(id: branch.id)
                            Haptics.medium()
                        } label: {
                            Text(String(localized: String.LocalizationValue(branch.displayNameKey)))
                        }
                    }
                } label: {
                    HStack(alignment: .center, spacing: 8) {
                        Text(homeViewModel.homeDashboardBranchTitle)
                            .font(AppTypography.homeBranchTitleFont())
                            .foregroundStyle(AppTheme.textPrimary)
                            .multilineTextAlignment(.leading)
                            .lineLimit(3)
                            .minimumScaleFactor(0.75)
                            .frame(minHeight: AppTypography.homeBranchTitleRowReservedHeight, alignment: .center)
                        Image(systemName: "chevron.up.chevron.down")
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(AppTheme.textSecondary)
                    }
                }
                .buttonStyle(.plain)

                Text(String(localized: String.LocalizationValue(LocalizationKey.homeDashboardMotto)))
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(AppTheme.textSecondary)
                    .monospaced()
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            HStack(spacing: 0) {
                Button {
                    Haptics.light()
                    navigationRouter.push(.homeScpSearch)
                } label: {
                    Image(systemName: "magnifyingglass")
                        .font(.title3.weight(.semibold))
                        .foregroundStyle(AppTheme.brandAccent)
                        .frame(width: 44, height: 44, alignment: .center)
                        .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
                .accessibilityLabel(String(localized: String.LocalizationValue(LocalizationKey.homeSearchButtonAccessibility)))

                Button {
                    Haptics.light()
                    onOpenSettings()
                } label: {
                    Image(systemName: "gearshape")
                        .font(.title3.weight(.semibold))
                        .foregroundStyle(AppTheme.brandAccent)
                        .frame(width: 44, height: 44, alignment: .center)
                        .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
                .accessibilityLabel(String(localized: String.LocalizationValue(LocalizationKey.tabSettings)))
            }
        }
        .padding(.vertical, 4)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.clear)
    }

    // MARK: - Layout helpers

    private func terminalPanel<Content: View>(@ViewBuilder content: () -> Content) -> some View {
        content()
            .padding(14)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .fill(AppTheme.cardStandard)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .stroke(AppTheme.terminalSilver.opacity(0.9), lineWidth: 1)
            )
    }

    private func splitHeroLabels(for kind: SCPArticleFeedKind) -> (title: String, subtitle: String) {
        let branch = homeViewModel.selectedBranch
        switch kind {
        case .jp:
            let d = HomeCategory.jpArticles.gridDescriptor(for: branch)
            return (localized(d.titleLocalizationKey), localized(d.subtitleLocalizationKey))
        case .en:
            let d = HomeCategory.originalArticles.gridDescriptor(for: branch)
            return (localized(d.titleLocalizationKey), localized(d.subtitleLocalizationKey))
        case .int:
            return (
                String(localized: String.LocalizationValue(LocalizationKey.homeSectionInternationalTitle)),
                String(localized: String.LocalizationValue(LocalizationKey.homeSectionInternationalSubtitle))
            )
        case .tales, .gois, .canons, .jokes:
            return ("", "")
        }
    }

    private func metricsSummary(total: Int, unread: Int) -> String {
        String(
            format: String(localized: String.LocalizationValue(LocalizationKey.homeHeroMetricsFormat)),
            locale: homeViewModel.resolvedLocale,
            total,
            unread
        )
    }

    private func selectBranch(for kind: SCPArticleFeedKind) {
        switch kind {
        case .jp:
            homeViewModel.selectBranch(id: BranchIdentifier.scpJapan)
        case .en:
            homeViewModel.selectBranch(id: BranchIdentifier.scpWikiEN)
        case .int:
            homeViewModel.selectBranch(id: BranchIdentifier.scpInternational)
        case .tales, .gois, .canons, .jokes:
            break
        }
    }

    private func handleCategoryTap(_ category: HomeCategory) {
        switch category {
        case .jpArticles:
            homeViewModel.selectBranch(id: BranchIdentifier.scpJapan)
            navigationRouter.push(.scpJapanArchive(initialTagFilters: nil))
        case .originalArticles:
            homeViewModel.selectBranch(id: BranchIdentifier.scpJapan)
            navigationRouter.push(.scpEnglishArchive(initialTagFilters: nil))
        case .tales:
            navigationRouter.push(.scpArticleCatalogFeed(.tales))
        case .canons:
            navigationRouter.push(.scpArticleCatalogFeed(.canons))
        case .gois:
            navigationRouter.push(.scpArticleCatalogFeed(.gois))
        case .jokes:
            navigationRouter.push(.scpArticleCatalogFeed(.jokes))
        }
    }

    private func localized(_ key: String) -> String {
        String(localized: String.LocalizationValue(key))
    }
}

#Preview {
    @Previewable @State var router = NavigationRouter()
    @Previewable @State var vm = HomeViewModel(
        settingsRepository: SettingsRepository(),
        articleRepository: ArticleRepository()
    )
    @Previewable @State var repo = ArticleRepository()
    NavigationStack {
        HomeView(
            navigationRouter: router,
            homeViewModel: vm,
            articleRepository: repo,
            onOpenSettings: {}
        )
    }
}
