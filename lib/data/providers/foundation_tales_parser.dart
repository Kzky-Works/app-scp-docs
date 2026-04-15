import 'package:html/dom.dart';
import 'package:html/parser.dart' as html_parser;

/// 物語インデックスのセクションキー（ページ内アンカーと一致）。
const Set<String> kFoundationTaleSectionKeys = {
  'A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J', 'K', 'L', 'M',
  'N', 'O', 'P', 'Q', 'R', 'S', 'T', 'U', 'V', 'W', 'X', 'Y', 'Z',
  '0-9',
  'misc',
};

/// UI 表示用ラベル（横スクロールバー）。
const List<String> kFoundationTaleSectionOrder = [
  'A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J', 'K', 'L', 'M',
  'N', 'O', 'P', 'Q', 'R', 'S', 'T', 'U', 'V', 'W', 'X', 'Y', 'Z',
  '0-9',
  'misc',
];

String foundationTaleSectionLabel(String key) {
  if (key == '0-9') return '0–9';
  if (key == 'misc') return 'その他';
  return key;
}

class TaleWorkEntry {
  const TaleWorkEntry({
    required this.title,
    required this.path,
    required this.summary,
  });

  final String title;
  final String path;
  final String summary;
}

class TaleAuthorEntry {
  TaleAuthorEntry({
    required this.name,
    required this.section,
    required this.works,
  });

  final String name;

  /// A–Z, 0-9, misc
  final String section;
  final List<TaleWorkEntry> works;
}

class TaleMiscLink {
  const TaleMiscLink({
    required this.title,
    required this.path,
    required this.description,
  });

  final String title;
  final String path;
  final String description;
}

class FoundationTalesParseResult {
  FoundationTalesParseResult({
    required this.authors,
    required this.miscHubLinks,
  });

  final List<TaleAuthorEntry> authors;
  final List<TaleMiscLink> miscHubLinks;
}

FoundationTalesParseResult parseFoundationTalesPage(String html) {
  final doc = html_parser.parse(html);
  final root = doc.getElementById('page-content');
  if (root == null) {
    return FoundationTalesParseResult(authors: [], miscHubLinks: []);
  }

  final parser = _FoundationTalesWalker();
  parser.walk(root);
  return FoundationTalesParseResult(
    authors: parser.authors,
    miscHubLinks: parser.miscHubLinks,
  );
}

class _FoundationTalesWalker {
  final List<TaleAuthorEntry> authors = [];
  final List<TaleMiscLink> miscHubLinks = [];

  String? currentSection;
  TaleAuthorEntry? currentAuthor;

  void walk(Element root) {
    _visit(root);
  }

  void _visit(Element e) {
    if (e.localName == 'a') {
      final name = e.attributes['name'];
      if (name != null && kFoundationTaleSectionKeys.contains(name)) {
        currentSection = name;
      }
    }

    if (e.localName == 'table') {
      if (e.classes.contains('wiki-content-table')) {
        _parseWorksTable(e);
        return;
      }
      if (_isAuthorHeaderTable(e)) {
        _startAuthor(e);
        return;
      }
    }

    if (e.localName == 'div' &&
        e.classes.contains('content-type-description') &&
        currentSection == 'misc') {
      _parseMiscHub(e);
      return;
    }

    for (final c in e.children) {
      _visit(c);
    }
  }

  bool _isAuthorHeaderTable(Element table) {
    if (table.classes.contains('wiki-content-table')) return false;
    final th = table.querySelector('th');
    if (th == null) return false;
    return th.querySelector('.printuser') != null ||
        th.querySelector('span.printuser') != null;
  }

  String? _extractAuthorName(Element table) {
    final th = table.querySelector('th');
    if (th == null) return null;
    final anchors = th.querySelectorAll('a');
    for (final a in anchors.reversed) {
      final t = a.text.trim();
      if (t.isNotEmpty) return t;
    }
    final plain = th.text.trim();
    return plain.isEmpty ? null : plain;
  }

  void _startAuthor(Element table) {
    final name = _extractAuthorName(table);
    if (name == null) return;
    final section = currentSection ?? 'misc';
    currentAuthor = TaleAuthorEntry(
      name: name,
      section: section,
      works: [],
    );
    authors.add(currentAuthor!);
  }

  void _parseWorksTable(Element table) {
    final author = currentAuthor;
    if (author == null) return;

    for (final row in table.querySelectorAll('tr')) {
      final tds = row.children
          .whereType<Element>()
          .where((el) => el.localName == 'td')
          .toList();
      if (tds.length < 2) continue;
      final link = tds[0].querySelector('a');
      if (link == null) continue;
      final href = link.attributes['href'];
      if (href == null || href.isEmpty) continue;
      final title = link.text.trim();
      if (title.isEmpty) continue;
      final summary = tds[1].text.trim();
      author.works.add(TaleWorkEntry(
        title: title,
        path: href,
        summary: summary,
      ));
    }
  }

  void _parseMiscHub(Element div) {
    for (final li in div.querySelectorAll('ul li')) {
      final a = li.querySelector('a');
      if (a == null) continue;
      final href = a.attributes['href'];
      if (href == null || href.isEmpty) continue;
      final title = a.text.trim();
      if (title.isEmpty) continue;
      var desc = li.text.trim();
      if (desc.startsWith(title)) {
        desc = desc.substring(title.length).trim();
        if (desc.startsWith('-')) desc = desc.substring(1).trim();
      }
      miscHubLinks.add(TaleMiscLink(
        title: title,
        path: href,
        description: desc,
      ));
    }
  }
}
