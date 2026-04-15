import 'package:html/parser.dart' as html_parser;

/// 連作ハブ下層ページに掲載された作品リンク（list-pages 等）。
class HubArticleLink {
  const HubArticleLink({
    required this.title,
    required this.path,
  });

  final String title;
  final String path;
}

/// ハブページ HTML から `.list-pages-box` 内の記事リンクを抽出する。
List<HubArticleLink> parseHubArticleListPage(String html) {
  final doc = html_parser.parse(html);
  final root = doc.getElementById('page-content');
  if (root == null) return [];

  final byPath = <String, HubArticleLink>{};
  for (final box in root.querySelectorAll('div.list-pages-box')) {
    for (final li in box.querySelectorAll('li')) {
      final a = li.querySelector('a[href^="/"]');
      if (a == null) continue;
      var path = (a.attributes['href'] ?? '').trim();
      if (path.isEmpty) continue;
      path = path.split('#').first;
      if (_skipPath(path)) continue;
      final title = a.text.trim();
      if (title.isEmpty) continue;
      byPath[path] = HubArticleLink(title: title, path: path);
    }
  }
  return byPath.values.toList();
}

bool _skipPath(String path) {
  if (path.startsWith('/system:')) return true;
  if (path.startsWith('/admin:')) return true;
  return false;
}
