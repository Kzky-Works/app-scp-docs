import 'package:flutter/material.dart';

import '../../core/constants/wikidot_base.dart';
import '../../core/theme/scp_reader_theme.dart';
import '../../data/providers/foundation_tales_parser.dart';
import '../widgets/dock_layout.dart';
import '../widgets/stark_card.dart';
import 'wiki_webview_screen.dart';

/// 1 著者の物語一覧。
class AuthorWorksScreen extends StatelessWidget {
  const AuthorWorksScreen({
    super.key,
    required this.authorName,
    required this.works,
  });

  final String authorName;
  final List<TaleWorkEntry> works;

  void _openWork(BuildContext context, TaleWorkEntry w) {
    final url = wikidotAbsoluteUrl(w.path);
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => WikiWebViewScreen(
          initialUrl: url,
          pageTitle: w.title,
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
          authorName,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
      body: ListView.separated(
        padding: EdgeInsets.fromLTRB(12, 12, 12, 12 + dock),
        itemCount: works.length,
        separatorBuilder: (context, _) => const SizedBox(height: 6),
        itemBuilder: (context, index) {
          final w = works[index];
          return StarkCard(
            onTap: () => _openWork(context, w),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        w.title,
                        style: Theme.of(context).textTheme.titleSmall,
                      ),
                      if (w.summary.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          w.summary,
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
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
      ),
    );
  }
}
