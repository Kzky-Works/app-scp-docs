import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/domain_provider.dart';

/// ドメイン切り替えのプレースホルダー（一覧は後続で拡張）。
class SettingsTab extends ConsumerWidget {
  const SettingsTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final domain = ref.watch(domainProvider);
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text(
          'Wiki ドメイン',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Text('現在: $domain'),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _DomainChip(
              label: 'JP',
              value: 'scp-jp.wikidot.com',
            ),
            _DomainChip(
              label: 'EN',
              value: 'scp-wiki.wikidot.com',
            ),
            _DomainChip(
              label: 'CN',
              value: 'scp-wiki-cn.wikidot.com',
            ),
          ],
        ),
      ],
    );
  }
}

class _DomainChip extends ConsumerWidget {
  const _DomainChip({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final current = ref.watch(domainProvider);
    final selected = current == value;
    return FilterChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) =>
          ref.read(domainProvider.notifier).setDomain(value),
    );
  }
}
