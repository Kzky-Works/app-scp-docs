import Foundation

struct ScpJpSeriesItem: Identifiable, Hashable {
    let id = UUID()
    let label: String
    let rangeDescription: String
    let url: URL
}

enum ScpJpSeriesCatalog {
    static let items: [ScpJpSeriesItem] = [
        .init(
            label: "SCP-JP シリーズ I",
            rangeDescription: "001–999",
            url: URL(string: "http://scp-jp.wikidot.com/scp-series-jp")!
        ),
        .init(
            label: "SCP-JP シリーズ II",
            rangeDescription: "1000–1999",
            url: URL(string: "http://scp-jp.wikidot.com/scp-series-jp-2")!
        ),
        .init(
            label: "SCP-JP シリーズ III",
            rangeDescription: "2000–2999",
            url: URL(string: "http://scp-jp.wikidot.com/scp-series-jp-3")!
        ),
        .init(
            label: "SCP-JP シリーズ IV",
            rangeDescription: "3000–3999",
            url: URL(string: "http://scp-jp.wikidot.com/scp-series-jp-4")!
        ),
        .init(
            label: "SCP-JP シリーズ V",
            rangeDescription: "4000–4999",
            url: URL(string: "http://scp-jp.wikidot.com/scp-series-jp-5")!
        ),
        .init(
            label: "SCP-JP シリーズ VI",
            rangeDescription: "5000–5999（サイト共通一覧）",
            url: URL(string: "http://scp-jp.wikidot.com/scp-series-6")!
        ),
        .init(
            label: "SCP-JP シリーズ VII",
            rangeDescription: "6000–6999（サイト共通一覧）",
            url: URL(string: "http://scp-jp.wikidot.com/scp-series-7")!
        ),
    ]
}
