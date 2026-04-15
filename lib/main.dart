import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/constants/category_catalog.dart';
import 'core/theme/scp_reader_theme.dart';
import 'data/repositories/favorites_repository.dart';
import 'ui/screens/splash_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  assert(
    kCategoriesById.length == kAllCategories.length,
    'kCategoriesById と kAllCategories を同期してください',
  );
  final favorites = FavoritesController();
  await favorites.load();

  runApp(
    ChangeNotifierProvider<FavoritesController>.value(
      value: favorites,
      child: const ScpReaderApp(),
    ),
  );
}

class ScpReaderApp extends StatelessWidget {
  const ScpReaderApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SCP Reader',
      debugShowCheckedModeBanner: false,
      theme: ScpReaderTheme.build(),
      home: const SplashScreen(),
    );
  }
}
