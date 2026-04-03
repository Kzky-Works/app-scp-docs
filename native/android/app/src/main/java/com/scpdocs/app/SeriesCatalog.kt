package com.scpdocs.app

data class ScpJpSeriesItem(
    val label: String,
    val rangeDescription: String,
    val url: String,
)

object ScpJpSeriesCatalog {
    val items: List<ScpJpSeriesItem> = listOf(
        ScpJpSeriesItem(
            label = "SCP-JP シリーズ I",
            rangeDescription = "001–999",
            url = "http://scp-jp.wikidot.com/scp-series-jp",
        ),
        ScpJpSeriesItem(
            label = "SCP-JP シリーズ II",
            rangeDescription = "1000–1999",
            url = "http://scp-jp.wikidot.com/scp-series-jp-2",
        ),
        ScpJpSeriesItem(
            label = "SCP-JP シリーズ III",
            rangeDescription = "2000–2999",
            url = "http://scp-jp.wikidot.com/scp-series-jp-3",
        ),
        ScpJpSeriesItem(
            label = "SCP-JP シリーズ IV",
            rangeDescription = "3000–3999",
            url = "http://scp-jp.wikidot.com/scp-series-jp-4",
        ),
        ScpJpSeriesItem(
            label = "SCP-JP シリーズ V",
            rangeDescription = "4000–4999",
            url = "http://scp-jp.wikidot.com/scp-series-jp-5",
        ),
        ScpJpSeriesItem(
            label = "SCP-JP シリーズ VI",
            rangeDescription = "5000–5999（サイト共通一覧）",
            url = "http://scp-jp.wikidot.com/scp-series-6",
        ),
        ScpJpSeriesItem(
            label = "SCP-JP シリーズ VII",
            rangeDescription = "6000–6999（サイト共通一覧）",
            url = "http://scp-jp.wikidot.com/scp-series-7",
        ),
    )
}
