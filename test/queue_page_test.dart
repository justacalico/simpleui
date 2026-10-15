import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:simpleui/models/comfy.dart';
import 'package:simpleui/ui/pages/queue_page.dart';

import 'fakes.dart';

void main() {
  testWidgets('empty queue shows summary and message', (tester) async {
    final api = FakeComfyApi();
    final state = await testState(api: api);
    await pumpPage(
      tester,
      state,
      const QueuePage(),
      size: const Size(900, 700),
    );
    await tester.pumpAndSettle();
    expect(find.textContaining('1 running'), findsOneWidget);
    expect(find.text('The queue is empty'), findsOneWidget);
  });

  testWidgets('buttons call refresh, interrupt, clear', (tester) async {
    final api = FakeComfyApi();
    final socket = FakeSocket();
    final state = await testState(api: api, socket: socket);
    await pumpPage(
      tester,
      state,
      const QueuePage(),
      size: const Size(900, 700),
    );

    await tester.tap(find.byKey(const Key('queue.refresh')));
    await tester.pump();
    await tester.tap(find.byKey(const Key('queue.interrupt')));
    await tester.pump();
    await tester.tap(find.byKey(const Key('queue.clear')));
    await tester.pumpAndSettle();
    expect(api.interrupted, 1);
    expect(api.cleared, 1);
  });

  testWidgets('jobs render with status labels and progress', (tester) async {
    final api = FakeComfyApi();
    final socket = FakeSocket();
    final state = await testState(api: api, socket: socket);
    await pumpPage(
      tester,
      state,
      const QueuePage(),
      size: const Size(900, 900),
    );

    await state.generator.submit(
      const GenerationParams(prompt: 'running job'),
      WorkflowDef(name: 'w', graph: const {}, builtin: true),
    );
    await tester.pump();
    expect(find.text('running job'), findsOneWidget);
    expect(find.text('Queued'), findsOneWidget);

    socket.controller.add('{"type":"progress","data":{"value":5,"max":10}}');
    await tester.pump();
    expect(find.textContaining('50%'), findsOneWidget);

    socket.controller.add('{"type":"executed","data":{"prompt_id":"pid-1"}}');
    await tester.pumpAndSettle();
    expect(find.text('Done'), findsOneWidget);
    expect(find.text('1 image(s)'), findsOneWidget);

    api.queueError = Exception('boom');
    await state.generator.submit(
      const GenerationParams(),
      WorkflowDef(name: 'w', graph: const {}, builtin: true),
    );
    await tester.pump();
    expect(find.text('Failed'), findsOneWidget);
    expect(find.text('(no prompt)'), findsOneWidget);
    expect(find.textContaining('boom'), findsWidgets);
  });

  testWidgets('interrupted job shows its label', (tester) async {
    final api = FakeComfyApi();
    final state = await testState(api: api);
    await pumpPage(
      tester,
      state,
      const QueuePage(),
      size: const Size(900, 700),
    );
    await state.generator.submit(
      const GenerationParams(prompt: 'stop me'),
      WorkflowDef(name: 'w', graph: const {}, builtin: true),
    );
    await tester.tap(find.byKey(const Key('queue.interrupt')));
    await tester.pumpAndSettle();
    expect(find.text('Interrupted'), findsOneWidget);
  });
}
