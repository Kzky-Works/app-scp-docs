import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/category_catalog.dart';
import '../../core/theme/scp_reader_theme.dart';
import '../../data/providers/scp_jp_series_discovery.dart';
import '../../data/repositories/favorites_repository.dart';
import '../widgets/dock_layout.dart';
import '../widgets/stark_card.dart';
import 'foundation_tales_hub_screen.dart';
import 'scp_series_list_screen.dart';
import 'series_hub_screen.dart';
import 'wiki_webview_screen.dart';

class CategoryDetailScreen extends StatelessWidget {
  const CategoryDetailScreen({
    super.key,
    required this.category,
  });

  final CategoryDefinition category;

  void _openWeb(BuildContext context, String title, String url) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => WikiWebViewScreen(
          initialUrl: url,
          pageTitle: title,
        ),
      ),
    );
  }

  void _openSubMenu(BuildContext context, SubMenuLink e) {
    if (category.id == 'scp_library' && e.url == kFoundationTalesJpHubUrl) {
      Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) => FoundationTalesHubScreen(
            hubUrl: e.url,
            title: e.label,
          ),
        ),
      );
      return;
    }
    if (category.id == 'scp_library' && e.url == kSeriesHubJpUrl) {
      Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) => SeriesHubScreen(
            hubUrl: e.url,
            title: e.label,
          ),
        ),
      );
      return;
    }
    _openWeb(context, e.label, e.url);
  }

  @override
  Widget build(BuildContext context) {
    final dock = DockLayout.bottomInsetOf(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(category.titleJa),
      ),
      body: category.isLibraryOnly
          ? _LibraryBody(onOpen: (url) => _openWeb(context, url, url))
          : category.id == 'scp_reports'
              ? _ScpDatabaseBody(
                  onOpenSeries: (listing) {
                    Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => ScpSeriesListScreen(
                          seriesTitle:
                              scpJpSeriesDisplayTitle(listing.seriesIndex1Based),
                          listPageUrl: listing.listPageUrl,
                          seriesIndex1Based: listing.seriesIndex1Based,
                        ),
                      ),
                    );
                  },
                )
              : ListView.separated(
                  padding: EdgeInsets.fromLTRB(12, 12, 12, 12 + dock),
                  itemCount: category.entries.length,
                  separatorBuilder: (context, _) => const SizedBox(height: 6),
                  itemBuilder: (context, index) {
                    final e = category.entries[index];
                    return StarkCard(
                      onTap: () => _openSubMenu(context, e),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              e.label,
                              style: Theme.of(context).textTheme.bodyLarge,
                            ),
                          ),
                          Icon(
                            Icons.open_in_new,
                            size: 18,
                            color: ScpReaderTheme.accent.withValues(alpha: 0.7),
                          ),
                        ],
                      ),
                    );
                  },
                ),
    );
  }
}

/// サイトの `scp-series-jp` ナビから JP シリーズ一覧を取得して表示。
class _ScpDatabaseBody extends StatefulWidget {
  const _ScpDatabaseBody({required this.onOpenSeries});

  final void Function(ScpJpSeriesListing listing) onOpenSeries;

  @override
  State<_ScpDatabaseBody> createState() => _ScpDatabaseBodyState();
}

class _ScpDatabaseBodyState extends State<_ScpDatabaseBody> {
  late Future<List<ScpJpSeriesListing>> _future;

  @override
  void initState() {
    super.initState();
    _future = discoverScpJpSeriesListings();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<ScpJpSeriesListing>>(
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
                    'シリーズ一覧の取得に失敗しました。\n${snap.error}',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 16),
                  FilledButton(
                    onPressed: () => setState(() {
                      _future = discoverScpJpSeriesListings();
                    }),
                    child: const Text('再試行'),
                  ),
                ],
              ),
            ),
          );
        }
        final listings = snap.data ?? [];
        if (listings.isEmpty) {
          return Center(
            child: Text(
              'JP シリーズへのリンクが見つかりませんでした。',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: ScpReaderTheme.accent,
                  ),
            ),
          );
        }
        final dock = DockLayout.bottomInsetOf(context);
        return ListView.separated(
          padding: EdgeInsets.fromLTRB(12, 12, 12, 12 + dock),
          itemCount: listings.length,
          separatorBuilder: (context, _) => const SizedBox(height: 6),
          itemBuilder: (context, index) {
            final item = listings[index];
            final title = scpJpSeriesDisplayTitle(item.seriesIndex1Based);
            final subtitle = scpJpSeriesRangeSubtitle(item.seriesIndex1Based);
            return StarkCard(
              onTap: () => widget.onOpenSeries(item),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: Theme.of(context).textTheme.titleSmall,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          subtitle,
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: ScpReaderTheme.accent,
                                  ),
                        ),
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
    );
  }
}

class _LibraryBody extends StatelessWidget {
  const _LibraryBody({required this.onOpen});

  final void Function(String url) onOpen;

  @override
  Widget build(BuildContext context) {
    final dock = DockLayout.bottomInsetOf(context);
    return Consumer<FavoritesController>(
      builder: (context, fav, _) {
        if (fav.urls.isEmpty) {
          return Center(
            child: Padding(
              padding: EdgeInsets.fromLTRB(24, 24, 24, 24 + dock),
              child: Text(
                'お気に入りはまだありません。\n'
                'WebView 画面下部の「お気に入り登録」から現在のページを保存できます。',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: ScpReaderTheme.accent,
                    ),
              ),
            ),
          );
        }
        return ListView.separated(
          padding: EdgeInsets.fromLTRB(12, 12, 12, 12 + dock),
          itemCount: fav.urls.length,
          separatorBuilder: (context, _) => const SizedBox(height: 6),
          itemBuilder: (context, index) {
            final url = fav.urls[index];
            return StarkCard(
              onTap: () => onOpen(url),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      url,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete_outline, size: 20),
                    color: ScpReaderTheme.accent,
                    onPressed: () => fav.removeAt(index),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
