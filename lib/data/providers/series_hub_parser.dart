import 'package:html/dom.dart';
import 'package:html/parser.dart' as html_parser;

/// 連作ハブ-JP の 1 連作。
class SeriesHubEntry {
  SeriesHubEntry({
    required this.anchorId,
    required this.title,
    required this.hubPath,
    required this.description,
  });

  final String anchorId;
  final String title;

  /// ハブページへのパス（例: `/bounenkai`）
  final String hubPath;

  /// 概要（プレーンテキスト・要約）
  final String description;
}

class SeriesHubParseResult {
  SeriesHubParseResult({
    required this.entriesByAnchor,
    required this.creationOrder,
    required this.gojuonOrder,
  });

  final Map<String, SeriesHubEntry> entriesByAnchor;
  final List<String> creationOrder;
  final List<String> gojuonOrder;
}

/// [html] は `series-hub-jp` の HTML。
SeriesHubParseResult parseSeriesHubPage(String html) {
  final doc = html_parser.parse(html);
  final root = doc.getElementById('page-content');
  if (root == null) {
    return SeriesHubParseResult(
      entriesByAnchor: {},
      creationOrder: [],
      gojuonOrder: [],
    );
  }

  final entries = <String, SeriesHubEntry>{};
  for (final panel
      in root.querySelectorAll('div.content-panel.centered.standalone.series')) {
    final parsed = _parseSeriesPanel(panel);
    if (parsed != null) {
      entries[parsed.anchorId] = parsed;
    }
  }

  final tocRoot = root.querySelector('div.TocTab');
  final creation = <String>[];
  final gojuon = <String>[];
  if (tocRoot != null) {
    final yuiPanels = tocRoot.querySelectorAll('div.yui-content > div');
    if (yuiPanels.length > 1) {
      creation.addAll(_anchorOrderFromTocPanel(yuiPanels[1]));
    }
    if (yuiPanels.length > 2) {
      gojuon.addAll(_anchorOrderFromTocPanel(yuiPanels[2]));
    }
  }

  return SeriesHubParseResult(
    entriesByAnchor: entries,
    creationOrder: creation,
    gojuonOrder: gojuon,
  );
}

SeriesHubEntry? _parseSeriesPanel(Element panel) {
  final titleBlock = panel.querySelector('div.series-title');
  if (titleBlock == null) return null;

  Element? hubLinkEl;
  for (final a in titleBlock.querySelectorAll('a[href^="/"]')) {
    final href = a.attributes['href'] ?? '';
    if (href.isEmpty || href.startsWith('//')) continue;
    hubLinkEl = a;
    break;
  }
  if (hubLinkEl == null) return null;

  final hubPath = hubLinkEl.attributes['href']!.split('#').first;
  final title = hubLinkEl.text.trim();
  if (title.isEmpty) return null;

  String anchorId = _slugFromPath(hubPath);
  final nameA = titleBlock.querySelector('a[name]');
  if (nameA != null) {
    final n = nameA.attributes['name']?.trim();
    if (n != null && n.isNotEmpty) anchorId = n;
  }

  final descEl = panel.querySelector('div.series-description');
  final description = descEl?.text.trim() ?? '';

  return SeriesHubEntry(
    anchorId: anchorId,
    title: title,
    hubPath: hubPath,
    description: description,
  );
}

String _slugFromPath(String path) {
  if (path.startsWith('/')) {
    return path.substring(1).split('/').first;
  }
  return path;
}

List<String> _anchorOrderFromTocPanel(Element panel) {
  final out = <String>[];
  final seen = <String>{};
  for (final a in panel.querySelectorAll('a[href^="#"]')) {
    final h = a.attributes['href'] ?? '';
    if (h.length < 2) continue;
    final id = h.substring(1);
    if (id.isEmpty || seen.contains(id)) continue;
    seen.add(id);
    out.add(id);
  }
  return out;
}
