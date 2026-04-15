import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/physics.dart';

import '../../core/theme/glass_dock_tokens.dart';

/// 1 タブ分。`icon` と `assetPath` のどちらか一方を指定。
class GlassTabItem {
  const GlassTabItem({
    this.icon,
    this.assetPath,
    required this.label,
    required this.semanticLabel,
  }) : assert(
          icon != null || assetPath != null,
          'icon または assetPath のどちらかが必要です',
        );

  final IconData? icon;
  final String? assetPath;
  final String label;
  final String semanticLabel;
}

/// 画面最下部に固定する全幅グラスドック（Prime Video 系の発光アクティブ）。
///
/// ホームインジケータ領域まで背景を伸ばし、その上にタブ行を配置。
class GlassBottomDock extends StatefulWidget {
  const GlassBottomDock({
    super.key,
    required this.items,
    required this.currentIndex,
    required this.onTap,
  });

  final List<GlassTabItem> items;
  final int currentIndex;
  final ValueChanged<int> onTap;

  /// ドック全体の高さ（タブ行 + 下端セーフエリア）。レイアウト用。
  static double totalHeight(BuildContext context) {
    return GlassDockTokens.barContentHeight +
        MediaQuery.paddingOf(context).bottom;
  }

  @override
  State<GlassBottomDock> createState() => _GlassBottomDockState();
}

