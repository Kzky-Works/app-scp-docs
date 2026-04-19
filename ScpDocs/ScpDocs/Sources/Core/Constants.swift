import Foundation

/// ルート `TabView` の選択（ホーム／書庫／設定）。
enum AppRootTab: Hashable {
    case home
    case library
    case settings
}

/// Stable identifiers for foundation branches (not UI-specific).
enum BranchIdentifier {
    static let scpJapan = "scp-jp"
    static let scpWikiEN = "scp-wiki-en"
    static let scpInternational = "scp-int"
}

/// Keys for `Localizable.strings` (keep in sync with `en.lproj` / `ja.lproj`).
enum LocalizationKey {
    static let homeTitle = "home.title"
    static let branchBaseURLLabel = "home.branch_url_label"

    static let categorySiteTop = "category.site_top"
    static let categorySeriesJP1 = "category.series_jp_1"
    static let categorySeriesJP2 = "category.series_jp_2"
    static let categorySeriesJP3 = "category.series_jp_3"
    static let categorySeriesJP4 = "category.series_jp_4"
    static let categorySeriesJP5 = "category.series_jp_5"
    static let categoryTalesJP = "category.tales_jp"
    static let categoryCredits = "category.credits"

    static let categoryENSiteTop = "category.en.site_top"
    static let categoryENSeries1 = "category.en.series_1"
    static let categoryENSeries2 = "category.en.series_2"
    static let categoryENSeries3 = "category.en.series_3"
    static let categoryENSeries4 = "category.en.series_4"
    static let categoryENSeries5 = "category.en.series_5"
    static let categoryENTales = "category.en.tales"
    static let categoryENLicensing = "category.en.licensing"

    static let categoryINTSiteTop = "category.int.site_top"
    static let categoryINTBranches = "category.int.branches"
    static let categoryINTRules = "category.int.rules"
    static let categoryINTTagGuide = "category.int.tag_guide"
    static let categoryINTChat = "category.int.chat"

    static let tabHome = "tab.home"
    static let tabLibrary = "tab.library"
    static let tabSettings = "tab.settings"

    static let dockTapToShowNav = "dock.tap_to_show_nav"
    static let dockOperations = "dock.operations"
    static let dockOperationsNeedArticle = "dock.operations.need_article"

    static let settingsTitle = "settings.title"
    static let settingsSectionBranch = "settings.section.branch"
    static let settingsBranchPicker = "settings.branch_picker"
    static let settingsSectionLocaleReader = "settings.section.locale_reader"
    static let settingsUILanguagePicker = "settings.ui_language.picker"
    static let settingsUILanguageSystem = "settings.ui_language.system"
    static let settingsUILanguageJapanese = "settings.ui_language.japanese"
    static let settingsUILanguageEnglish = "settings.ui_language.english"
    static let settingsReaderFontSize = "settings.reader.font_size"
    static let settingsReaderFontSizeFooter = "settings.reader.font_size.footer"
    static let settingsSectionData = "settings.section.data"
    static let settingsClearHistory = "settings.clear_history"
    static let settingsClearBookmarks = "settings.clear_bookmarks"
    static let settingsClearWebCache = "settings.clear_web_cache"
    static let settingsWebCacheCleared = "settings.web_cache_cleared"
    static let settingsSectionAbout = "settings.section.about"
    static let settingsAppVersion = "settings.app_version"
    static let settingsLicenseCreditTitle = "settings.license.title"
    static let settingsLicenseCreditBody = "settings.license.body"
    static let settingsLicenseLinkTitle = "settings.license.link"
    static let settingsConfirmTitle = "settings.confirm.title"
    static let settingsConfirmDelete = "settings.confirm.delete"
    static let settingsConfirmCancel = "settings.confirm.cancel"
    static let settingsConfirmHistoryMessage = "settings.confirm.history_message"
    static let settingsConfirmBookmarksMessage = "settings.confirm.bookmarks_message"
    static let libraryTitle = "library.title"
    static let librarySegmentBookmarks = "library.segment.bookmarks"
    static let librarySegmentHistory = "library.segment.history"
    static let libraryEmptyBookmarksTitle = "library.empty.bookmarks.title"
    static let libraryEmptyBookmarksDescription = "library.empty.bookmarks.description"
    static let libraryEmptyHistoryTitle = "library.empty.history.title"
    static let libraryEmptyHistoryDescription = "library.empty.history.description"
    static let searchJumpToSCP = "home.search.jump_scp"

