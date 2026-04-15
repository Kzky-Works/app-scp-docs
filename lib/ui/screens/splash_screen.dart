import 'package:flutter/material.dart';

import '../../core/theme/scp_reader_theme.dart';
import 'persistent_tab_shell.dart';

/// 財団ロゴ（プレースホルダ）とアクセス文言。
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future<void>.delayed(const Duration(milliseconds: 2400), () {
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute<void>(
          builder: (_) => const PersistentTabShell(),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ScpReaderTheme.background,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 88,
              height: 88,
              decoration: BoxDecoration(
                border: Border.all(color: ScpReaderTheme.accent, width: 2),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Icon(
                Icons.shield_outlined,
                size: 48,
                color: ScpReaderTheme.accent,
              ),
            ),
            const SizedBox(height: 28),
            Text(
              'ACCESSING FOUNDATION DATABASE...',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: ScpReaderTheme.accent,
                    letterSpacing: 1.2,
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: 20),
            const SizedBox(
              width: 28,
              height: 28,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: ScpReaderTheme.accent,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
