import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:scp_docs/main.dart';
import 'package:scp_docs/theme/app_theme.dart';

void main() {
  testWidgets('ScpDocsApp applies theme and title', (WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        child: ScpDocsApp(
          theme: AppTheme.defaults(),
          home: Scaffold(
            appBar: AppBar(title: const Text('SCP Docs')),
          ),
        ),
      ),
    );

    expect(find.text('SCP Docs'), findsOneWidget);
  });
}
