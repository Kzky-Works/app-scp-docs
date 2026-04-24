import Foundation

/// SCP-JP 報告書の Wikidot シリーズ（各 1000 件ブロック）。
enum SCPJPSeries: Int, CaseIterable, Identifiable, Hashable, Sendable {
    /// JP-I（001-JP 〜 999-JP）
    case series1 = 0
    /// JP-II（1000-JP 〜 1999-JP）
    case series2 = 1
    /// JP-III（2000-JP 〜 2999-JP）
    case series3 = 2
    /// JP-IV（3000-JP 〜 3999-JP）
    case series4 = 3
    /// JP-V（4000-JP 〜 4999-JP）
    case series5 = 4

    var id: Int { rawValue }

    /// 報告書番号の範囲（両端含む）。
    var scpNumberRange: ClosedRange<Int> {
        switch self {
        case .series1: 1 ... 999
        case .series2: 1000 ... 1999
        case .series3: 2000 ... 2999
        case .series4: 3000 ... 3999
        case .series5: 4000 ... 4999
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
        }
    }

    /// 英語アーカイヴの 1000 件ブロックピッカー用（001–4999）。
    var englishThousandBlockLocalizationKey: String {
        switch self {
        case .series1: LocalizationKey.archiveEnSeriesBlock1
        case .series2: LocalizationKey.archiveEnSeriesBlock2
        case .series3: LocalizationKey.archiveEnSeriesBlock3
        case .series4: LocalizationKey.archiveEnSeriesBlock4
        case .series5: LocalizationKey.archiveEnSeriesBlock5
        }
    }

    /// シリーズに対応する Wikidot 一覧ページ（参照用・外部ブラウザ用）。
    var wikidotSeriesIndexURL: URL {
        let path: String
        switch self {
        case .series1: path = "scp-series-jp"
        case .series2: path = "scp-series-jp-2"
        case .series3: path = "scp-series-jp-3"
        case .series4: path = "scp-series-jp-4"
        case .series5: path = "scp-series-jp-5"
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

