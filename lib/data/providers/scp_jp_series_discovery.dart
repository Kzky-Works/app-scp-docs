import 'package:html/parser.dart' as html_parser;

import '../../core/constants/wikidot_base.dart';
import 'wikidot_fetcher.dart';

/// 表示用ローマ数字（Unicode）。10 まで対応。
const List<String> kScpJpRomanNumerals = [
  'Ⅰ', 'Ⅱ', 'Ⅲ', 'Ⅳ', 'Ⅴ', 'Ⅵ', 'Ⅶ', 'Ⅷ', 'Ⅸ', 'Ⅹ',
];

/// サイト側のナビに掲載されている JP シリーズ一覧ページ。
class ScpJpSeriesListing {
  ScpJpSeriesListing({
    required this.seriesIndex1Based,
    required this.listPagePath,
    required this.listPageUrl,
  });

  /// 1 始まり（Ⅰ = 1）。
  final int seriesIndex1Based;

  /// 例: `/scp-series-jp` または `/scp-series-jp-5`
  final String listPagePath;

  final String listPageUrl;
}

/// `scp-series-jp` ページの HTML から `/scp-series-jp` 系リンクを集め、存在するシリーズだけ返す。
List<ScpJpSeriesListing> parseScpJpSeriesNavFromHtml(String html) {
  final doc = html_parser.parse(html);
  final byPath = <String, int>{};

  for (final a in doc.querySelectorAll('a[href]')) {
    var href = (a.attributes['href'] ?? '').trim();
    if (href.isEmpty) continue;
    if (href.startsWith('//') || href.startsWith('http')) continue;
    if (href.contains('#')) {
      href = href.split('#').first;
    }
    final idx = _seriesIndexFromListPath(href);
    if (idx == null) continue;
    byPath[href] = idx;
  }

  final listings = byPath.entries
      .map(
        (e) => ScpJpSeriesListing(
          seriesIndex1Based: e.value,
          listPagePath: e.key,
          listPageUrl: wikidotAbsoluteUrl(e.key),
        ),
      )
      .toList()
    ..sort((a, b) => a.seriesIndex1Based.compareTo(b.seriesIndex1Based));

  return listings;
}

int? _seriesIndexFromListPath(String path) {
  if (path == '/scp-series-jp') return 1;
  final m = RegExp(r'^/scp-series-jp-([0-9]+)$').firstMatch(path);
  if (m != null) return int.tryParse(m.group(1)!);
  return null;
}

Future<List<ScpJpSeriesListing>> discoverScpJpSeriesListings() async {
  final html =
      await fetchWikidotHtml('$kWikidotJpBase/scp-series-jp');
  return parseScpJpSeriesNavFromHtml(html);
}

String scpJpSeriesDisplayTitle(int seriesIndex1Based) {
  final romans = kScpJpRomanNumerals;
  final i = seriesIndex1Based - 1;
  final roman =
      i >= 0 && i < romans.length ? romans[i] : '$seriesIndex1Based';
  return 'シリーズJP - $roman';
}

/// 例: （001-JP 〜 999-JP）、（4000-JP 〜 4999-JP）
String scpJpSeriesRangeSubtitle(int seriesIndex1Based) {
  if (seriesIndex1Based == 1) {
    return '（001-JP 〜 999-JP）';
  }
  final low = (seriesIndex1Based - 1) * 1000;
  final high = seriesIndex1Based * 1000 - 1;
  return '（$low-JP 〜 $high-JP）';
}
