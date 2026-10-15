import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:simpleui/models/app_update.dart';
import 'package:simpleui/state/settings_store.dart';
import 'package:simpleui/ui/pages/settings_page.dart';

import 'fakes.dart';

void main() {
  testWidgets('server url field updates settings and validates', (
    tester,
  ) async {
    final state = await testState();
    await pumpPage(
      tester,
      state,
      const SettingsPage(),
      size: const Size(900, 1000),
    );
    await tester.enterText(
      find.byKey(const Key('settings.serverUrl')),
      'not a url at all ::',
    );
    await tester.pump();
    await tester.enterText(
      find.byKey(const Key('settings.serverUrl')),
      'https://gpu.lan:8188',
    );
    await tester.pump();
    expect(state.settings.serverUrl, 'https://gpu.lan:8188');
  });

  testWidgets('test connection shows stats then failure', (tester) async {
    final api = FakeComfyApi();
    final state = await testState(api: api);
    await pumpPage(
      tester,
      state,
      const SettingsPage(),
      size: const Size(900, 1000),
    );
    await tester.tap(find.byKey(const Key('settings.testConnection')));
    await tester.pumpAndSettle();
    expect(find.textContaining('Test GPU'), findsOneWidget);

    api.statsError = Exception('down');
    await tester.tap(find.byKey(const Key('settings.testConnection')));
    await tester.pumpAndSettle();
    expect(find.text('Could not reach the server'), findsOneWidget);
  });

  testWidgets('theme and language dropdowns persist', (tester) async {
    final state = await testState();
    await pumpPage(
      tester,
      state,
      const SettingsPage(),
      size: const Size(900, 1200),
    );

    await tester.tap(find.byKey(const Key('settings.theme')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('OLED').last);
    await tester.pumpAndSettle();
    expect(state.settings.theme, AppTheme.oled);

    await tester.tap(find.byKey(const Key('settings.language')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Русский').last);
    await tester.pumpAndSettle();
    expect(state.settings.locale, const Locale('ru'));

    await tester.tap(find.byKey(const Key('settings.language')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('System').last);
    await tester.pumpAndSettle();
    expect(state.settings.locale, isNull);
  });

  testWidgets('accent swatches update the theme color', (tester) async {
    final state = await testState();
    await pumpPage(
      tester,
      state,
      const SettingsPage(),
      size: const Size(900, 1200),
    );
    await tester.tap(find.byKey(const Key('settings.accent.ff2e7d32')));
    await tester.pumpAndSettle();
    expect(state.settings.accentColor, 0xFF2E7D32);
    expect(find.byIcon(Icons.check), findsOneWidget);
  });

  testWidgets('update check: up to date, available, failed', (tester) async {
    final checker = FakeVersionChecker()
      ..result = AppUpdate(
        currentVersion: '1.0.0',
        latestVersion: '1.0.0',
        updateAvailable: false,
        releaseUrl: 'https://gitlab.com/x',
      );
    final state = await testState(versionChecker: checker);
    await pumpPage(
      tester,
      state,
      const SettingsPage(),
      size: const Size(900, 1400),
    );
    await tester.tap(find.byKey(const Key('settings.checkUpdates')));
    await tester.pumpAndSettle();
    expect(find.text('Up to date'), findsOneWidget);
    expect(checker.calls, 1);

    checker.result = AppUpdate(
      currentVersion: '1.0.0',
      latestVersion: '2.0.0',
      updateAvailable: true,
      releaseUrl:
          'https://gitlab.com/HttpAnimations/simpleui/-/releases/v2.0.0',
    );
    await tester.tap(find.byKey(const Key('settings.checkUpdates')));
    await tester.pumpAndSettle();
    expect(find.textContaining('2.0.0'), findsWidgets);

    await tester.tap(find.byKey(const Key('settings.getUpdate')));
    expect(state.update!.updateAvailable, true);
  });

  testWidgets('failed update check shows feedback', (tester) async {
    final checker = FakeVersionChecker()..error = Exception('offline');
    final state = await testState(versionChecker: checker);
    await pumpPage(
      tester,
      state,
      const SettingsPage(),
      size: const Size(900, 1400),
    );
    await tester.tap(find.byKey(const Key('settings.checkUpdates')));
    await tester.pumpAndSettle();
    expect(find.text('Update check failed'), findsOneWidget);
  });

  testWidgets('release and source links launch', (tester) async {
    final launches = <Uri>[];
    final state = await testState(launches: launches);
    await pumpPage(
      tester,
      state,
      const SettingsPage(),
      size: const Size(900, 1400),
    );
    await tester.tap(find.byKey(const Key('settings.releases')));
    await tester.tap(find.byKey(const Key('settings.source')));
    expect(launches.length, 2);
    expect(
      launches.first.toString(),
      'https://gitlab.com/HttpAnimations/simpleui/-/releases',
    );
    expect(
      launches.last.toString(),
      'https://gitlab.com/HttpAnimations/simpleui',
    );
  });

  testWidgets('invalid url shows the error text', (tester) async {
    final state = await testState();
    await pumpPage(
      tester,
      state,
      const SettingsPage(),
      size: const Size(900, 1000),
    );
    await tester.enterText(
      find.byKey(const Key('settings.serverUrl')),
      '::bad::',
    );
    await tester.pump();
    expect(find.text('Enter a valid http(s) URL'), findsOneWidget);
  });
}
