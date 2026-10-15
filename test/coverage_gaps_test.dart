import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:simpleui/models/app_update.dart';
import 'package:simpleui/models/comfy.dart';
import 'package:simpleui/services/comfy_api.dart';
import 'package:simpleui/services/version_checker.dart';
import 'package:simpleui/state/generate_controller.dart';
import 'package:simpleui/ui/pages/settings_page.dart';
import 'package:simpleui/ui/pages/workflows_page.dart';
import 'package:simpleui/ui/shell/app_shell.dart';
import 'package:simpleui/ui/shell/side_nav.dart';
import 'package:simpleui/ui/shell/title_bar.dart';

import 'fakes.dart';

void main() {
  test('AppUpdate equality', () {
    const a = AppUpdate(currentVersion: '1', latestVersion: '2');
    const b = AppUpdate(currentVersion: '1', latestVersion: '2');
    const c = AppUpdate(currentVersion: '1', latestVersion: '3');
    expect(a, b);
    expect(a == c, false);
    expect(a.hashCode, b.hashCode);
    expect(a == Object(), false);
  });

  test('VersionCheckException toString', () {
    expect(
      const VersionCheckException('x').toString(),
      'VersionCheckException: x',
    );
  });

  test('HttpComfyApi creates its own client', () {
    final api = HttpComfyApi(Uri.parse('http://x'));
    expect(api.client, isA<http.Client>());
  });

  test('completion failure marks the job failed', () async {
    final api = _FailingHistoryApi();
    final socket = FakeSocket();
    final state = await testState(api: api, socket: socket);
    final job = await state.generator.submit(
      const GenerationParams(prompt: 'x'),
      WorkflowDef(name: 'w', graph: const {}, builtin: true),
    );
    socket.controller.add(
      jsonEncode({
        'type': 'executed',
        'data': {'prompt_id': job.promptId},
      }),
    );
    await Future<void>.delayed(const Duration(milliseconds: 10));
    await Future<void>.delayed(const Duration(milliseconds: 10));
    expect(job.status, JobStatus.failed);
    expect(job.error, contains('nope'));
  });

  test('history clear deletes image blobs', () async {
    final state = await testState();
    await state.imageStore.save('blob', testPng);
    await state.history.add(
      GenerationEntry(
        id: 'x',
        params: const GenerationParams(),
        imageKeys: const ['blob'],
        createdAt: DateTime.utc(2026),
      ),
      state.prefs,
    );
    await state.history.clear(state.prefs, state.imageStore);
    expect(await state.imageStore.read('blob'), isNull);
  });

  testWidgets('desktop shell renders the title bar', (tester) async {
    debugDefaultTargetPlatformOverride = TargetPlatform.linux;
    final state = await testState(windowActions: FakeWindowActions());
    await pumpPage(
      tester,
      state,
      const AppShell(),
      size: const Size(1100, 700),
    );
    expect(find.byType(AppTitleBar), findsOneWidget);
    expect(find.byType(TrafficLights), findsOneWidget);
    debugDefaultTargetPlatformOverride = null;
  });

  testWidgets('side nav with header and footer items', (tester) async {
    var tapped = -1;
    final state = await testState();
    await pumpPage(
      tester,
      state,
      SizedBox(
        height: 600,
        child: SideNav(
          selectedIndex: 0,
          onSelected: (i) => tapped = i,
          header: const Text('head'),
          footerCount: 1,
          destinations: const [
            (icon: Icons.home, selectedIcon: Icons.home, label: 'a'),
            (icon: Icons.info, selectedIcon: Icons.info, label: 'foot'),
          ],
        ),
      ),
      size: const Size(300, 600),
    );
    expect(find.text('head'), findsOneWidget);
    await tester.tap(find.text('foot'));
    expect(tapped, 1);
  });

  testWidgets('collapsed side nav shows tooltip icons', (tester) async {
    final state = await testState();
    await pumpPage(
      tester,
      state,
      SizedBox(
        height: 600,
        child: SideNav(
          selectedIndex: 0,
          onSelected: (_) {},
          collapsed: true,
          header: const Text('head'),
          destinations: const [
            (icon: Icons.home, selectedIcon: Icons.home, label: 'a'),
          ],
        ),
      ),
      size: const Size(120, 600),
    );
    expect(find.byType(Tooltip), findsWidgets);
  });

  testWidgets('workflows radio selects directly', (tester) async {
    final state = await testState();
    await state.workflows.add(
      WorkflowDef.tryParse('{"1": {"class_type": "X"}}', name: 'mine')!,
      state.prefs,
    );
    await pumpPage(
      tester,
      state,
      const WorkflowsPage(),
      size: const Size(900, 800),
    );
    await tester.tap(find.byType(Radio<String>).last);
    await tester.pumpAndSettle();
    expect(state.settings.activeWorkflow, 'mine');
  });

  testWidgets('checking state shows spinner text', (tester) async {
    final checker = FakeVersionChecker();
    checker.result = null;
    final state = await testState(versionChecker: checker);
    await pumpPage(
      tester,
      state,
      const SettingsPage(),
      size: const Size(900, 1400),
    );
    checker.gate = Completer<void>();
    await tester.tap(find.byKey(const Key('settings.checkUpdates')));
    await tester.pump();
    expect(find.text('Checking…'), findsOneWidget);
    checker.gate!.complete();
    await tester.pumpAndSettle();
  });
}

class _FailingHistoryApi extends FakeComfyApi {
  @override
  Future<List<ComfyImage>> historyImages(String promptId) =>
      throw Exception('nope');
}
