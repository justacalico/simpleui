import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:simpleui/app.dart';
import 'package:simpleui/state/app_state.dart';
import 'package:simpleui/state/settings_store.dart';

import 'fakes.dart';

Future<void> pumpApp(
  WidgetTester tester,
  AppState state, {
  Size size = const Size(1200, 800),
  Brightness brightness = Brightness.light,
}) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);
  tester.platformDispatcher.platformBrightnessTestValue = brightness;
  addTearDown(() {
    tester.platformDispatcher.clearAllTestValues();
  });
  await tester.pumpWidget(AppScope(state: state, child: const SimpleuiApp()));
}

void main() {
  testWidgets('builds with the sidebar on wide windows', (tester) async {
    await pumpApp(tester, await testState());
    await tester.pumpAndSettle();
    expect(find.text('Generate'), findsWidgets);
  });

  for (final theme in AppTheme.values) {
    testWidgets('theme $theme builds', (tester) async {
      final state = await testState();
      await state.settings.setTheme(theme, state.prefs);
      await pumpApp(tester, state);
      await tester.pumpAndSettle();
      expect(find.byType(MaterialApp), findsOneWidget);
    });
  }

  testWidgets('locale override applies', (tester) async {
    final state = await testState();
    await state.settings.setLocale(const Locale('ru'), state.prefs);
    await pumpApp(tester, state);
    await tester.pumpAndSettle();
    final app = tester.widget<MaterialApp>(find.byType(MaterialApp));
    expect(app.locale, const Locale('ru'));
  });
}
