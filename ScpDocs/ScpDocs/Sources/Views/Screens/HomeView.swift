import SwiftUI

// MARK: - ダッシュボード・グリッド（高さ・幅は重みで比例配分し、親の `GeometryReader` に追従して伸縮）

private enum HomeDashboardGridMetrics {
    static let rowGap: CGFloat = 8
    static let columnGap: CGFloat = 12
    /// 上段（アーカイブ 2 枚）: 中段（書庫・INT）: 下段（ガイド・イベント）の高さ比。
    static let rowHeightWeights: (CGFloat, CGFloat, CGFloat) = (2, 1, 1)
    /// 上段の左（SCP-JP）: 右（SCP）の幅比。
    static let archiveColumnWidthWeights: (CGFloat, CGFloat) = (3, 2)

    static func rowHeights(totalHeight: CGFloat, rowGap: CGFloat) -> (CGFloat, CGFloat, CGFloat) {
        let (w0, w1, w2) = rowHeightWeights
        let sum = w0 + w1 + w2
        guard totalHeight.isFinite, totalHeight > 0, sum > 0 else { return (0, 0, 0) }
        let gapsTotal = 2 * rowGap
        let available = max(0, totalHeight - gapsTotal)
        let h0 = available * (w0 / sum)
        let h1 = available * (w1 / sum)
        let h2 = available * (w2 / sum)
        return (h0, h1, h2)
    }

    static func archiveColumnWidths(totalWidth: CGFloat, columnGap: CGFloat) -> (CGFloat, CGFloat) {
        let (wl, wr) = archiveColumnWidthWeights
        let sum = wl + wr
        guard totalWidth.isFinite, totalWidth > 0, sum > 0 else { return (0, 0) }
        let inner = max(0, totalWidth - columnGap)
        let left = inner * (wl / sum)
        let right = inner * (wr / sum)
        return (left, right)
    }
}

struct HomeView: View {
    @Bindable var navigationRouter: NavigationRouter
    private let homeViewModel: HomeViewModel
    private let japanSCPListMetadataStore: JapanSCPListMetadataStore
    private let onOpenScpLibrary: () -> Void

    @Environment(\.scpHomeAdBottomReserve) private var homeAdBottomReserve

    init(
        navigationRouter: NavigationRouter,
        homeViewModel: HomeViewModel,
        japanSCPListMetadataStore: JapanSCPListMetadataStore,
        onOpenScpLibrary: @escaping () -> Void
    ) {
        self.navigationRouter = navigationRouter
        self.homeViewModel = homeViewModel
        self.japanSCPListMetadataStore = japanSCPListMetadataStore
        self.onOpenScpLibrary = onOpenScpLibrary
    }

    var body: some View {
        VStack(spacing: 0) {
            VStack(spacing: 8) {
                dashboardHeaderCard

                randomAccessRow

                GeometryReader { geo in
                    let innerW = geo.size.width
                    let totalH = geo.size.height
                    let rowGap = HomeDashboardGridMetrics.rowGap
                    let colGap = HomeDashboardGridMetrics.columnGap

                    if innerW.isFinite, totalH.isFinite, innerW > 0, totalH > 0 {
                        let (rowTop, rowMid, rowBot) = HomeDashboardGridMetrics.rowHeights(totalHeight: totalH, rowGap: rowGap)
                        let (jpW, enW) = HomeDashboardGridMetrics.archiveColumnWidths(totalWidth: innerW, columnGap: colGap)

                        VStack(spacing: rowGap) {
                            HStack(spacing: colGap) {
                                dashboardTile(for: .jpArchive, stretchVertically: true)
                                    .frame(width: jpW, height: rowTop)
                                dashboardTile(for: .enArchive, stretchVertically: true)
                                    .frame(width: enW, height: rowTop)
                            }
                            .frame(height: rowTop)

                            HStack(spacing: colGap) {
                                dashboardTile(for: .scpLibrary, stretchVertically: true)
                                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                                dashboardTile(for: .international, stretchVertically: true)
                                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                            }
                            .frame(height: rowMid)

                            HStack(spacing: colGap) {
                                dashboardTile(for: .guide, stretchVertically: true)
                                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                                dashboardTile(for: .events, stretchVertically: true)
                                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                            }
                            .frame(height: rowBot)
                        }
                        .frame(width: innerW, height: totalH, alignment: .top)
                    } else {
                        Color.clear
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            }
            .padding(.horizontal, 16)
            .padding(.top, 2)
            .padding(.bottom, 8 + homeAdBottomReserve)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        }
        .background(AppTheme.backgroundPrimary)
        .toolbar(.hidden, for: .navigationBar)
        .tint(AppTheme.brandAccent)
    }

    /// 支部名をナビの大タイトル風に背景へ直書き（カード面・線なし。レイアウト用に透明の箱のみ）。
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
                    HStack(alignment: .firstTextBaseline, spacing: 8) {
                        Text(homeViewModel.branchDisplayTitle)
                            .font(.largeTitle.weight(.bold))
                            .foregroundStyle(AppTheme.textPrimary)
                            .multilineTextAlignment(.leading)
                            .lineLimit(3)
                            .minimumScaleFactor(0.75)
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
        }
        .padding(.vertical, 4)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.clear)
    }

