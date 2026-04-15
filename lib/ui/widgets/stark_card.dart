import 'package:flutter/material.dart';

import '../../core/theme/scp_reader_theme.dart';

/// 無機質なカード（角丸 4px、細いアクセント枠）。
class StarkCard extends StatelessWidget {
  const StarkCard({
    super.key,
    required this.child,
    this.onTap,
    this.padding = const EdgeInsets.all(14),
  });

  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    final card = Card(
      child: Padding(
        padding: padding,
        child: child,
      ),
    );

    if (onTap == null) return card;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(4),
        splashColor: ScpReaderTheme.accent.withValues(alpha: 0.15),
        child: card,
      ),
    );
  }
}
