import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import 'screens/main_screen.dart';
import 'theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (!kIsWeb &&
      (defaultTargetPlatform == TargetPlatform.android ||
          defaultTargetPlatform == TargetPlatform.iOS)) {
    await MobileAds.instance.initialize();
  }

  final appTheme = AppTheme.defaults();
  runApp(
    ProviderScope(
      child: ScpDocsApp(theme: appTheme, home: const MainScreen()),
    ),
  );
}

class ScpDocsApp extends StatelessWidget {
  const ScpDocsApp({super.key, required this.theme, required this.home});

  final AppTheme theme;
  final Widget home;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SCP Docs',
      theme: theme.toMaterialTheme(),
      home: home,
    );
  }
}
