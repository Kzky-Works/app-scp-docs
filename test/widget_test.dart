import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:scp_reader/providers/favorites_controller.dart';
import 'package:scp_reader/screens/home_screen.dart';
import 'package:scp_reader/screens/splash_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Splash then home after delay', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final fav = FavoritesController();
    await fav.load();

    await tester.pumpWidget(
      ChangeNotifierProvider<FavoritesController>.value(
        value: fav,
        child: MaterialApp(
          theme: ThemeData.dark(),
          home: const SplashScreen(),
        ),
      ),
    );

    expect(
      find.textContaining('ACCESSING FOUNDATION DATABASE'),
      findsOneWidget,
    );

    await tester.pump(const Duration(milliseconds: 2500));
    await tester.pumpAndSettle();

    expect(find.byType(HomeScreen), findsOneWidget);
    expect(find.textContaining('SCP READER'), findsOneWidget);
  });
}
