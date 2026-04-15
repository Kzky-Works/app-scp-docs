import 'package:flutter/material.dart';

import '../../core/theme/scp_reader_theme.dart';
import '../widgets/dock_layout.dart';

/// 設定タブ（プレースホルダー。今後テーマ切替等を足せる）。
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final dock = DockLayout.bottomInsetOf(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('設定'),
      ),
      body: ListView(
        padding: EdgeInsets.fromLTRB(16, 16, 16, 16 + dock),
        children: [
          Text(
            'SCP Reader',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Text(
            'バージョン 1.0.0',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: ScpReaderTheme.accent,
                ),
          ),
          const SizedBox(height: 24),
          Text(
            '表示や通知などの設定は、今後の更新で追加できます。',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: ScpReaderTheme.accent,
                ),
          ),
        ],
      ),
    );
  }
}
