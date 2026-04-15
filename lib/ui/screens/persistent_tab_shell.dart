import 'package:flutter/material.dart';

import '../../core/constants/app_assets.dart';
import '../widgets/dock_layout.dart';
import '../widgets/glass_floating_tab_bar.dart';
import 'favorites_tab_screen.dart';
import 'home_screen.dart';
import 'settings_screen.dart';

/// 全画面で共通のボトムドックを最前面に固定し、タブごとに [Navigator] を保持。
class PersistentTabShell extends StatefulWidget {
  const PersistentTabShell({super.key});

  @override
  State<PersistentTabShell> createState() => _PersistentTabShellState();
}

class _PersistentTabShellState extends State<PersistentTabShell> {
  final GlobalKey<NavigatorState> _homeNavKey = GlobalKey<NavigatorState>();
  final GlobalKey<NavigatorState> _favNavKey = GlobalKey<NavigatorState>();
  final GlobalKey<NavigatorState> _settingsNavKey = GlobalKey<NavigatorState>();

  int _tabIndex = 0;

  NavigatorState? _navigatorForTab(int tab) {
    switch (tab) {
      case 0:
        return _homeNavKey.currentState;
      case 1:
        return _favNavKey.currentState;
      case 2:
        return _settingsNavKey.currentState;
      default:
        return null;
    }
  }

  void _onDockTap(int index) {
    if (_tabIndex == index) {
      _navigatorForTab(index)?.popUntil((route) => route.isFirst);
    }
    setState(() => _tabIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    final dockH = GlassBottomDock.totalHeight(context);

    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: DockLayout(
        bottomInset: dockH,
        child: Stack(
          fit: StackFit.expand,
          children: [
            IndexedStack(
              index: _tabIndex,
              children: [
                Navigator(
                  key: _homeNavKey,
                  onGenerateInitialRoutes: (nav, initialRoute) => [
                    MaterialPageRoute<void>(
                      builder: (_) => const HomeScreen(),
                    ),
                  ],
                ),
                Navigator(
                  key: _favNavKey,
                  onGenerateInitialRoutes: (nav, initialRoute) => [
                    MaterialPageRoute<void>(
                      builder: (_) => const FavoritesTabScreen(),
                    ),
                  ],
                ),
                Navigator(
                  key: _settingsNavKey,
                  onGenerateInitialRoutes: (nav, initialRoute) => [
                    MaterialPageRoute<void>(
                      builder: (_) => const SettingsScreen(),
                    ),
                  ],
                ),
              ],
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: GlassBottomDock(
                currentIndex: _tabIndex,
                onTap: _onDockTap,
                items: [
                  GlassTabItem(
                    assetPath: AppAssets.scpHomeIcon,
                    label: 'ホーム',
                    semanticLabel: 'ホーム',
                  ),
                  GlassTabItem(
                    icon: Icons.star_rounded,
                    label: 'お気に入り',
                    semanticLabel: 'お気に入り',
                  ),
                  GlassTabItem(
                    icon: Icons.settings_rounded,
                    label: '設定',
                    semanticLabel: '設定',
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
