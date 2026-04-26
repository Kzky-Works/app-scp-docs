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
    static let settingsSectionAppearance = "settings.section.appearance"
    static let settingsAppearanceDarkModeToggle = "settings.appearance.dark_mode_toggle"
    static let settingsAppearanceDarkModeFooter = "settings.appearance.dark_mode_footer"
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
    static let librarySegmentReadLater = "library.segment.read_later"
    static let libraryEmptyReadLaterTitle = "library.empty.read_later.title"
    static let libraryEmptyReadLaterDescription = "library.empty.read_later.description"
    static let libraryEmptyBookmarksTitle = "library.empty.bookmarks.title"
    static let libraryEmptyBookmarksDescription = "library.empty.bookmarks.description"
    static let libraryEmptyHistoryTitle = "library.empty.history.title"
    static let libraryEmptyHistoryDescription = "library.empty.history.description"
    static let searchJumpToSCP = "home.search.jump_scp"
    static let homeSearchTitle = "home.search.screen.title"
    static let homeSearchPlaceholder = "home.search.screen.placeholder"
    static let homeSearchHint = "home.search.screen.hint"
    static let homeSearchButtonAccessibility = "home.search.button.accessibility"
    static let homeSearchEmpty = "home.search.screen.empty"
    static let homeSearchNoIndex = "home.search.screen.no_index"

    static let homeRandomCurrentBranchTitle = "home.random.current_branch.title"
    static let homeRandomAccessCaption = "home.random.access.caption"
    static let homeRandomPanelSubtitle = "home.random.panel.subtitle"
    static let homeRandomArticleReadSectionTitle = "home.random_article_read.section_title"
    static let homeContinueReadingCaption = "home.continue_reading.caption"
    static let homeContinueReadingEmptyTitle = "home.continue_reading.empty.title"
    static let homeContinueReadingEmptySubtitle = "home.continue_reading.empty.subtitle"
    static let homeContinueReadingAccessibility = "home.continue_reading.accessibility"
    static let homeContinueScrollPercentFormat = "home.continue_reading.scroll_percent_format"
    /// ゲージ右下の数値用（`%lld%%` など）。
    static let homeContinueGaugePercentFormat = "home.continue_reading.gauge_percent"
    static let homeContinueObjectClassFormat = "home.continue_reading.object_class_format"
    /// 続きから読む 1 行目: Wikidot ホストに対応する短い支部名。
    static let homeContinueBranchScpJp = "home.continue_reading.branch.scp_jp"
    static let homeContinueBranchScp = "home.continue_reading.branch.scp"
    static let homeContinueBranchScpInt = "home.continue_reading.branch.scp_int"
    static let homeContinueBranchScpKo = "home.continue_reading.branch.scp_ko"
    static let homeContinueCategoryScpJp = "home.continue_reading.category.scp_jp"
    static let homeContinueCategoryScpMainJp = "home.continue_reading.category.scp_main_jp"
    static let homeContinueCategoryScpEn = "home.continue_reading.category.scp_en"
    static let homeContinueCategoryScpInt = "home.continue_reading.category.scp_int"
    static let homeContinueCategoryTale = "home.continue_reading.category.tale"
    static let homeContinueCategoryCanon = "home.continue_reading.category.canon"
    static let homeContinueCategoryGoi = "home.continue_reading.category.goi"
    static let homeContinueCategoryJoke = "home.continue_reading.category.joke"
    static let homeContinueCategoryOther = "home.continue_reading.category.other"
    /// 続きから読む 1 行目: 国際カタログ（`SCP-INTERNATIONAL` 表記）。
    static let homeContinueCategoryScpInternational = "home.continue_reading.category.scp_international"
    /// 続きから読む 1 行目: Tale 系（複数形表記の `Tales`）。
    static let homeContinueCategoryTales = "home.continue_reading.category.tales"
    static let homePillarCategorySectionCaption = "home.pillar.category_caption"
    static let homeRandomCLIPrefix = "home.random.cli_prefix"
    static let homeRandomCLIWildcard = "home.random.cli_wildcard"
    static let homeRandomExploreSubtitle = "home.random.explore_subtitle"
    static let homeDashboardMotto = "home.dashboard.motto"
    /// ホーム上部の支部名（日本支部選択時のみ「日本支部」を省いた短表記）。
    static let homeDashboardBranchShortJapan = "home.dashboard.branch_short_jp"
    static let homeDashboardBranchShortEN = "home.dashboard.branch_short_en"
    static let homeDashboardBranchShortINT = "home.dashboard.branch_short_int"

    /// Split Hero / 職員ダッシュボード（Step 2）。
    static let homePersonnelResumeMission = "home.personnel.resume_mission"
    static let homePersonnelRandomDiscovery = "home.personnel.random_discovery"
    static let homePersonnelDailyAssignment = "home.personnel.daily_assignment"
    static let homePersonnelDailyAssignmentEmptyTitle = "home.personnel.daily_assignment_empty.title"
    static let homePersonnelDailyAssignmentEmptySubtitle = "home.personnel.daily_assignment_empty.subtitle"
    static let homeHeroMetricsFormat = "home.hero.metrics_format"
    static let homeHeroJpTagline = "home.hero.jp.tagline"
    static let homeHeroEnTagline = "home.hero.en.tagline"
    static let homeHeroIntTagline = "home.hero.int.tagline"
    static let homeHeroCatalogGaugeA11yLabel = "home.hero.catalog_gauge.a11y.label"
    static let homeHeroCatalogGaugeA11yValueFormat = "home.hero.catalog_gauge.a11y.value_format"
    static let homeFeedListTitleJP = "home.feed_list.title.jp"
    static let homeFeedListTitleEN = "home.feed_list.title.en"
    static let homeFeedListTitleINT = "home.feed_list.title.int"
    /// SCP International カタログ下部の横スクロール支部チップ（末尾言語コードで絞り込み）。
    static let intCatalogBranchPickerCaption = "int.catalog_branch_picker.caption"
    static let intCatalogBranchFilterEmptyTitle = "int.catalog_branch_filter.empty.title"
    static let intCatalogBranchFilterEmptySubtitle = "int.catalog_branch_filter.empty.subtitle"
    static let intCatalogBranchChipAll = "int.catalog_branch_chip.all"
    static let intCatalogBranchChipRU = "int.catalog_branch_chip.ru"
    static let intCatalogBranchChipKO = "int.catalog_branch_chip.ko"
    static let intCatalogBranchChipCN = "int.catalog_branch_chip.cn"
    static let intCatalogBranchChipFR = "int.catalog_branch_chip.fr"
    static let intCatalogBranchChipPL = "int.catalog_branch_chip.pl"
    static let intCatalogBranchChipES = "int.catalog_branch_chip.es"
    static let intCatalogBranchChipTH = "int.catalog_branch_chip.th"
    static let intCatalogBranchChipDE = "int.catalog_branch_chip.de"
    static let intCatalogBranchChipIT = "int.catalog_branch_chip.it"
    static let intCatalogBranchChipUA = "int.catalog_branch_chip.ua"
    static let intCatalogBranchChipPTBR = "int.catalog_branch_chip.pt_br"
    static let intCatalogBranchChipCS = "int.catalog_branch_chip.cs"
    static let intCatalogBranchChipZHTR = "int.catalog_branch_chip.zh_tr"
    static let intCatalogBranchChipVN = "int.catalog_branch_chip.vn"
    static let intCatalogBranchChipOther = "int.catalog_branch_chip.other"
    /// ジョーク報告書一覧: `scp-N-jp-j`（日本支部）と `scp-N-j`（本家 J）の切替。
    static let jokeCatalogOriginJP = "joke.catalog_origin.jp"
    static let jokeCatalogOriginMain = "joke.catalog_origin.main"
    static let jokeCatalogOriginPickerAccessibility = "joke.catalog_origin.picker.a11y"
    static let jokeCatalogFilterEmptyTitle = "joke.catalog_filter.empty.title"
    static let jokeCatalogFilterEmptySubtitle = "joke.catalog_filter.empty.subtitle"
    static let homeFeedListTitleTales = "home.feed_list.title.tales"
    static let homeFeedListTitleGois = "home.feed_list.title.gois"
    static let homeFeedListTitleCanons = "home.feed_list.title.canons"
    static let homeFeedListTitleJokes = "home.feed_list.title.jokes"
    static let goiCatalogSourceTabJP = "goi.catalog_source_tab.jp"
    static let goiCatalogSourceTabEN = "goi.catalog_source_tab.en"
    static let goiCatalogSourceTabOther = "goi.catalog_source_tab.other"
    static let goiCatalogSourcePickerAccessibility = "goi.catalog_source_picker.a11y"

    static let canonHubSourcePickerAccessibility = "canon.hub_source_picker.a11y"
    static let canonHubFeedTabEmptyTitle = "canon.hub_feed.tab_empty.title"
    static let canonHubFeedTabEmptySubtitle = "canon.hub_feed.tab_empty.subtitle"
    /// 引数: yyyy/MM/dd（`String(format:locale:)` 用）。
    static let canonCardLastUpdatedFormat = "canon.card.last_updated_format"
    static let goiFeedEmptyNoGroupTags = "goi.feed.empty.no_group_tags"

    static let multiformAuthorUnknown = "multiform.author.unknown"

    static let searchBadgeScpJpCatalog = "search.badge.scp_jp_catalog"
    static let searchBadgeScpEnCatalog = "search.badge.scp_en_catalog"
    static let searchBadgeScpIntCatalog = "search.badge.scp_int_catalog"
    static let searchBadgeTale = "search.badge.tale"
    static let searchBadgeGoi = "search.badge.goi"
    static let searchBadgeCanon = "search.badge.canon"
    static let searchBadgeJoke = "search.badge.joke"
    static let searchBadgeScpJpList = "search.badge.scp_jp_list"

    static let homeSearchScanning = "home.search.scanning"

    static let tacticalEmptyEyebrow = "tactical.empty.eyebrow"
    static let tacticalEmptyArchiveTitle = "tactical.empty.archive.title"
    static let tacticalEmptyArchiveSubtitle = "tactical.empty.archive.subtitle"
    static let tacticalEmptyNetworkTitle = "tactical.empty.network.title"
    static let tacticalEmptyNetworkSubtitle = "tactical.empty.network.subtitle"

    static let settingsTerminalSectionTitle = "settings.terminal.section.title"
    static let settingsTerminalFlavor = "settings.terminal.flavor"
    static let settingsTerminalFlavorFooter = "settings.terminal.flavor.footer"
    static let homeFeedListEmpty = "home.feed_list.empty"

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

    // Phase 15.1: ホーム読者特化 6 ピラー（支部別タイトル／サブタイトル／バッジ）
    static let homeReaderJpArticlesTitleJP = "home.reader.jp_articles.title.jp"
    static let homeReaderJpArticlesTitleEN = "home.reader.jp_articles.title.en"
    static let homeReaderJpArticlesTitleINT = "home.reader.jp_articles.title.int"
    static let homeReaderJpArticlesSubtitleJP = "home.reader.jp_articles.subtitle.jp"
    static let homeReaderJpArticlesSubtitleEN = "home.reader.jp_articles.subtitle.en"
    static let homeReaderJpArticlesSubtitleINT = "home.reader.jp_articles.subtitle.int"

    static let homeReaderOriginalArticlesTitleJP = "home.reader.original_articles.title.jp"
    static let homeReaderOriginalArticlesTitleEN = "home.reader.original_articles.title.en"
    static let homeReaderOriginalArticlesTitleINT = "home.reader.original_articles.title.int"
    static let homeReaderOriginalArticlesSubtitleJP = "home.reader.original_articles.subtitle.jp"
    static let homeReaderOriginalArticlesSubtitleEN = "home.reader.original_articles.subtitle.en"
    static let homeReaderOriginalArticlesSubtitleINT = "home.reader.original_articles.subtitle.int"

    static let homeReaderTalesTitleJP = "home.reader.tales.title.jp"
    static let homeReaderTalesTitleEN = "home.reader.tales.title.en"
    static let homeReaderTalesTitleINT = "home.reader.tales.title.int"
    static let homeReaderTalesSubtitleJP = "home.reader.tales.subtitle.jp"
    static let homeReaderTalesSubtitleEN = "home.reader.tales.subtitle.en"
    static let homeReaderTalesSubtitleINT = "home.reader.tales.subtitle.int"

    static let homeReaderCanonsTitleJP = "home.reader.canons.title.jp"
    static let homeReaderCanonsTitleEN = "home.reader.canons.title.en"
    static let homeReaderCanonsTitleINT = "home.reader.canons.title.int"
    static let homeReaderCanonsSubtitleJP = "home.reader.canons.subtitle.jp"
    static let homeReaderCanonsSubtitleEN = "home.reader.canons.subtitle.en"
    static let homeReaderCanonsSubtitleINT = "home.reader.canons.subtitle.int"

    static let homeReaderGoisTitleJP = "home.reader.gois.title.jp"
    static let homeReaderGoisTitleEN = "home.reader.gois.title.en"
    static let homeReaderGoisTitleINT = "home.reader.gois.title.int"
    static let homeReaderGoisSubtitleJP = "home.reader.gois.subtitle.jp"
    static let homeReaderGoisSubtitleEN = "home.reader.gois.subtitle.en"
    static let homeReaderGoisSubtitleINT = "home.reader.gois.subtitle.int"

    static let homeReaderJokesTitleJP = "home.reader.jokes.title.jp"
    static let homeReaderJokesTitleEN = "home.reader.jokes.title.en"
    static let homeReaderJokesTitleINT = "home.reader.jokes.title.int"
    static let homeReaderJokesSubtitleJP = "home.reader.jokes.subtitle.jp"
    static let homeReaderJokesSubtitleEN = "home.reader.jokes.subtitle.en"
    static let homeReaderJokesSubtitleINT = "home.reader.jokes.subtitle.int"

    static let homeReaderPillar01BadgeJP = "home.reader.pillar.01.badge.jp"
    static let homeReaderPillar02BadgeJP = "home.reader.pillar.02.badge.jp"
    static let homeReaderPillar03BadgeJP = "home.reader.pillar.03.badge.jp"
    static let homeReaderPillar04BadgeJP = "home.reader.pillar.04.badge.jp"
    static let homeReaderPillar05BadgeJP = "home.reader.pillar.05.badge.jp"
    static let homeReaderPillar06BadgeJP = "home.reader.pillar.06.badge.jp"
    static let homeReaderPillar01BadgeEN = "home.reader.pillar.01.badge.en"
    static let homeReaderPillar02BadgeEN = "home.reader.pillar.02.badge.en"
    static let homeReaderPillar03BadgeEN = "home.reader.pillar.03.badge.en"
    static let homeReaderPillar04BadgeEN = "home.reader.pillar.04.badge.en"
    static let homeReaderPillar05BadgeEN = "home.reader.pillar.05.badge.en"
    static let homeReaderPillar06BadgeEN = "home.reader.pillar.06.badge.en"
    static let homeReaderPillar01BadgeINT = "home.reader.pillar.01.badge.int"
    static let homeReaderPillar02BadgeINT = "home.reader.pillar.02.badge.int"
    static let homeReaderPillar03BadgeINT = "home.reader.pillar.03.badge.int"
    static let homeReaderPillar04BadgeINT = "home.reader.pillar.04.badge.int"
    static let homeReaderPillar05BadgeINT = "home.reader.pillar.05.badge.int"
    static let homeReaderPillar06BadgeINT = "home.reader.pillar.06.badge.int"

    static let settingsSectionStaffGuide = "settings.section.staff_guide"
    static let settingsStaffGuideIndexTitle = "settings.staff_guide.index.title"
    static let settingsStaffGuideIndexSubtitle = "settings.staff_guide.index.subtitle"

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
    /// オブジェクトクラス・クイックチップ（`SCPJPTagObjectClassCatalog` の Wiki 表記と対）。
    static let archiveOcSafe = "archive.oc.safe"
    static let archiveOcEuclid = "archive.oc.euclid"
    static let archiveOcKeter = "archive.oc.keter"
    static let archiveOcThaumiel = "archive.oc.thaumiel"
    static let archiveOcApollyon = "archive.oc.apollyon"
    static let archiveOcArchon = "archive.oc.archon"
    static let archiveOcCernunnos = "archive.oc.cernunnos"
    static let archiveOcTiconderoga = "archive.oc.ticonderoga"
    static let archiveOcNeutralized = "archive.oc.neutralized"
    static let archiveOcDecommissioned = "archive.oc.decommissioned"
    static let archiveOcPending = "archive.oc.pending"
    static let archiveOcEsoteric = "archive.oc.esoteric"
    static let archiveFilterNoTagsInSegment = "archive.filter.no_tags_in_segment"
    /// アーカイヴ一覧: 各行にタグチップを常時表示するトグル（フィルタ適用時は自動表示）。
    static let archiveListRowTagsToggleAccessibility = "archive.list.row_tags.accessibility"

    // Phase 16: レーティング・アーカイヴ並べ替え
    static let archiveSortRatingHighToLow = "archive.sort.rating_high_low"
    static let archiveSortScpNumberAsc = "archive.sort.scp_number_asc"
    static let archiveSortToolbarAccessibility = "archive.sort.toolbar_accessibility"
    static let archiveFilterHighRatingChip = "archive.filter.high_rating_chip"
    static let archiveFilterHighRatingAccessibility = "archive.filter.high_rating.accessibility"
    static let archiveRatingMeterUnreadAccessibility = "archive.rating_meter.unread_a11y"
    static let archiveRatingMeterScoreAccessibilityFormat = "archive.rating_meter.score_voice"

    /// 記事ビュー下部: カタログ／タグ由来のメタデータ帯。
    static let articleMetadataTagsSection = "article.metadata.tags.section"

    static let articleRatingUnsetShort = "article.rating.unset_short"
    static let articleRatingScaleMax = "article.rating.scale_max"
    static let articleRatingAccessibility = "article.rating.a11y"
    static let articleAutoArchiveToastFormat = "article.auto_archive.toast_format"

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

    static let articleRatingNavAccessibility = "article.rating.nav_accessibility"
    static let articleReadLaterNavAccessibility = "article.read_later.nav_accessibility"
    static let articleQuickReaderAccessibility = "article.quick_reader.accessibility"
    static let articleQuickReaderLarger = "article.quick_reader.larger"
    static let articleQuickReaderSmaller = "article.quick_reader.smaller"
    static let articleToolbarActionsHub = "article.toolbar.actions_hub"
    static let articleToolbarShare = "article.toolbar.share"
    static let articleOfflineBadge = "article.offline_badge"
    static let articleLoadTimeout = "article.load.timeout"
    static let articleLoadFailed = "article.load.failed"
    static let articleLoadRetry = "article.load.retry"
    static let articleReaderTypographyLoadingTitle = "article.reader_typography.loading_title"
    static let articleReaderTypographyLoadingSubtitle = "article.reader_typography.loading_subtitle"

    /// Step 3: 読了後のカタログ内ナビ。
    static let articlePostReadNextCase = "article.post_read.next_case"
    static let articlePostReadRandomCase = "article.post_read.random_case"
    static let articleDiagnosticMinimalBanner = "article.diagnostic.minimal_banner"

    static let settingsSectionWebViewDebug = "settings.section.webview_debug"
    static let settingsWebViewMinimalToggle = "settings.webview.minimal_toggle"
    static let settingsWebViewMinimalFooter = "settings.webview.minimal_footer"
    static let settingsWebViewProbe = "settings.webview.probe"
    static let settingsWebViewProbeFooter = "settings.webview.probe_footer"

    // Tales-JP（foundation-tales-jp）著者別索引
    static let talesJpAuthorIndexTitle = "tales.jp.author_index.title"
    static let talesJpSegmentDigits = "tales.jp.segment.digits"
    static let talesJpSegmentMisc = "tales.jp.segment.misc"
    static let talesJpAlphabetPickerAccessibility = "tales.jp.alphabet_picker.a11y"
    static let talesJpLoadFailed = "tales.jp.load_failed"
    static let talesJpLoadFailedHint = "tales.jp.load_failed.hint"
    static let talesJpRetry = "tales.jp.retry"
    static let talesJpOpenWikiHubAccessibility = "tales.jp.open_wiki.a11y"
    static let talesJpRefreshAccessibility = "tales.jp.refresh.a11y"
    static let talesJpEmpty = "tales.jp.empty"
    static let talesJpEmptyHint = "tales.jp.empty.hint"
    static let talesJpEmptySegment = "tales.jp.empty_segment"
    static let talesJpNoTalesUnderAuthor = "tales.jp.no_tales_under_author"
    static let talesJpTaleCountFormat = "tales.jp.tale_count_format"
}

