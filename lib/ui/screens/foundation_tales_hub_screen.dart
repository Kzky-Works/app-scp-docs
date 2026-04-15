import 'package:flutter/material.dart';

import '../../core/constants/wikidot_base.dart';
import '../../core/theme/scp_reader_theme.dart';
import '../../data/providers/foundation_tales_parser.dart';
import '../../data/providers/wikidot_fetcher.dart';
import '../widgets/dock_layout.dart';
import '../widgets/stark_card.dart';
import 'author_works_screen.dart';
import 'wiki_webview_screen.dart';

/// 財団内物語-JP インデックスを取得し、頭文字で著者を絞り込み。
class FoundationTalesHubScreen extends StatefulWidget {
  const FoundationTalesHubScreen({
    super.key,
    required this.hubUrl,
    this.title = '財団内物語-JP',
  });

  final String hubUrl;
  final String title;

  @override
  State<FoundationTalesHubScreen> createState() =>
      _FoundationTalesHubScreenState();
}

class _FoundationTalesHubScreenState extends State<FoundationTalesHubScreen> {
  late Future<FoundationTalesParseResult> _future;
  String _sectionKey = 'A';

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  Future<FoundationTalesParseResult> _load() async {
    final html = await fetchWikidotHtml(widget.hubUrl);
    return parseFoundationTalesPage(html);
  }

  List<TaleAuthorEntry> _authorsForSection(FoundationTalesParseResult data) {
    return data.authors.where((a) => a.section == _sectionKey).toList();
  }

  void _openAuthor(BuildContext context, TaleAuthorEntry author) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => AuthorWorksScreen(
          authorName: author.name,
          works: author.works,
        ),
      ),
    );
  }

  void _openMiscLink(BuildContext context, TaleMiscLink link) {
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
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: [
          IconButton(
            icon: const Icon(Icons.public),
            tooltip: 'インデックスをサイトで開く',
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
      body: FutureBuilder<FoundationTalesParseResult>(
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
                      'インデックスの取得に失敗しました。\n${snap.error}',
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

          final data = snap.data!;
          final authors = _authorsForSection(data);
          final showMiscHub = _sectionKey == 'misc' && data.miscHubLinks.isNotEmpty;
          final dock = DockLayout.bottomInsetOf(context);

          return Padding(
            padding: EdgeInsets.only(bottom: dock),
            child: Column(
              children: [
              Expanded(
                child: ListView(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                  children: [
                    if (showMiscHub) ...[
                      Text(
                        'ハブ・一覧',
                        style: Theme.of(context).textTheme.labelLarge,
                      ),
                      const SizedBox(height: 8),
                      ...data.miscHubLinks.map(
                        (link) => Padding(
                          padding: const EdgeInsets.only(bottom: 6),
                          child: StarkCard(
                            onTap: () => _openMiscLink(context, link),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        link.title,
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleSmall,
                                      ),
                                      if (link.description.isNotEmpty) ...[
                                        const SizedBox(height: 4),
                                        Text(
                                          link.description,
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
                                  Icons.open_in_new,
                                  size: 18,
                                  color: ScpReaderTheme.accent
                                      .withValues(alpha: 0.7),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      if (authors.isNotEmpty) ...[
                        const SizedBox(height: 16),
                        Text(
                          '著者',
                          style: Theme.of(context).textTheme.labelLarge,
                        ),
                        const SizedBox(height: 8),
                      ],
                    ],
                    if (authors.isEmpty && !showMiscHub)
                      Padding(
                        padding: const EdgeInsets.only(top: 48),
                        child: Text(
                          'この頭文字の著者は見つかりませんでした。',
                          textAlign: TextAlign.center,
                          style:
                              Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: ScpReaderTheme.accent,
                                  ),
                        ),
                      )
                    else
                      ...authors.map(
                        (a) => Padding(
                          padding: const EdgeInsets.only(bottom: 6),
                          child: StarkCard(
                            onTap: () => _openAuthor(context, a),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    a.name,
                                    style:
                                        Theme.of(context).textTheme.bodyLarge,
                                  ),
                                ),
                                Text(
                                  '${a.works.length} 件',
                                  style: Theme.of(context)
                                      .textTheme
                                      .labelSmall
                                      ?.copyWith(
                                        color: ScpReaderTheme.accent,
                                      ),
                                ),
                                Icon(
                                  Icons.chevron_right,
                                  color: ScpReaderTheme.accent
                                      .withValues(alpha: 0.7),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              _SectionPickerBar(
                selected: _sectionKey,
                onSelect: (k) => setState(() => _sectionKey = k),
              ),
            ],
            ),
          );
        },
      ),
    );
  }
}

class _SectionPickerBar extends StatelessWidget {
  const _SectionPickerBar({
    required this.selected,
    required this.onSelect,
  });

  final String selected;
  final ValueChanged<String> onSelect;

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
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            itemCount: kFoundationTaleSectionOrder.length,
            separatorBuilder: (context, _) => const SizedBox(width: 6),
            itemBuilder: (context, index) {
              final key = kFoundationTaleSectionOrder[index];
              final label = foundationTaleSectionLabel(key);
              final isSel = key == selected;
              return ChoiceChip(
                label: Text(
                  label,
                  style: TextStyle(
                    color: isSel ? Colors.black : ScpReaderTheme.accent,
                    fontSize: 13,
                    fontWeight: isSel ? FontWeight.w600 : FontWeight.normal,
                  ),
                ),
                selected: isSel,
                onSelected: (_) => onSelect(key),
                selectedColor: ScpReaderTheme.accent,
                backgroundColor: Colors.black,
                side: const BorderSide(color: ScpReaderTheme.accent),
                showCheckmark: false,
                padding: const EdgeInsets.symmetric(horizontal: 4),
                visualDensity: VisualDensity.compact,
              );
            },
          ),
        ),
      ),
    );
  }
}