    static let homeRandomCurrentBranchTitle = "home.random.current_branch.title"
    static let homeRandomAccessCaption = "home.random.access.caption"
    static let homeDashboardMotto = "home.dashboard.motto"

    static let homePillarJpBadge = "home.pillar.jp_badge"
    static let homePillarEnBadge = "home.pillar.en_badge"
    static let homePillarLibraryBadge = "home.pillar.library_badge"
    static let homePillarInternationalBadge = "home.pillar.international_badge"
    static let homePillarGuideBadge = "home.pillar.guide_badge"
    static let homePillarEventsBadge = "home.pillar.events_badge"

    static let homeSectionJpArchiveTitle = "home.section.jp_archive.title"
    static let homeSectionJpArchiveSubtitle = "home.section.jp_archive.subtitle"
    static let homeSectionEnArchiveTitle = "home.section.en_archive.title"
    static let homeSectionEnArchiveSubtitle = "home.section.en_archive.subtitle"
    static let homeSectionScpLibraryTitle = "home.section.scp_library.title"
    static let homeSectionScpLibrarySubtitle = "home.section.scp_library.subtitle"
    static let homeSectionInternationalTitle = "home.section.international.title"
    static let homeSectionInternationalSubtitle = "home.section.international.subtitle"
    static let homeSectionGuideTitle = "home.section.guide.title"
    static let homeSectionGuideSubtitle = "home.section.guide.subtitle"
    static let guideIndexItemAboutFoundation = "guide.index.item.about_foundation"
    static let guideIndexItemFAQ = "guide.index.item.faq"
    static let guideIndexItemContact = "guide.index.item.contact"
    static let guideIndexItemSiteRules = "guide.index.item.site_rules"
    static let guideIndexItemLicensing = "guide.index.item.licensing"
    static let guideIndexItemJoinSite = "guide.index.item.join_site"
    static let homeSectionEventsTitle = "home.section.events.title"
    static let homeSectionEventsSubtitle = "home.section.events.subtitle"

    static let goiPortalTitle = "goi.portal.title"
    static let goiPortalNativeListTitle = "goi.portal.native_list.title"
    static let goiPortalNativeListSubtitle = "goi.portal.native_list.subtitle"
    static let goiPortalPersonnelTitle = "goi.portal.personnel.title"
    static let goiPortalPersonnelSubtitle = "goi.portal.personnel.subtitle"

    static let libraryCategoryGoITitle = "library.category.goi.title"
    static let libraryCategoryGoISubtitle = "library.category.goi.subtitle"
    static let libraryItemGoIHubMasterEN = "library.item.goi_hub_master_en"

    static let settingsSectionMonetization = "settings.section.monetization"
    static let settingsPurchaseRemoveAds = "settings.purchase.remove_ads"
    static let settingsPurchaseRestore = "settings.purchase.restore"
    static let settingsPurchaseBusy = "settings.purchase.busy"
    static let settingsPurchaseAdFreeActive = "settings.purchase.adfree_active"
    static let settingsPurchaseProductUnavailable = "settings.purchase.product_unavailable"
    static let settingsPurchaseVerificationFailed = "settings.purchase.verification_failed"

    /// Google AdMob（テスト用）。本番では App Store Connect / AdMob コンソールの値に差し替える。
    static let adMobApplicationIDTest = "ca-app-pub-3940256099942544~1458002511"
    static let adMobBannerUnitIDTest = "ca-app-pub-3940256099942544/2934735716"

    static let archiveTitle = "archive.title"
    static let archiveTitleJP = "archive.title.jp"
    static let archiveTitleEN = "archive.title.en"
    static let archiveSegmentLabelTemplate = "archive.segment.label_template"

    static let archiveJpSeriesListTitle = "archive.jp.series_list.title"
    static let archiveJpSeriesPickerAccessibility = "archive.jp.series_picker.accessibility"
    static let archiveJpSegmentPickerAccessibility = "archive.jp.segment_picker.accessibility"
    static let archiveJpOpenWikiIndex = "archive.jp.open_wiki_index"
    static let archiveJpScpRowTitleFormat = "archive.jp.scp.row_title_format"
    /// 一覧 HTML に項目が無い・タイトル抽出できない場合のフォールバック。
    static let archiveJpArticleTitleUnknown = "archive.jp.article.title_unknown"
    static let archiveEnSeriesBlock1 = "archive.en.series_block.1"
    static let archiveEnSeriesBlock2 = "archive.en.series_block.2"
    static let archiveEnSeriesBlock3 = "archive.en.series_block.3"
    static let archiveEnSeriesBlock4 = "archive.en.series_block.4"
    static let archiveEnSeriesBlock5 = "archive.en.series_block.5"
    static let archiveEnSeriesPickerAccessibility = "archive.en.series_picker.accessibility"
    static let archiveEnSegmentPickerAccessibility = "archive.en.segment_picker.accessibility"
    static let archiveEnOpenWikiIndex = "archive.en.open_wiki_index"
    static let archiveEnScpRowTitleFormat = "archive.en.scp.row_title_format"
    /// JP / EN アーカイヴ共通のタイトル不明フォールバック。
    static let archiveArticleTitleUnknown = "archive.article.title_unknown"