// MARK: - Phase 13 リモートデータ（マニフェスト・カタログ）

enum AppRemoteConfig {
    /// キャッシュへ保存する正規形の `schemaVersion`（フラット entries のみ）。
    static let scpArticleFeedSchemaVersion = 1

    /// ネットワーク上で受け入れる記事フィードの `schemaVersion`（1=従来、2=manifest）。
    static let supportedSCPArticleFeedSchemaVersions: Set<Int> = [1, 2]

    /// キャッシュへ保存する正規形の `schemaVersion`。
    static let scpGeneralContentFeedSchemaVersion = 1

    /// Tales/GoI 等で受け入れる `schemaVersion`（1=従来、2=manifest、3=GoI 階層）。
    static let supportedSCPGeneralContentFeedSchemaVersions: Set<Int> = [1, 2, 3]

    /// マニフェスト JSON 等を置くベース URL（末尾スラッシュなし）。
    /// `list/jp/manifest_*.json` はリポジトリ `main` に存在するが、GitHub Pages の現行公開では 404 になるため、
    /// `raw.githubusercontent.com` の `main` を参照する（Pages を `list/` まで配信できたら差し替え可能）。
    static let scpDataHostBaseURLString = "https://raw.githubusercontent.com/kzky-works/data-scp-docs/main"

