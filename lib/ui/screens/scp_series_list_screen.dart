import 'package:flutter/material.dart';

import '../../core/constants/wikidot_base.dart';
import '../../core/theme/scp_reader_theme.dart';
import '../../data/providers/scp_series_parser.dart';
import '../../data/providers/wikidot_fetcher.dart';
import '../widgets/dock_layout.dart';
import '../widgets/stark_card.dart';
import 'wiki_webview_screen.dart';

/// 報告書シリーズ 1 ページ分の SCP 一覧を取得して表示し、タップで WebView へ。
class ScpSeriesListScreen extends StatefulWidget {
  const ScpSeriesListScreen({
    super.key,
    required this.seriesTitle,
    required this.listPageUrl,
    required this.seriesIndex1Based,
  });

  final String seriesTitle;
  final String listPageUrl;

  /// シリーズ番号（Ⅰ = 1）。100 件刻みチップの範囲計算に使用。
  final int seriesIndex1Based;

  @override
  State<ScpSeriesListScreen> createState() => _ScpSeriesListScreenState();
}

class _ScpSeriesListScreenState extends State<ScpSeriesListScreen> {
  late Future<List<ScpSeriesEntry>> _future;

  /// null = 全件表示。
  int? _selectedBucket;

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  Future<List<ScpSeriesEntry>> _load() async {
    final html = await fetchWikidotHtml(widget.listPageUrl);
    return parseScpSeriesListPage(html);
  }

  int? _bucketForEntry(ScpSeriesEntry e) {
    final m = RegExp(r'^/scp-(\d+)-jp').firstMatch(e.path);
    if (m == null) return null;
    final n = int.parse(m.group(1)!);
    final idx = widget.seriesIndex1Based;
    if (idx == 1) {
      if (n < 1 || n > 999) return null;
      return (n - 1) ~/ 100;
    }
    final low = (idx - 1) * 1000;
    final high = idx * 1000 - 1;
    if (n < low || n > high) return null;
    return (n - low) ~/ 100;
  }

  Set<int> _bucketsFor(List<ScpSeriesEntry> items) {
    final s = <int>{};
    for (final e in items) {
      final b = _bucketForEntry(e);
      if (b != null) s.add(b);
    }
    return s;
  }

  String _chipLabel(int bucket) {
    final idx = widget.seriesIndex1Based;
    if (idx == 1) {
      final start = bucket * 100 + 1;
      var end = start + 99;
      if (end > 999) end = 999;
      return '${start.toString().padLeft(3, '0')}–${end.toString().padLeft(3, '0')}';
    }
    final low = (idx - 1) * 1000;
    final start = low + bucket * 100;
    var end = start + 99;
    final maxN = idx * 1000 - 1;
    if (end > maxN) end = maxN;
    return '$start–$end';
  }

  List<ScpSeriesEntry> _visible(List<ScpSeriesEntry> all) {
    final b = _selectedBucket;
    if (b == null) return all;
    return all.where((e) => _bucketForEntry(e) == b).toList();
  }

