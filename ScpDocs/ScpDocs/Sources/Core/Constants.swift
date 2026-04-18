import Foundation

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

    static let settingsTitle = "settings.title"
    static let settingsSectionBranch = "settings.section.branch"
    static let settingsBranchPicker = "settings.branch_picker"
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
    static let articleToolbarBookmark = "article.toolbar.bookmark"
    static let articleOfflineBadge = "article.offline_badge"
}