    // Phase 14: タグ／オブジェクトクラス フィルタ
    static let archiveFilterTagsSection = "archive.filter.tags.section"
    static let archiveFilterClear = "archive.filter.clear"
    static let archiveFilterTagSearchPlaceholder = "archive.filter.tag_search.placeholder"
    static let archiveFilterNoResults = "archive.filter.no_results"
    static let archiveFilterNoResultsHint = "archive.filter.no_results.hint"
    static let archiveFilterObjectClassAccessibility = "archive.filter.object_class.accessibility"
    static let archiveFilterNoTagsInSegment = "archive.filter.no_tags_in_segment"
    /// アーカイヴ一覧: 各行にタグチップを常時表示するトグル（フィルタ適用時は自動表示）。
    static let archiveListRowTagsToggleAccessibility = "archive.list.row_tags.accessibility"

    static let libraryIndexTitle = "library.index.title"
    static let libraryCategoryTalesTitle = "library.category.tales.title"
    static let libraryCategoryTalesSubtitle = "library.category.tales.subtitle"
    static let libraryCategoryCanonsTitle = "library.category.canons.title"
    static let libraryCategoryCanonsSubtitle = "library.category.canons.subtitle"
    static let libraryCategorySeriesTitle = "library.category.series.title"
    static let libraryCategorySeriesSubtitle = "library.category.series.subtitle"
    static let libraryListSearchPrompt = "library.list.search_prompt"

    static let librarySortWikiOrder = "library.sort.wiki_order"
    static let librarySortTitleAsc = "library.sort.title_asc"
    static let librarySortTitleDesc = "library.sort.title_desc"
    static let librarySortNewest = "library.sort.newest"
    static let librarySortOldest = "library.sort.oldest"
    static let librarySortAuthorAsc = "library.sort.author_asc"
    static let librarySortAuthorHubCount = "library.sort.author_hub_count"
    static let librarySortToolbarAccessibility = "library.sort.toolbar_accessibility"

