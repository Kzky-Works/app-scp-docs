import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/scp_reader_theme.dart';
import '../../data/repositories/favorites_repository.dart';
import '../widgets/dock_layout.dart';
import '../widgets/stark_card.dart';
import 'wiki_webview_screen.dart';

/// グラスドック付きシェル用のお気に入りタブ。
class FavoritesTabScreen extends StatelessWidget {
  const FavoritesTabScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final dock = DockLayout.bottomInsetOf(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('お気に入り'),
      ),
      body: Consumer<FavoritesController>(
        builder: (context, fav, _) {
          if (fav.urls.isEmpty) {
            return Padding(
              padding: EdgeInsets.fromLTRB(24, 24, 24, 24 + dock),
              child: Center(
                child: Text(
                  'お気に入りはまだありません。\n'
                  '記事を WebView で開いたあと、下部の星から保存できます。',
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
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => WikiWebViewScreen(
                        initialUrl: url,
                        pageTitle: url,
                      ),
                    ),
                  );
                },
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
      ),
    );
  }
}
