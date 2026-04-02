import 'package:flutter/material.dart';

import '../widgets/bottom_banner_ad.dart';
import 'archive/archive_tab.dart';
import 'home/home_tab.dart';
import 'search/search_tab.dart';
import 'settings/settings_tab.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _index = 0;

  static const _tabs = [
    _NavItem(label: 'ホーム', icon: Icons.home_outlined),
    _NavItem(label: '検索', icon: Icons.search),
    _NavItem(label: 'アーカイブ', icon: Icons.inventory_2_outlined),
    _NavItem(label: '設定', icon: Icons.settings_outlined),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('SCP Docs'),
      ),
      body: IndexedStack(
        index: _index,
        children: const [
          HomeTab(),
          SearchTab(),
          ArchiveTab(),
          SettingsTab(),
        ],
      ),
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          NavigationBar(
            selectedIndex: _index,
            onDestinationSelected: (i) => setState(() => _index = i),
            destinations: [
              for (final t in _tabs)
                NavigationDestination(
                  icon: Icon(t.icon),
                  label: t.label,
                ),
            ],
          ),
          const BottomBannerAd(),
        ],
      ),
    );
  }
}

class _NavItem {
  const _NavItem({required this.label, required this.icon});
  final String label;
  final IconData icon;
}
