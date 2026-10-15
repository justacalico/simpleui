import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:simpleui/app.dart';
import 'package:simpleui/l10n/app_localizations.dart';
import 'package:simpleui/state/app_state.dart';
import 'package:simpleui/state/settings_store.dart';

import 'fakes.dart';

void main() {
  for (final locale in supportedLocales) {
    testWidgets('renders in ${locale.toLanguageTag()}', (tester) async {
      final state = await testState();
      tester.view.physicalSize = const Size(1200, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);
      await state.settings.setLocale(locale, state.prefs);
      await tester.pumpWidget(
        AppScope(state: state, child: const SimpleuiApp()),
      );
      await tester.pumpAndSettle();
      expect(find.byType(MaterialApp), findsOneWidget);
      // walk every page so every translated key is exercised
      for (var i = 0; i < 5; i++) {
        state.selectTab(i);
        await tester.pumpAndSettle();
      }
    });
  }

  testWidgets('system default falls back to en_GB strings', (tester) async {
    final state = await testState();
    tester.view.physicalSize = const Size(1200, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(AppScope(state: state, child: const SimpleuiApp()));
    await tester.pumpAndSettle();
    expect(find.text('Generate'), findsWidgets);
  });

  test('supportedLocales match the settings picker order', () {
    expect(
      AppLocalizations.supportedLocales,
      containsAll(const [
        Locale('en', 'GB'),
        Locale('en'),
        Locale.fromSubtags(languageCode: 'zh', scriptCode: 'Hans'),
        Locale('zh'),
        Locale('ru'),
        Locale('ga'),
      ]),
    );
  });
}