    private var randomAccessRow: some View {
        let poolCount = japanSCPListMetadataStore.officialJapaneseTranslationRandomPool.count
        return Button {
            Haptics.medium()
            let branch = homeViewModel.selectedBranch
            if branch.id == BranchIdentifier.scpJapan {
                if let url = japanSCPListMetadataStore.randomOfficialJapaneseTranslationURL() {
                    navigationRouter.pushArticle(url: url)
                } else {
                    navigationRouter.pushArticle(url: branch.randomSCPURL)
                }
            } else {
                navigationRouter.pushArticle(url: branch.randomSCPURL)
            }
        } label: {
            HStack(alignment: .center, spacing: 12) {
                Image(systemName: "dice.fill")
                    .font(.title3.weight(.semibold))
                    .foregroundStyle(AppTheme.brandAccent)
                    .frame(width: 28, alignment: .center)

                VStack(alignment: .leading, spacing: 4) {
                    Text(String(localized: String.LocalizationValue(LocalizationKey.homeRandomAccessCaption)))
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(AppTheme.textSecondary)
                        .monospaced()
                        .textCase(.uppercase)
                    Text(localized(LocalizationKey.homeRandomCurrentBranchTitle))
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(AppTheme.textPrimary)
                        .multilineTextAlignment(.leading)
                        .lineLimit(3)
                        .minimumScaleFactor(0.85)
                }
                .frame(maxWidth: .infinity, alignment: .leading)

                Image(systemName: "arrow.right")
                    .font(.body.weight(.semibold))
                    .foregroundStyle(AppTheme.brandAccent)
            }
            .padding(14)
            .foundationCard(style: .standard)
        }
        .buttonStyle(DashboardPressButtonStyle())
        .id(poolCount)
    }

    @ViewBuilder
    private func dashboardTile(for section: HomeSection, stretchVertically: Bool = false) -> some View {
        let branch = homeViewModel.selectedBranch
        let badge = String(localized: String.LocalizationValue(section.badgeLocalizationKey))
        let style: FoundationCardStyle = switch section {
        case .jpArchive: .inverted
        case .events: .danger
        default: .standard
        }
        let isWide = section == .jpArchive

        switch section {
        case .jpArchive:
            SectionTile(
                title: localized(section.titleLocalizationKey),
                subtitle: localized(section.subtitleLocalizationKey),
                leading: .none,
                emphasizeTitle: true,
                archiveTitleDoubleSize: true,
                isWide: isWide,
                style: style,
                badge: badge,
                stretchVertically: stretchVertically,
                onTap: {
                    Haptics.medium()
                    homeViewModel.selectBranch(id: BranchIdentifier.scpJapan)
                    navigationRouter.push(.scpJapanArchive)
                }
            )
        case .enArchive:
            SectionTile(
                title: localized(section.titleLocalizationKey),
                subtitle: localized(section.subtitleLocalizationKey),
                leading: .none,
                emphasizeTitle: true,
                archiveTitleDoubleSize: true,
                isWide: false,
                style: style,
                badge: badge,
                stretchVertically: stretchVertically,
                onTap: {
                    Haptics.medium()
                    homeViewModel.selectBranch(id: BranchIdentifier.scpJapan)
                    navigationRouter.push(.scpEnglishArchive)
                }
            )
        case .scpLibrary:
            SectionTile(
                title: localized(section.titleLocalizationKey),
                subtitle: localized(section.subtitleLocalizationKey),
                leading: .none,
                isWide: isWide,
                style: style,
                badge: badge,
                stretchVertically: stretchVertically,
                onTap: {
                    Haptics.medium()
                    onOpenScpLibrary()
                }
            )
        case .international:
            SectionTile(
                title: localized(section.titleLocalizationKey),
                subtitle: localized(section.subtitleLocalizationKey),
                leading: .none,
                isWide: isWide,
                style: style,
                badge: badge,
                stretchVertically: stretchVertically,
                onTap: {
                    Haptics.medium()
                    homeViewModel.selectBranch(id: BranchIdentifier.scpInternational)
                    navigationRouter.push(.category(Branch.international.internationalBranchesPortalURL()))
                }
            )
        case .guide:
            SectionTile(
                title: localized(section.titleLocalizationKey),
                subtitle: localized(section.subtitleLocalizationKey),
                leading: .none,
                isWide: isWide,
                style: style,
                badge: badge,
                stretchVertically: stretchVertically,
                onTap: {
                    Haptics.medium()
                    navigationRouter.push(.staffGuideIndex)
                }
            )
        case .events:
            SectionTile(
                title: localized(section.titleLocalizationKey),
                subtitle: localized(section.subtitleLocalizationKey),
                leading: .none,
                isWide: isWide,
                style: style,
                badge: badge,
                stretchVertically: stretchVertically,
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
    NavigationStack {
        HomeView(
            navigationRouter: router,
            homeViewModel: vm,
            japanSCPListMetadataStore: JapanSCPListMetadataStore(cacheRepository: SCPListCacheRepository()),
            onOpenScpLibrary: {}
        )
    }
}
