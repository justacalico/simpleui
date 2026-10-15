import 'package:flutter_test/flutter_test.dart';
import 'package:simpleui/app.dart';
import 'package:simpleui/models/app_update.dart';
import 'package:simpleui/state/app_state.dart';
import 'package:simpleui/ui/shell/app_shell.dart';
import 'package:flutter/material.dart';

import 'fakes.dart';

void main() {
  test('selectTab notifies only on change', () async {
    final state = await testState();
    var calls = 0;
    state.addListener(() => calls++);
    state.selectTab(0);
    expect(calls, 0);
    state.selectTab(2);
    expect(calls, 1);
    expect(state.tabIndex, 2);
  });

  test('checkForUpdate de-dupes concurrent calls and caches', () async {
    final checker = FakeVersionChecker()
      ..result = AppUpdate(
        currentVersion: '1.0.0',
        latestVersion: '1.1.0',
        updateAvailable: true,
        releaseUrl: 'u',
      );
    final state = await testState(versionChecker: checker);
    final results = await Future.wait([
      state.checkForUpdate(),
      state.checkForUpdate(),
    ]);
    expect(results.first!.updateAvailable, true);
    expect(state.update!.latestVersion, '1.1.0');
    await state.checkForUpdate();
    expect(checker.calls, 2); // concurrent calls shared the in-flight future
  });

  test('checkForUpdate failure returns null', () async {
    final checker = FakeVersionChecker()..error = Exception('x');
    final state = await testState(versionChecker: checker);
    expect(await state.checkForUpdate(), isNull);
    expect(state.update, isNull);
  });

  testWidgets('AppScope resolves state', (tester) async {
    final state = await testState();
    late AppState found;
    await tester.pumpWidget(
      AppScope(
        state: state,
        child: Builder(
          builder: (context) {
            found = AppScope.of(context);
            expect(AppScope.read(context), state);
            return const SizedBox();
          },
        ),
      ),
    );
    expect(found, state);
  });

  testWidgets('full app shell mounts all five tabs', (tester) async {
    final state = await testState();
    tester.view.physicalSize = const Size(1200, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(AppScope(state: state, child: const SimpleuiApp()));
    await tester.pumpAndSettle();
    expect(find.byType(AppShell), findsOneWidget);
    for (final i in [1, 2, 3, 4, 0]) {
      state.selectTab(i);
      await tester.pumpAndSettle();
    }
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