class _GlassBottomDockState extends State<GlassBottomDock>
    with SingleTickerProviderStateMixin {
  late final AnimationController _springCtrl;

  double _barWidth = 0;
  bool _laidOut = false;

  @override
  void initState() {
    super.initState();
    _springCtrl = AnimationController.unbounded(vsync: this)
      ..addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _springCtrl.dispose();
    super.dispose();
  }

  double _centerXForIndex(int index, double width) {
    final n = widget.items.length;
    if (n == 0 || width <= 0) return 0;
    final cell = width / n;
    return cell * index + cell / 2;
  }

  void _syncSpringToIndex(int index, double width, {bool jump = false}) {
    final target = _centerXForIndex(index, width);
    if (jump) {
      _springCtrl.value = target;
      _springCtrl.stop();
      return;
    }
    final v = _springCtrl.velocity;
    _springCtrl.animateWith(
      SpringSimulation(
        GlassDockTokens.indicatorSpring,
        _springCtrl.value,
        target,
        v.isNaN ? 0 : v,
      ),
    );
  }

  @override
  void didUpdateWidget(covariant GlassBottomDock oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.currentIndex != widget.currentIndex && _barWidth > 0) {
      _syncSpringToIndex(widget.currentIndex, _barWidth);
    }
  }

  @override
  Widget build(BuildContext context) {
    final accent = Theme.of(context).colorScheme.primary;
    final bottomSafe = MediaQuery.paddingOf(context).bottom;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final glassTint = isDark
        ? Colors.white.withValues(
            alpha: 0.06 * GlassDockTokens.materialOpacityDark,
          )
        : Colors.white.withValues(alpha: 0.75);

    return LayoutBuilder(
      builder: (context, constraints) {
        final w = constraints.maxWidth;
        if (w > 0 && !_laidOut) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (!mounted || _laidOut) return;
            setState(() {
              _barWidth = w;
              _springCtrl.value = _centerXForIndex(widget.currentIndex, w);
              _springCtrl.stop();
              _laidOut = true;
            });
          });
        } else if (w > 0 && _laidOut && (_barWidth - w).abs() > 0.5) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (!mounted) return;
            setState(() {
              _barWidth = w;
              _syncSpringToIndex(widget.currentIndex, w, jump: true);
            });
          });
        }

        final glowCenterX = _springCtrl.value;

        return ClipRRect(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(GlassDockTokens.fullWidthTopRadius),
          ),
          child: BackdropFilter(
            filter: ImageFilter.blur(
              sigmaX: GlassDockTokens.blurSigma,
              sigmaY: GlassDockTokens.blurSigma,
            ),
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: glassTint,
                border: Border(
                  top: BorderSide(
                    color: Colors.white.withValues(alpha: 0.08),
                    width: 0.5,
                  ),
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    height: GlassDockTokens.barContentHeight,
                    child: Stack(
                      clipBehavior: Clip.none,
                      alignment: Alignment.center,
                      children: [
                        // アクティブ・グロウ（アイコン直上の柔らかい白光）
                        if (w > 0 && _laidOut)
                          Positioned(
                            left: glowCenterX - GlassDockTokens.glowWidth / 2,
                            top: 6,
                            child: IgnorePointer(
                              child: Container(
                                width: GlassDockTokens.glowWidth,
                                height: GlassDockTokens.glowHeight,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(20),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.white.withValues(
                                        alpha: 0.45,
                                      ),
                                      blurRadius: 22,
                                      spreadRadius: 0,
                                    ),
                                    BoxShadow(
                                      color: accent.withValues(alpha: 0.2),
                                      blurRadius: 12,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        Row(
                          children: List.generate(widget.items.length, (index) {
                            final item = widget.items[index];
                            final selected = widget.currentIndex == index;
                            return Expanded(
                              child: _DockTabCell(
                                item: item,
                                selected: selected,
                                accent: accent,
                                onTap: () => widget.onTap(index),
                              ),
                            );
                          }),
                        ),
                      ],
                    ),
                  ),
                  ColoredBox(
                    color: Colors.black.withValues(alpha: 0.25),
                    child: SizedBox(
                      width: double.infinity,
                      height: bottomSafe,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _DockTabCell extends StatefulWidget {
  const _DockTabCell({
    required this.item,
    required this.selected,
    required this.accent,
    required this.onTap,
  });

  final GlassTabItem item;
  final bool selected;
  final Color accent;
  final VoidCallback onTap;

  @override
  State<_DockTabCell> createState() => _DockTabCellState();
}

class _DockTabCellState extends State<_DockTabCell>
    with SingleTickerProviderStateMixin {
  static const int _wPress = 90;
  static const int _wUp = 110;
  static const int _wSettle = 120;

  late final AnimationController _bounceCtrl;
  late final Animation<double> _bounceScale;

  @override
  void initState() {
    super.initState();
    _bounceCtrl = AnimationController(
      vsync: this,
      duration: const Duration(
        milliseconds: _wPress + _wUp + _wSettle,
      ),
    )..addListener(() => setState(() {}));

    _bounceScale = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(
          begin: 1.0,
          end: GlassDockTokens.iconPressScale,
        ).chain(CurveTween(curve: Curves.easeOut)),
        weight: _wPress.toDouble(),
      ),
      TweenSequenceItem(
        tween: Tween<double>(
          begin: GlassDockTokens.iconPressScale,
          end: GlassDockTokens.iconOvershootScale,
        ).chain(CurveTween(curve: Curves.easeOut)),
        weight: _wUp.toDouble(),
      ),
      TweenSequenceItem(
        tween: Tween<double>(
          begin: GlassDockTokens.iconOvershootScale,
          end: 1.0,
        ).chain(CurveTween(curve: Curves.easeInOut)),
        weight: _wSettle.toDouble(),
      ),
    ]).animate(_bounceCtrl);
  }

  @override
  void dispose() {
    _bounceCtrl.dispose();
    super.dispose();
  }

  Widget _icon(Color iconColor) {
    final path = widget.item.assetPath;
    if (path != null) {
      final img = Image.asset(
        path,
        width: 26,
        height: 26,
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) => Icon(
          Icons.shield_outlined,
          size: 24,
          color: iconColor,
        ),
      );
      if (!widget.selected) {
        return Opacity(opacity: 0.45, child: img);
      }
      return img;
    }
    return Icon(
      widget.item.icon!,
      size: 24,
      color: iconColor,
    );
  }

  @override
  Widget build(BuildContext context) {
    final iconColor = widget.selected
        ? Colors.white
        : widget.accent.withValues(alpha: 0.45);
    final textColor = widget.selected
        ? Colors.white
        : widget.accent.withValues(alpha: 0.45);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          widget.onTap();
          _bounceCtrl.forward(from: 0);
        },
        child: Semantics(
          button: true,
          selected: widget.selected,
          label: widget.item.semanticLabel,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Transform.scale(
                scale: _bounceScale.value,
                child: _icon(iconColor),
              ),
              const SizedBox(height: 2),
              Text(
                widget.item.label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      fontSize: 10,
                      height: 1.1,
                      color: textColor,
                      fontWeight:
                          widget.selected ? FontWeight.w600 : FontWeight.w400,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