    static let goiIndexTitle = "goi.index.title"
    static let goiIndexSectionPortals = "goi.index.section.portals"
    static let goiIndexSectionEN = "goi.index.section.en"
    static let goiIndexSectionJP = "goi.index.section.jp"
    static let goiIndexPortalGoiMasterJP = "goi.index.portal.goi_master_jp"
    static let goiIndexPortalGoiFormatsEN = "goi.index.portal.goi_formats_en"
    static let goiIndexPortalInternationalFormats = "goi.index.portal.international_formats"
    static let goiIndexHubAlexylva = "goi.index.hub.alexylva"
    static let goiIndexHubAmbrose = "goi.index.hub.ambrose"
    static let goiIndexHubAnderson = "goi.index.hub.anderson"
    static let goiIndexHubArcadia = "goi.index.hub.arcadia"
    static let goiIndexHubAWCY = "goi.index.hub.awcy"
    static let goiIndexHubBlackQueen = "goi.index.hub.black_queen"
    static let goiIndexHubCI = "goi.index.hub.ci"
    static let goiIndexHubChicago = "goi.index.hub.chicago"
    static let goiIndexHubCotBG = "goi.index.hub.cotbg"
    static let goiIndexHubCotSH = "goi.index.hub.cotsh"
    static let goiIndexHubDeer = "goi.index.hub.deer"
    static let goiIndexHubFactory = "goi.index.hub.factory"
    static let goiIndexHubFifthist = "goi.index.hub.fifthist"
    static let goiIndexHubGOC = "goi.index.hub.goc"
    static let goiIndexHubGruP = "goi.index.hub.gru_p"
    static let goiIndexHubHermanFuller = "goi.index.hub.herman_fuller"
    static let goiIndexHubHI = "goi.index.hub.hi"
    static let goiIndexHubIJAMEA = "goi.index.hub.ijamea"
    static let goiIndexHubMCF = "goi.index.hub.mcf"
    static let goiIndexHubMCD = "goi.index.hub.mcd"
    static let goiIndexHubNobody = "goi.index.hub.nobody"
    static let goiIndexHubORIA = "goi.index.hub.oria"
    static let goiIndexHubOneiroi = "goi.index.hub.oneiroi"
    static let goiIndexHubParawatch = "goi.index.hub.parawatch"
    static let goiIndexHubPrometheus = "goi.index.hub.prometheus"
    static let goiIndexHubSH = "goi.index.hub.sh"
    static let goiIndexHubSPC = "goi.index.hub.spc"
    static let goiIndexHubTMI = "goi.index.hub.tmi"
    static let goiIndexHubUIU = "goi.index.hub.uiu"
    static let goiIndexHubW = "goi.index.hub.w"
    static let goiIndexHubWWS = "goi.index.hub.wws"
    static let goiIndexHubAodaisho = "goi.index.hub.aodaisho"
    static let goiIndexHubPAMWAC = "goi.index.hub.pamwac"
    static let goiIndexHubImaginanimal = "goi.index.hub.imaginanimal"
    static let goiIndexHubElma = "goi.index.hub.elma"
    static let goiIndexHubTokuzika = "goi.index.hub.tokuzika"
    static let goiIndexHubKoigarezaki = "goi.index.hub.koigarezaki"
    static let goiIndexHubSaigaha = "goi.index.hub.saigaha"
    static let goiIndexHubShushuin = "goi.index.hub.shushuin"
    static let goiIndexHubSekiryuClub = "goi.index.hub.sekiryu_club"
    static let goiIndexHubTono = "goi.index.hub.tono"
    static let goiIndexHubJOICLE = "goi.index.hub.joicle"
    static let goiIndexHubJAGPATO = "goi.index.hub.jagpato"
    static let goiIndexHubMeiteigai = "goi.index.hub.meiteigai"
    static let goiIndexHubMujinGetsudo = "goi.index.hub.mujin_getsudo"
    static let goiIndexHubYamizushi = "goi.index.hub.yamizushi"
    static let goiIndexHubYumemi = "goi.index.hub.yumemi"

    static let articleReaderNavTapHint = "article.reader_nav.tap_hint"
    static let articleReaderNavCollapseA11y = "article.reader_nav.collapse.a11y"
    static let articleReaderNavBackA11y = "article.reader_nav.back.a11y"

    static let articleToolbarBookmark = "article.toolbar.bookmark"
    static let articleQuickReaderAccessibility = "article.quick_reader.accessibility"
    static let articleQuickReaderLarger = "article.quick_reader.larger"
    static let articleQuickReaderSmaller = "article.quick_reader.smaller"
    static let articleToolbarActionsHub = "article.toolbar.actions_hub"
    static let articleToolbarShare = "article.toolbar.share"
    static let articleOfflineBadge = "article.offline_badge"
    static let articleLoadTimeout = "article.load.timeout"
    static let articleLoadFailed = "article.load.failed"
    static let articleLoadRetry = "article.load.retry"
    static let articleDiagnosticMinimalBanner = "article.diagnostic.minimal_banner"

    static let settingsSectionWebViewDebug = "settings.section.webview_debug"
    static let settingsWebViewMinimalToggle = "settings.webview.minimal_toggle"
    static let settingsWebViewMinimalFooter = "settings.webview.minimal_footer"
    static let settingsWebViewProbe = "settings.webview.probe"
    static let settingsWebViewProbeFooter = "settings.webview.probe_footer"
}

// MARK: - Phase 13 リモート一覧（Plan B）

/// GitHub Pages / 自前サーバーに配置する `scp_list.json` の取得先。
enum AppRemoteConfig {
    /// `SCPListRemotePayload` の `schemaVersion` と一致させる。
    static let scpListSchemaVersion = 1

    /// 空文字のときはリモート同期を行わない（埋め込み `JapanSCPArchiveTitleData` のみ）。
    /// 本番では HTTPS の絶対 URL に差し替える（例: `https://<user>.github.io/scp-docs/scp_list.json`）。
    static let scpListJSONURLString = ""

    static func resolvedSCPListJSONURL() -> URL? {
        let trimmed = scpListJSONURLString.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty, let url = URL(string: trimmed) else { return nil }
        guard let scheme = url.scheme?.lowercased(), scheme == "https" || scheme == "http" else {
            return nil
        }
        return url
    }
}
