import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data/category_catalog.dart';
import '../providers/favorites_controller.dart';
import '../theme/scp_reader_theme.dart';
import '../widgets/stark_card.dart';
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(category.titleJa),
      ),
      body: category.isLibraryOnly
          ? _LibraryBody(onOpen: (url) => _openWeb(context, url, url))
          : ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              itemCount: category.entries.length,
              separatorBuilder: (context, _) => const SizedBox(height: 6),
              itemBuilder: (context, index) {
                final e = category.entries[index];
                return StarkCard(
                  onTap: () => _openWeb(context, e.label, e.url),
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

class _LibraryBody extends StatelessWidget {
  const _LibraryBody({required this.onOpen});

  final void Function(String url) onOpen;

  @override
  Widget build(BuildContext context) {
    return Consumer<FavoritesController>(
      builder: (context, fav, _) {
        if (fav.urls.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
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
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
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
