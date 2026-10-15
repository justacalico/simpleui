import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:simpleui/l10n/app_localizations.dart';
import 'package:simpleui/models/comfy.dart';
import 'package:simpleui/state/app_state.dart';
import 'package:simpleui/ui/pages/gallery_page.dart';
import 'package:simpleui/ui/pages/generate_page.dart';
import 'package:simpleui/ui/pages/queue_page.dart';
import 'package:simpleui/ui/pages/settings_page.dart';
import 'package:simpleui/ui/pages/workflows_page.dart';
import 'package:simpleui/ui/shell/app_shell.dart';

import 'fakes.dart';

Widget wrap(AppState state, Widget child, {Locale? locale}) => AppScope(
  state: state,
  child: MaterialApp(
    debugShowCheckedModeBanner: false,
    locale: locale,
    supportedLocales: AppLocalizations.supportedLocales,
    localizationsDelegates: const [
      AppLocalizations.delegate,
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
    ],
    theme: ThemeData(
      fontFamily: 'Inter',
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFF6C5CE7),
        brightness: Brightness.dark,
      ),
    ),
    home: child,
  ),
);

Future<void> snap(
  WidgetTester tester,
  String name,
  Widget child, {
  Size size = const Size(1100, 800),
  Locale? locale,
}) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(wrap(await testState(), child, locale: locale));
  await tester.pumpAndSettle();
  await expectLater(
    find.byType(MaterialApp),
    matchesGoldenFile('goldens/$name.png'),
  );
}

void main() {
  testWidgets('app shell golden', (tester) async {
    await snap(tester, 'app_shell', const AppShell());
  });

  testWidgets('generate page golden', (tester) async {
    await snap(tester, 'generate_page', const Scaffold(body: GeneratePage()));
  });

  testWidgets('generate page with results golden', (tester) async {
    final state = await testState();
    await state.imageStore.save('k1', testPng);
    await state.history.add(
      GenerationEntry(
        id: 'e1',
        params: const GenerationParams(prompt: 'a fox in the snow'),
        imageKeys: const ['k1'],
        createdAt: DateTime.utc(2026, 1, 1),
      ),
      state.prefs,
    );
    tester.view.physicalSize = const Size(1100, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(wrap(state, const Scaffold(body: GeneratePage())));
    await tester.pumpAndSettle();
    await expectLater(
      find.byType(MaterialApp),
      matchesGoldenFile('goldens/generate_result.png'),
    );
  });

  testWidgets('gallery page golden', (tester) async {
    final state = await testState();
    await state.imageStore.save('g1', testPng);
    await state.history.add(
      GenerationEntry(
        id: 'g1e',
        params: const GenerationParams(prompt: 'forest'),
        imageKeys: const ['g1'],
        createdAt: DateTime.utc(2026),
      ),
      state.prefs,
    );
    tester.view.physicalSize = const Size(1100, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(wrap(state, const Scaffold(body: GalleryPage())));
    await tester.pumpAndSettle();
    await expectLater(
      find.byType(MaterialApp),
      matchesGoldenFile('goldens/gallery_page.png'),
    );
  });

  testWidgets('queue page golden', (tester) async {
    final state = await testState();
    tester.view.physicalSize = const Size(1100, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    await state.generator.submit(
      const GenerationParams(prompt: 'a skyline'),
      WorkflowDef(name: 'w', graph: const {}, builtin: true),
    );
    await tester.pumpWidget(wrap(state, const Scaffold(body: QueuePage())));
    await tester.pumpAndSettle();
    await expectLater(
      find.byType(MaterialApp),
      matchesGoldenFile('goldens/queue_page.png'),
    );
  });

  testWidgets('workflows page golden', (tester) async {
    await snap(tester, 'workflows_page', const Scaffold(body: WorkflowsPage()));
  });

  testWidgets('settings page golden', (tester) async {
    await snap(
      tester,
      'settings_page',
      const Scaffold(body: SettingsPage()),
      size: const Size(1100, 1000),
    );
  });

  testWidgets('generate page zh golden', (tester) async {
    await snap(
      tester,
      'generate_page_zh',
      const Scaffold(body: GeneratePage()),
      locale: const Locale('zh', 'Hans'),
    );
  });
}
