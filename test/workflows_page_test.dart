import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:simpleui/models/comfy.dart';
import 'package:simpleui/ui/pages/workflows_page.dart';

import 'fakes.dart';

void main() {
  testWidgets('lists builtin and selects active workflow', (tester) async {
    final state = await testState();
    await pumpPage(
      tester,
      state,
      const WorkflowsPage(),
      size: const Size(900, 800),
    );
    expect(find.text('Text to image'), findsOneWidget);

    final wf = WorkflowDef.tryParse(
      '{"1": {"class_type": "X"}}',
      name: 'mine',
    )!;
    await state.workflows.add(wf, state.prefs);
    await tester.pumpAndSettle();
    expect(find.text('mine'), findsOneWidget);
    expect(find.text('1 nodes'), findsOneWidget);

    await tester.tap(find.text('mine'));
    await tester.pumpAndSettle();
    expect(state.settings.activeWorkflow, 'mine');
  });

  testWidgets('import dialog adds a pasted workflow', (tester) async {
    final state = await testState();
    await pumpPage(
      tester,
      state,
      const WorkflowsPage(),
      size: const Size(900, 900),
    );
    await tester.tap(find.byKey(const Key('workflows.import')));
    await tester.pumpAndSettle();

    await tester.enterText(find.byKey(const Key('workflow.name')), 'upscale');
    await tester.enterText(
      find.byKey(const Key('workflow.json')),
      '{"n": {"class_type": "KSampler", "inputs": {}}}',
    );
    await tester.tap(find.byKey(const Key('workflow.save')));
    await tester.pumpAndSettle();
    expect(state.workflows.custom.single.name, 'upscale');
    expect(find.byType(SnackBar), findsOneWidget);
  });

  testWidgets('invalid json shows an error snackbar', (tester) async {
    final state = await testState();
    await pumpPage(
      tester,
      state,
      const WorkflowsPage(),
      size: const Size(900, 900),
    );
    await tester.tap(find.byKey(const Key('workflows.import')));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(const Key('workflow.json')),
      'not a workflow',
    );
    await tester.tap(find.byKey(const Key('workflow.save')));
    await tester.pumpAndSettle();
    expect(state.workflows.custom, isEmpty);
    expect(find.textContaining('API-format'), findsWidgets);
  });

  testWidgets('cancel closes without importing', (tester) async {
    final state = await testState();
    await pumpPage(
      tester,
      state,
      const WorkflowsPage(),
      size: const Size(900, 900),
    );
    await tester.tap(find.byKey(const Key('workflows.import')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
    expect(state.workflows.custom, isEmpty);
  });

  testWidgets('file picker fills the json field', (tester) async {
    final state = await testState(
      pickWorkflowFile: () async => '{"f": {"class_type": "Y"}}',
    );
    await pumpPage(
      tester,
      state,
      const WorkflowsPage(),
      size: const Size(900, 900),
    );
    await tester.tap(find.byKey(const Key('workflows.import')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('workflow.pickFile')));
    await tester.pumpAndSettle();
    expect(
      tester
          .widget<TextField>(find.byKey(const Key('workflow.json')))
          .controller!
          .text,
      '{"f": {"class_type": "Y"}}',
    );
    await tester.tap(find.byKey(const Key('workflow.save')));
    await tester.pumpAndSettle();
    expect(state.workflows.custom.single.name, 'custom');
  });

  testWidgets('file picker null keeps the field', (tester) async {
    final state = await testState(pickWorkflowFile: () async => null);
    await pumpPage(
      tester,
      state,
      const WorkflowsPage(),
      size: const Size(900, 900),
    );
    await tester.tap(find.byKey(const Key('workflows.import')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('workflow.pickFile')));
    await tester.pumpAndSettle();
    expect(
      tester
          .widget<TextField>(find.byKey(const Key('workflow.json')))
          .controller!
          .text,
      '',
    );
  });

  testWidgets('delete removes a custom workflow', (tester) async {
    final state = await testState();
    await state.workflows.add(
      WorkflowDef.tryParse('{"1": {"class_type": "X"}}', name: 'doomed')!,
      state.prefs,
    );
    await pumpPage(
      tester,
      state,
      const WorkflowsPage(),
      size: const Size(900, 800),
    );
    await tester.tap(find.byKey(const Key('workflow.delete.doomed')));
    await tester.pumpAndSettle();
    expect(state.workflows.custom, isEmpty);
  });
}
