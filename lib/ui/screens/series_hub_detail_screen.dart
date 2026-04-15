import 'package:flutter/material.dart';

import '../../core/constants/wikidot_base.dart';
import '../../core/theme/scp_reader_theme.dart';
import '../../data/providers/series_hub_detail_parser.dart';
import '../../data/providers/wikidot_fetcher.dart';
import '../widgets/dock_layout.dart';
import '../widgets/stark_card.dart';
import 'wiki_webview_screen.dart';

/// 単一連作ハブページから作品リンクを抽出して一覧表示。
class SeriesHubDetailScreen extends StatefulWidget {
  const SeriesHubDetailScreen({
    super.key,
    required this.hubTitle,
    required this.hubPath,
  });

  final String hubTitle;
  final String hubPath;

  @override
  State<SeriesHubDetailScreen> createState() => _SeriesHubDetailScreenState();
}

class _SeriesHubDetailScreenState extends State<SeriesHubDetailScreen> {
  late Future<List<HubArticleLink>> _future;

  String get _hubUrl => wikidotAbsoluteUrl(widget.hubPath);

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  Future<List<HubArticleLink>> _load() async {
    final html = await fetchWikidotHtml(_hubUrl);
    return parseHubArticleListPage(html);
  }

  void _openArticle(HubArticleLink link) {
    final url = wikidotAbsoluteUrl(link.path);
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => WikiWebViewScreen(
          initialUrl: url,
          pageTitle: link.title,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final dock = DockLayout.bottomInsetOf(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.hubTitle,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.public),
            tooltip: 'ハブをサイトで開く',
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => WikiWebViewScreen(
                    initialUrl: _hubUrl,
                    pageTitle: widget.hubTitle,
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: FutureBuilder<List<HubArticleLink>>(
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
                      'ページの取得に失敗しました。\n${snap.error}',
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
          final items = snap.data ?? [];
          if (items.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '自動抽出できる作品リストが見つかりませんでした。\n'
                      'ハブのレイアウトが異なる可能性があります。',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: ScpReaderTheme.accent,
                          ),
                    ),
                    const SizedBox(height: 20),
                    FilledButton(
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute<void>(
                            builder: (_) => WikiWebViewScreen(
                              initialUrl: _hubUrl,
                              pageTitle: widget.hubTitle,
                            ),
                          ),
                        );
                      },
                      child: const Text('WebView でハブを開く'),
                    ),
                  ],
                ),
              ),
            );
          }
          return ListView.separated(
            padding: EdgeInsets.fromLTRB(12, 12, 12, 12 + dock),
            itemCount: items.length,
            separatorBuilder: (context, _) => const SizedBox(height: 6),
            itemBuilder: (context, index) {
              final link = items[index];
              return StarkCard(
                onTap: () => _openArticle(link),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        link.title,
                        style: Theme.of(context).textTheme.bodyLarge,
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