    /// 支部サイトの言語コード（データホスト上の `list/<code>/` に対応）。現状は日本支部のみ `jp`。
    /// 将来 `ru` / `cn` 等に切り替えたときは `list/ru/` 等の JSON を配信する想定。
    static let scpArticleFeedSiteListCode = "jp"

    /// 3 系統 SCP 報告書フィードおよびマルチフォーム（Tale / GoI）の配信パス接頭辞。
    private static let scpArticleFeedListPathPrefix = "list/\(scpArticleFeedSiteListCode)"

    /// 日本支部系統のマニフェスト（`list/jp/manifest_scp-jp.json`）。
    static let scpJPListJSONPathComponent = "\(scpArticleFeedListPathPrefix)/manifest_scp-jp.json"
    /// 本家メイン和訳系のマニフェスト（`list/jp/manifest_scp-main.json`）。
    static let scpENListJSONPathComponent = "\(scpArticleFeedListPathPrefix)/manifest_scp-main.json"
    /// 国際支部系統のマニフェスト（`list/jp/manifest_scp-int.json`）。
    static let scpINTListJSONPathComponent = "\(scpArticleFeedListPathPrefix)/manifest_scp-int.json"

    static let talesListJSONPathComponent = "\(scpArticleFeedListPathPrefix)/manifest_tales.json"
    static let goisListJSONPathComponent = "\(scpArticleFeedListPathPrefix)/manifest_gois.json"
    static let canonsListJSONPathComponent = "\(scpArticleFeedListPathPrefix)/manifest_canons.json"
    static let jokesListJSONPathComponent = "\(scpArticleFeedListPathPrefix)/manifest_jokes.json"