  void _openArticle(BuildContext context, ScpSeriesEntry e) {
    final url = wikidotAbsoluteUrl(e.path);
    final label =
        e.title.isEmpty ? e.scpIdLabel : '${e.scpIdLabel} - ${e.title}';
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => WikiWebViewScreen(
          initialUrl: url,
          pageTitle: label,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.seriesTitle,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.public),
            tooltip: '一覧ページをサイトで開く',
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => WikiWebViewScreen(
                    initialUrl: widget.listPageUrl,
                    pageTitle: widget.seriesTitle,
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: FutureBuilder<List<ScpSeriesEntry>>(
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
                      '一覧の取得に失敗しました。\n${snap.error}',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 16),
                    FilledButton(
                      onPressed: () => setState(() {
                        _future = _load();
                      }),
                      child: const Text('再試行'),
                    ),
                  ],
                ),
              ),
            );
          }
          final allItems = snap.data ?? [];
          if (allItems.isEmpty) {
            return Center(
              child: Text(
                '項目が見つかりませんでした。\n'
                'Wikidot の HTML 構造が変わった可能性があります。',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: ScpReaderTheme.accent,
                    ),
              ),
            );
          }

          final buckets = _bucketsFor(allItems).toList()..sort();
          final visible = _visible(allItems);
          final dock = DockLayout.bottomInsetOf(context);

          return Padding(
            padding: EdgeInsets.only(bottom: dock),
            child: Column(
              children: [
              Expanded(
                child: visible.isEmpty
                    ? Center(
                        child: Text(
                          'この範囲に該当する項目がありません。',
                          style:
                              Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: ScpReaderTheme.accent,
                                  ),
                        ),
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
                        itemCount: visible.length,
                        separatorBuilder: (context, _) =>
                            const SizedBox(height: 6),
                        itemBuilder: (context, index) {
                          final e = visible[index];
                          final subtitle =
                              e.title.isEmpty ? null : e.title;
                          return StarkCard(
                            onTap: () => _openArticle(context, e),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        e.scpIdLabel,
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleSmall,
                                      ),
                                      if (subtitle != null) ...[
                                        const SizedBox(height: 4),
                                        Text(
                                          subtitle,
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodySmall
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
                                  color: ScpReaderTheme.accent
                                      .withValues(alpha: 0.7),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
              ),
              _SeriesRangeChipBar(
                buckets: buckets,
                selectedBucket: _selectedBucket,
                chipLabel: _chipLabel,
                onSelectAll: () => setState(() => _selectedBucket = null),
                onSelectBucket: (b) =>
                    setState(() => _selectedBucket = b),
              ),
            ],
            ),
          );
        },
      ),
    );
  }
}

class _SeriesRangeChipBar extends StatelessWidget {
  const _SeriesRangeChipBar({
    required this.buckets,
    required this.selectedBucket,
    required this.chipLabel,
    required this.onSelectAll,
    required this.onSelectBucket,
  });

  final List<int> buckets;
  final int? selectedBucket;
  final String Function(int bucket) chipLabel;
  final VoidCallback onSelectAll;
  final ValueChanged<int> onSelectBucket;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xFF0A0A0A),
      child: SafeArea(
        top: false,
        child: Container(
          decoration: const BoxDecoration(
            border: Border(
              top: BorderSide(color: ScpReaderTheme.accent, width: 1),
            ),
          ),
          height: 52,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            children: [
              Padding(
                padding: const EdgeInsets.only(right: 6),
                child: ChoiceChip(
                  label: const Text('すべて'),
                  selected: selectedBucket == null,
                  onSelected: (_) => onSelectAll(),
                  selectedColor: ScpReaderTheme.accent,
                  labelStyle: TextStyle(
                    color: selectedBucket == null
                        ? Colors.black
                        : ScpReaderTheme.accent,
                    fontSize: 12,
                    fontWeight: selectedBucket == null
                        ? FontWeight.w600
                        : FontWeight.normal,
                  ),
                  backgroundColor: Colors.black,
                  side: const BorderSide(color: ScpReaderTheme.accent),
                  showCheckmark: false,
                ),
              ),
              ...buckets.map(
                (b) => Padding(
                  padding: const EdgeInsets.only(right: 6),
                  child: ChoiceChip(
                    label: Text(chipLabel(b)),
                    selected: selectedBucket == b,
                    onSelected: (_) => onSelectBucket(b),
                    selectedColor: ScpReaderTheme.accent,
                    labelStyle: TextStyle(
                      color: selectedBucket == b
                          ? Colors.black
                          : ScpReaderTheme.accent,
                      fontSize: 12,
                      fontWeight: selectedBucket == b
                          ? FontWeight.w600
                          : FontWeight.normal,
                    ),
                    backgroundColor: Colors.black,
                    side: const BorderSide(color: ScpReaderTheme.accent),
                    showCheckmark: false,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
