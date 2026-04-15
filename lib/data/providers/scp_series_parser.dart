import 'package:html/parser.dart' as html_parser;

/// シリーズ一覧ページの 1 行。
class ScpSeriesEntry {
  const ScpSeriesEntry({
    required this.scpIdLabel,
    required this.title,
    required this.path,
  });

  /// 例: SCP-001-JP
  final String scpIdLabel;

  /// ダッシュ以降の表題（HTML から抽出したプレーンテキスト）。
  final String title;

  /// 例: /scp-001-jp
  final String path;
}

final _scpHref = RegExp(r'^/scp-(\d+)-jp$');

/// [html] は `foundation-tales-jp` ではなく各 `scp-series-jp` 系ページの HTML。
List<ScpSeriesEntry> parseScpSeriesListPage(String html) {
  final doc = html_parser.parse(html);
  final root = doc.getElementById('page-content');
  if (root == null) return [];

  final out = <ScpSeriesEntry>[];
  for (final li in root.querySelectorAll('li')) {
    final a = li.querySelector('a[href^="/scp-"]');
    if (a == null) continue;
    final href = a.attributes['href']?.trim() ?? '';
    if (!_scpHref.hasMatch(href)) continue;

    final idLabel = a.text.trim();
    if (idLabel.isEmpty) continue;

    var rest = li.text.trim();
    if (rest.startsWith(idLabel)) {
      rest = rest.substring(idLabel.length).trim();
      if (rest.startsWith('-')) {
        rest = rest.substring(1).trim();
      }
    }

    out.add(ScpSeriesEntry(
      scpIdLabel: idLabel,
      title: rest,
      path: href,
    ));
  }
  return out;
}