    /// タグ逆引きマップ（`build_jp_wikidot_tag_article_map.py` → `list/jp/jp_tag.json`）。
    static let jpTagMapJSONPathComponent = "\(scpArticleFeedListPathPrefix)/jp_tag.json"

    /// Step 1: 3 系統 SCP 報告書フィード URL。マルチフォーム（`manifest_*.json`）は `resolvedMultiformArchiveJSONURL` を使う。
    static func resolvedSCPArticleFeedURL(kind: SCPArticleFeedKind) -> URL? {
        let pathSuffix: String? = switch kind {
        case .jp: scpJPListJSONPathComponent
        case .en: scpENListJSONPathComponent
        case .int: scpINTListJSONPathComponent
        case .tales, .gois, .canons, .jokes: nil
        }
        guard let pathComponent = pathSuffix?.trimmingCharacters(in: .whitespacesAndNewlines), !pathComponent.isEmpty else {
            return nil
        }
        return resolvedJSONURLAppendingPathComponent(pathComponent)
    }

    /// Step 4: `manifest_tales.json` / `manifest_gois.json` / `manifest_canons.json` / `manifest_jokes.json`（いずれも `list/<site>/`）。
    static func resolvedMultiformArchiveJSONURL(kind: SCPArticleFeedKind) -> URL? {
        let pathSuffix: String? = switch kind {
        case .tales: talesListJSONPathComponent
        case .gois: goisListJSONPathComponent
        case .canons: canonsListJSONPathComponent
        case .jokes: jokesListJSONPathComponent
        case .jp, .en, .int: nil
        }
        guard let pathComponent = pathSuffix?.trimmingCharacters(in: .whitespacesAndNewlines), !pathComponent.isEmpty else {
            return nil
        }
        return resolvedJSONURLAppendingPathComponent(pathComponent)
    }

    private static func resolvedJSONURLAppendingPathComponent(_ trimmedPath: String) -> URL? {
        let baseTrimmed = scpDataHostBaseURLString.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !baseTrimmed.isEmpty, var components = URLComponents(string: baseTrimmed) else {
            return nil
        }
        guard let scheme = components.scheme?.lowercased(), scheme == "https" || scheme == "http" else {
            return nil
        }
        if components.path.hasSuffix("/") {
            components.path += trimmedPath
        } else if components.path.isEmpty || components.path == "/" {
            components.path = "/" + trimmedPath
        } else {
            components.path += "/" + trimmedPath
        }
        return components.url
    }

    /// `list/jp/jp_tag.json` の完全 URL（タグ・オブジェクトクラス補完用）。
    static func resolvedJPTagMapURL() -> URL? {
        resolvedJSONURLAppendingPathComponent(jpTagMapJSONPathComponent)
    }
}

extension Notification.Name {
    /// マルチフォーム manifest の取得・保存が一通り終わったあとに送出する（一覧の再読込用）。
    static let scpMultiformManifestsDidSync = Notification.Name("jp.scpdocs.scpMultiformManifestsDidSync")
}
