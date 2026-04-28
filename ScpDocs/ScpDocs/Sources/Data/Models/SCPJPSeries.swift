import Foundation

/// SCP-JP 報告書の Wikidot シリーズ（Ⅰのみ 999 件、Ⅱ以降は各 1000 件のブロック）。
enum SCPJPSeries: Int, CaseIterable, Identifiable, Hashable, Sendable {
    /// JP-I（001-JP 〜 999-JP）。シリーズⅠのみ 3 桁レンジ。
    case series1 = 0
    /// JP-II（1000-JP 〜 1999-JP）
    case series2 = 1
    /// JP-III（2000-JP 〜 2999-JP）
    case series3 = 2
    /// JP-IV（3000-JP 〜 3999-JP）
    case series4 = 3
    /// JP-V（4000-JP 〜 4999-JP）
    case series5 = 4
    /// JP-VI（5000-JP 〜 5999-JP）— 一覧ページ未整備の場合はインデックスでは `scp-series-jp-5` 等へのフォールバックがあり得る。
    case series6 = 5
    /// JP-VII（6000-JP 〜 6999-JP）
    case series7 = 6
    /// JP-VIII（7000-JP 〜 7999-JP）
    case series8 = 7
    /// JP-IX（8000-JP 〜 8999-JP）
    case series9 = 8
    /// JP-X（9000-JP 〜 9999-JP）
    case series10 = 9

    var id: Int { rawValue }

    /// 一覧・インデックスで扱う主番号の上限（現メインリストの末尾ブロック）。
    static let canonicalTrifoldReportNumberUpperBound = 9999

    /// 報告書番号の範囲（両端含む）。
    var scpNumberRange: ClosedRange<Int> {
        switch self {
        case .series1: 1 ... 999
        case .series2: 1000 ... 1999
        case .series3: 2000 ... 2999
        case .series4: 3000 ... 3999
        case .series5: 4000 ... 4999
        case .series6: 5000 ... 5999
        case .series7: 6000 ... 6999
        case .series8: 7000 ... 7999
        case .series9: 8000 ... 8999
        case .series10: 9000 ... 9999
        }
    }

    /// 100 件セグメントの先頭番号（ピッカー用）。
    var segmentStarts: [Int] {
        let lo = scpNumberRange.lowerBound
        let hi = scpNumberRange.upperBound
        var starts: [Int] = []
        var cursor = lo
        while cursor <= hi {
            starts.append(cursor)
            cursor += 100
        }
        return starts
    }

    /// `segmentStart` で始まるブロックに含まれる報告書番号。
    func numbersInSegment(segmentStart: Int) -> [Int] {
        let segmentLo = max(scpNumberRange.lowerBound, segmentStart)
        let segmentHi = min(scpNumberRange.upperBound, segmentStart + 99)
        guard segmentLo <= segmentHi else { return [] }
        return Array(segmentLo ... segmentHi)
    }

    func articleURL(scpNumber: Int) -> URL {
        let slug: String
        if scpNumber < 1000 {
            slug = String(format: "scp-%03d-jp", scpNumber)
        } else {
            slug = "scp-\(scpNumber)-jp"
        }
        return URL(string: "https://scp-jp.wikidot.com/\(slug)")!
    }

    var titleLocalizationKey: String {
        switch self {
        case .series1: LocalizationKey.categorySeriesJP1
        case .series2: LocalizationKey.categorySeriesJP2
        case .series3: LocalizationKey.categorySeriesJP3
        case .series4: LocalizationKey.categorySeriesJP4
        case .series5: LocalizationKey.categorySeriesJP5
        case .series6: LocalizationKey.categorySeriesJP6
        case .series7: LocalizationKey.categorySeriesJP7
        case .series8: LocalizationKey.categorySeriesJP8
        case .series9: LocalizationKey.categorySeriesJP9
        case .series10: LocalizationKey.categorySeriesJP10
        }
    }

