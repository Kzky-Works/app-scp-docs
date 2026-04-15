import 'package:flutter/material.dart';

import '../../core/theme/scp_reader_theme.dart';
import '../../data/providers/series_hub_parser.dart';
import '../../data/providers/wikidot_fetcher.dart';
import '../widgets/dock_layout.dart';
import '../widgets/stark_card.dart';
import 'series_hub_detail_screen.dart';
import 'wiki_webview_screen.dart';

enum SeriesHubSortMode {
  creation,
  gojuon,
}

/// 連作ハブ-JP を解析して一覧表示。並べ替えは右下 FAB。
class SeriesHubScreen extends StatefulWidget {
  const SeriesHubScreen({
    super.key,
    required this.hubUrl,
    this.title = '連作-JP',
  });

  final String hubUrl;
  final String title;

  @override
  State<SeriesHubScreen> createState() => _SeriesHubScreenState();
}

class _SeriesHubScreenState extends State<SeriesHubScreen> {
  late Future<SeriesHubParseResult> _future;
  SeriesHubSortMode _sortMode = SeriesHubSortMode.creation;

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  Future<SeriesHubParseResult> _load() async {
    final html = await fetchWikidotHtml(widget.hubUrl);
    return parseSeriesHubPage(html);
  }

  List<SeriesHubEntry> _orderedEntries(SeriesHubParseResult data) {
    final order =
        _sortMode == SeriesHubSortMode.creation ? data.creationOrder : data.gojuonOrder;
    if (order.isEmpty) {
      return data.entriesByAnchor.values.toList();
    }
    final out = <SeriesHubEntry>[];
    final seen = <String>{};
    for (final id in order) {
      final e = data.entriesByAnchor[id];
      if (e != null) {
        out.add(e);
        seen.add(e.anchorId);
      }
    }
    for (final e in data.entriesByAnchor.values) {
      if (!seen.contains(e.anchorId)) out.add(e);
    }
    return out;
  }

  Future<void> _chooseSortMode() async {
    final mode = await showModalBottomSheet<SeriesHubSortMode>(
      context: context,
      backgroundColor: const Color(0xFF121212),
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text('作成順表示'),
              trailing: _sortMode == SeriesHubSortMode.creation
                  ? const Icon(Icons.check, color: ScpReaderTheme.accent)
                  : null,
              onTap: () => Navigator.pop(ctx, SeriesHubSortMode.creation),
            ),
            ListTile(
              title: const Text('五十音順表示'),
              trailing: _sortMode == SeriesHubSortMode.gojuon
                  ? const Icon(Icons.check, color: ScpReaderTheme.accent)
                  : null,
              onTap: () => Navigator.pop(ctx, SeriesHubSortMode.gojuon),
            ),
          ],
        ),
      ),
    );
    if (mode != null && mounted) {
      setState(() => _sortMode = mode);
    }
  }

  void _openDetail(BuildContext context, SeriesHubEntry e) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => SeriesHubDetailScreen(
          hubTitle: e.title,
          hubPath: e.hubPath,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final dock = DockLayout.bottomInsetOf(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: [
          IconButton(
            icon: const Icon(Icons.public),
            tooltip: 'サイトで開く',
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => WikiWebViewScreen(
                    initialUrl: widget.hubUrl,
                    pageTitle: widget.title,
                  ),
                ),
              );
            },
          ),
        ],
      ),
      floatingActionButton: Padding(
        padding: EdgeInsets.only(bottom: dock),
        child: FloatingActionButton(
          onPressed: _chooseSortMode,
          tooltip: '並べ替え',
          backgroundColor: const Color(0xFF1A1A1A),
          foregroundColor: ScpReaderTheme.accent,
          child: const Icon(Icons.sort),
        ),
      ),
      body: FutureBuilder<SeriesHubParseResult>(
        future: _future,
        builder: (context, snap) {
          if (snap.connectionState != ConnectionState.done) {
            return const Center(
              child: CircularProgressIndicator(color: ScpReaderTheme.accent),
            );
          }
          if (snap.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '連作一覧の取得に失敗しました。\n${snap.error}',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 16),
                    FilledButton(
                      onPressed: () => setState(() => _future = _load()),
                      child: const Text('再試行'),
                    ),
                  ],
                ),
              ),
            );
          }
          final data = snap.data!;
          final items = _orderedEntries(data);
          if (items.isEmpty) {
            return Center(
              child: Text(
                '連作エントリを解析できませんでした。',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: ScpReaderTheme.accent,
                    ),
              ),
            );
          }
          return ListView.separated(
            padding: EdgeInsets.fromLTRB(12, 12, 12, 88 + dock),
            itemCount: items.length,
            separatorBuilder: (context, _) => const SizedBox(height: 6),
            itemBuilder: (context, index) {
              final e = items[index];
              return StarkCard(
                onTap: () => _openDetail(context, e),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            e.title,
                            style: Theme.of(context).textTheme.titleSmall,
                          ),
                          if (e.description.isNotEmpty) ...[
                            const SizedBox(height: 6),
                            Text(
                              e.description,
                              maxLines: 4,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(
                                color: ScpReaderTheme.accent,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    Icon(
                      Icons.chevron_right,
                      color: ScpReaderTheme.accent.withValues(alpha: 0.7),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
