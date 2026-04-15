/// サブメニュー 1 行（シリーズやハブへのリンク）。
///
/// カタログ全体は [kAllCategories] / [kCategoriesById] で拡張する。
class SubMenuLink {
  const SubMenuLink({
    required this.label,
    required this.url,
  });

  final String label;
  final String url;
}

/// トップの 7 カテゴリ。
class CategoryDefinition {
  const CategoryDefinition({
    required this.id,
    required this.titleJa,
    required this.titleEn,
    required this.entries,
    this.isLibraryOnly = false,
  });

  final String id;
  final String titleJa;
  final String titleEn;

  /// 空のときは [isLibraryOnly] 用（お気に入り一覧のみ表示）。
  final List<SubMenuLink> entries;

  /// true の場合、詳細画面では [entries] ではなく保存済み URL を表示。
  final bool isLibraryOnly;
}

/// 財団内物語-JP インデックス（著者別一覧の取得元）。
const String kFoundationTalesJpHubUrl =
    'http://scp-jp.wikidot.com/foundation-tales-jp';

/// 連作ハブ-JP（連作一覧・目次の取得元）。
const String kSeriesHubJpUrl = 'http://scp-jp.wikidot.com/series-hub-jp';

/// モック: Wikidot の実 URL。404 のものは後から差し替え可能。
final List<CategoryDefinition> kAllCategories = [
  CategoryDefinition(
    id: 'scp_reports',
    titleJa: '【SCPデータベース】',
    titleEn: 'SCP Database',
    /// シリーズ一覧はサイトのナビから [discoverScpJpSeriesListings] で動的取得。
    entries: const [],
  ),
  CategoryDefinition(
    id: 'scp_library',
    titleJa: '【SCPライブラリ】',
    titleEn: 'SCP Library',
    entries: const [
      SubMenuLink(
        label: 'Tales-JP',
        url: kFoundationTalesJpHubUrl,
      ),
      SubMenuLink(
        label: 'カノン-JP',
        url: 'http://scp-jp.wikidot.com/canon-hub-jp',
      ),
      SubMenuLink(
        label: '連作-JP',
        url: kSeriesHubJpUrl,
      ),
      SubMenuLink(
        label: 'GoI フォーマット',
        url: 'http://scp-jp.wikidot.com/goi-format-hub',
      ),
    ],
  ),
  CategoryDefinition(
    id: 'international',
    titleJa: '【世界各国の報告書】',
    titleEn: 'International Branches',
    entries: const [
      SubMenuLink(
        label: '国際支部ハブ',
        url: 'http://scp-jp.wikidot.com/scp-international',
      ),
      SubMenuLink(
        label: '英語本部シリーズ一覧',
        url: 'http://scp-jp.wikidot.com/scp-series',
      ),
      SubMenuLink(
        label: '中国語支部シリーズ',
        url: 'http://scp-jp.wikidot.com/scp-series-cn',
      ),
      SubMenuLink(
        label: '韓国語支部シリーズ',
        url: 'http://scp-jp.wikidot.com/scp-series-ko',
      ),
    ],
  ),
  CategoryDefinition(
    id: 'goi',
    titleJa: '【要注意団体 & 登場人物】',
    titleEn: 'GoI / Personnel',
    entries: const [
      SubMenuLink(
        label: '要注意団体一覧',
        url: 'http://scp-jp.wikidot.com/groups-of-interest-jp',
      ),
      SubMenuLink(
        label: 'キャラクター・人物ハブ',
        url: 'http://scp-jp.wikidot.com/personnel-hub-jp',
      ),
    ],
  ),
  CategoryDefinition(
    id: 'guide',
    titleJa: '【新人職員ガイド & 規約】',
    titleEn: 'Guide & Rules',
    entries: const [
      SubMenuLink(
        label: 'ガイドハブ',
        url: 'http://scp-jp.wikidot.com/guide-hub-jp',
      ),
      SubMenuLink(
        label: 'サイト規約',
        url: 'http://scp-jp.wikidot.com/site-rules-jp',
      ),
      SubMenuLink(
        label: '批評・投稿ガイド',
        url: 'http://scp-jp.wikidot.com/how-to-write',
      ),
    ],
  ),
  CategoryDefinition(
    id: 'events',
    titleJa: '【イベント & コンテスト】',
    titleEn: 'Events & Contests',
    entries: const [
      SubMenuLink(
        label: 'コンテストアーカイブ',
        url: 'http://scp-jp.wikidot.com/contest-archive',
      ),
      SubMenuLink(
        label: 'コンテストハブ',
        url: 'http://scp-jp.wikidot.com/contest-hub-jp',
      ),
    ],
  ),
  CategoryDefinition(
    id: 'library',
    titleJa: '【ユーザーライブラリ】',
    titleEn: 'My Library',
    entries: const [],
    isLibraryOnly: true,
  ),
];

/// ID → カテゴリ（動的追加時は [kAllCategories] を更新してから再生成）。
final Map<String, CategoryDefinition> kCategoriesById = {
  for (final c in kAllCategories) c.id: c,
};
