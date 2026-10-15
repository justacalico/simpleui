import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:simpleui/state/history_store.dart';
import 'package:simpleui/ui/pages/generate_page.dart';

import 'fakes.dart';

void main() {
  testWidgets('prompt + generate submits a job', (tester) async {
    final api = FakeComfyApi();
    final socket = FakeSocket();
    final state = await testState(api: api, socket: socket);
    await pumpPage(
      tester,
      state,
      const GeneratePage(),
      size: const Size(900, 900),
    );

    await tester.enterText(
      find.byKey(const Key('generate.prompt')),
      'a fox in the snow',
    );
    await tester.tap(find.byKey(const Key('generate.submit')));
    await tester.pumpAndSettle();
    expect(api.queued, 1);
    expect(api.lastGraph!['6']['inputs']['text'], 'a fox in the snow');
  });

  testWidgets('failed submit shows a snackbar', (tester) async {
    final api = FakeComfyApi()..queueError = Exception('no server');
    final state = await testState(api: api);
    await pumpPage(
      tester,
      state,
      const GeneratePage(),
      size: const Size(900, 900),
    );
    await tester.tap(find.byKey(const Key('generate.submit')));
    await tester.pumpAndSettle();
    expect(find.byType(SnackBar), findsOneWidget);
    expect(state.generator.jobs.single.status.name, 'failed');
  });

  testWidgets('advanced panel exposes every control', (tester) async {
    final state = await testState();
    await pumpPage(
      tester,
      state,
      const GeneratePage(),
      size: const Size(1000, 1400),
    );
    await tester.tap(find.byKey(const Key('generate.advancedToggle')));
    await tester.pumpAndSettle();

    await tester.enterText(
      find.byKey(const Key('generate.negative')),
      'blurry',
    );
    await tester.enterText(find.byKey(const Key('generate.seed')), '1234');
    await tester.tap(find.byKey(const Key('generate.dice')));
    await tester.pumpAndSettle();
    expect(state.settings.keepSeed, true);

    await tester.tap(find.byKey(const Key('generate.keepSeed')));
    await tester.pumpAndSettle();
    expect(state.settings.keepSeed, false);

    await tester.tap(find.text('3:4'));
    await tester.pumpAndSettle();
    expect(state.settings.params.width, 832);
    expect(state.settings.params.height, 1216);

    await tester.tap(find.byKey(const Key('generate.submit')));
    await tester.pumpAndSettle();
    expect(state.generator.jobs.single.params.negativePrompt, 'blurry');
  });

  testWidgets('dropdowns update params', (tester) async {
    final state = await testState();
    await state.generator.testConnection();
    await pumpPage(
      tester,
      state,
      const GeneratePage(),
      size: const Size(1000, 1400),
    );
    await tester.tap(find.byKey(const Key('generate.advancedToggle')));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('generate.model')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('flux.safetensors').last);
    await tester.pumpAndSettle();
    expect(state.settings.params.model, 'flux.safetensors');

    await tester.tap(find.byKey(const Key('generate.sampler')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('ddim').last);
    await tester.pumpAndSettle();
    expect(state.settings.params.sampler, 'ddim');

    await tester.tap(find.byKey(const Key('generate.scheduler')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('karras').last);
    await tester.pumpAndSettle();
    expect(state.settings.params.scheduler, 'karras');
  });

  testWidgets('sliders update steps cfg and batch', (tester) async {
    final state = await testState();
    await pumpPage(
      tester,
      state,
      const GeneratePage(),
      size: const Size(1000, 1400),
    );
    await tester.tap(find.byKey(const Key('generate.advancedToggle')));
    await tester.pumpAndSettle();

    await tester.drag(find.byType(Slider).first, const Offset(120, 0));
    await tester.pumpAndSettle();
    expect(state.settings.params.steps, isNot(20));

    await tester.drag(find.byType(Slider).at(1), const Offset(-60, 0));
    await tester.pumpAndSettle();
    expect(state.settings.params.cfg, isNot(7.0));

    await tester.drag(
      find.byKey(const Key('generate.batch')),
      const Offset(40, 0),
    );
    await tester.pumpAndSettle();
    expect(state.settings.params.batchSize, greaterThan(1));
  });

  testWidgets('shows running progress and latest result', (tester) async {
    final api = FakeComfyApi();
    final socket = FakeSocket();
    final history = HistoryStore();
    final state = await testState(api: api, socket: socket, history: history);
    await pumpPage(
      tester,
      state,
      const GeneratePage(),
      size: const Size(900, 1000),
    );
    expect(find.textContaining('Nothing here yet'), findsOneWidget);

    await tester.tap(find.byKey(const Key('generate.submit')));
    await tester.pump();
    socket.controller.add(
      '{"type":"executing","data":{"node":"3","prompt_id":"pid-1"}}',
    );
    socket.controller.add('{"type":"progress","data":{"value":10,"max":20}}');
    await tester.pump();
    expect(find.textContaining('50%'), findsOneWidget);
    expect(find.byType(LinearProgressIndicator), findsWidgets);

    socket.controller.add('{"type":"executed","data":{"prompt_id":"pid-1"}}');
    await tester.pumpAndSettle();
    expect(find.text('Latest result'), findsOneWidget);
    expect(history.entries.single.params.prompt, '');
  });

  testWidgets('empty model list keeps current selection', (tester) async {
    final api = FakeComfyApi()..checkpointsList = const [];
    final state = await testState(api: api);
    await pumpPage(
      tester,
      state,
      const GeneratePage(),
      size: const Size(1000, 1400),
    );
    await tester.tap(find.byKey(const Key('generate.advancedToggle')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('generate.model')), findsOneWidget);
  });
}
