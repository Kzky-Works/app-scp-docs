import 'package:flutter/material.dart';

/// グローバル・ボトムドックとコンテンツが重ならないよう、下側インセットを子孫へ伝える。
class DockLayout extends InheritedWidget {
  const DockLayout({
    super.key,
    required this.bottomInset,
    required super.child,
  });

  /// ドック本体（タブ行＋ホームインジケータ領域）の高さ分。
  final double bottomInset;

  static double bottomInsetOf(BuildContext context) {
    final d = context.dependOnInheritedWidgetOfExactType<DockLayout>();
    return d?.bottomInset ?? 0;
  }

  @override
  bool updateShouldNotify(covariant DockLayout oldWidget) =>
      oldWidget.bottomInset != bottomInset;
}