    /// 英語アーカイヴのシリーズブロックピッカー用（Ⅰのみ 999 番まで、その他は 1000 件ブロック）。
    var englishThousandBlockLocalizationKey: String {
        switch self {
        case .series1: LocalizationKey.archiveEnSeriesBlock1
        case .series2: LocalizationKey.archiveEnSeriesBlock2
        case .series3: LocalizationKey.archiveEnSeriesBlock3
        case .series4: LocalizationKey.archiveEnSeriesBlock4
        case .series5: LocalizationKey.archiveEnSeriesBlock5
        case .series6: LocalizationKey.archiveEnSeriesBlock6
        case .series7: LocalizationKey.archiveEnSeriesBlock7
        case .series8: LocalizationKey.archiveEnSeriesBlock8
        case .series9: LocalizationKey.archiveEnSeriesBlock9
        case .series10: LocalizationKey.archiveEnSeriesBlock10
        }
    }

    /// シリーズに対応する Wikidot 一覧ページ（参照用・外部ブラウザ用）。JP-VI 以降の専用ハブが未整備の場合は末尾ブロック一覧へフォールバックする。
    var wikidotSeriesIndexURL: URL {
        let path: String
        switch self {
        case .series1: path = "scp-series-jp"
        case .series2: path = "scp-series-jp-2"
        case .series3: path = "scp-series-jp-3"
        case .series4: path = "scp-series-jp-4"
        case .series5, .series6, .series7, .series8, .series9, .series10:
            path = "scp-series-jp-5"
        }
        return URL(string: "https://scp-jp.wikidot.com/\(path)")!
    }

    /// 本家メインリストの日本語訳（`https://scp-jp.wikidot.com/scp-series` 系）の記事 URL。
    func englishMainlistTranslationArticleURL(scpNumber: Int) -> URL {
        let slug: String
        if scpNumber < 1000 {
            slug = String(format: "scp-%03d", scpNumber)
        } else {
            slug = "scp-\(scpNumber)"
        }
        return URL(string: "https://scp-jp.wikidot.com/\(slug)")!
    }

    /// 英語メイン Wiki のシリーズ一覧ページ（`Branch.englishMain.homeCategories` と対応）。
    var englishWikidotSeriesIndexURL: URL {
        let path: String
        switch self {
        case .series1: path = "scp-series"
        case .series2: path = "scp-series-2"
        case .series3: path = "scp-series-3"
        case .series4: path = "scp-series-4"
        case .series5: path = "scp-series-5"
        case .series6: path = "scp-series-6"
        case .series7: path = "scp-series-7"
        case .series8: path = "scp-series-8"
        case .series9: path = "scp-series-9"
        case .series10: path = "scp-series-10"
        }
        return URL(string: "https://scp-wiki.wikidot.com/\(path)")!
    }

    /// 本家メインリスト和訳の Wikidot 一覧（`scp-series` / `scp-series-2` …）。
    var wikidotEnglishMainlistTranslationSeriesIndexURL: URL {
        let path: String
        switch self {
        case .series1: path = "scp-series"
        case .series2: path = "scp-series-2"
        case .series3: path = "scp-series-3"
        case .series4: path = "scp-series-4"
        case .series5: path = "scp-series-5"
        case .series6: path = "scp-series-6"
        case .series7: path = "scp-series-7"
        case .series8: path = "scp-series-8"
        case .series9: path = "scp-series-9"
        case .series10: path = "scp-series-10"
        }
        return URL(string: "https://scp-jp.wikidot.com/\(path)")!
    }
}

/// 日本支部アーカイヴの 1 行（`LibraryStaticData` が生成）。
struct JapanSCPArchiveEntry: Identifiable, Hashable, Sendable {
    let id: String
    let scpNumber: Int
    let url: URL
    /// HTML 一覧から注入されたタイトル。`nil` の場合は UI でフォールバック表示。
    let articleTitle: String?
    /// Phase 14: Wikidot カタログ同期由来。未同期時は `nil` / 空。
    let objectClass: String?
    /// Phase 14: リモート JSON のタグ一覧。
    let tags: [String]

    init(
        id: String,
        scpNumber: Int,
        url: URL,
        articleTitle: String?,
        objectClass: String? = nil,
        tags: [String] = []
    ) {
        self.id = id
        self.scpNumber = scpNumber
        self.url = url
        self.articleTitle = articleTitle
        self.objectClass = objectClass
        self.tags = tags
    }
}
