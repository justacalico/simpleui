import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:simpleui/models/comfy.dart';
import 'package:simpleui/services/image_store.dart';
import 'package:simpleui/state/generate_controller.dart';
import 'package:simpleui/state/history_store.dart';

import 'fakes.dart';

Future<GenerateController> controller(
  FakeComfyApi api,
  FakeSocket socket, {
  ImageStore? images,
  HistoryStore? history,
}) async {
  final state = await testState(
    api: api,
    socket: socket,
    imageStore: images,
    history: history,
  );
  return state.generator;
}

void main() {
  test('submit queues a job and wires the socket once', () async {
    final api = FakeComfyApi();
    final socket = FakeSocket();
    final gen = await controller(api, socket);

    final job = await gen.submit(
      const GenerationParams(prompt: 'a fox'),
      WorkflowDef(name: 'txt2img', graph: const {}, builtin: true),
    );
    expect(job.promptId, 'pid-1');
    expect(job.status, JobStatus.queued);
    expect(gen.activeJob, job);
    expect(socket.opened.single.path, '/ws');
    expect(socket.opened.single.queryParameters['clientId'], 'test-client');
    expect(api.lastGraph!['3']['inputs']['seed'], greaterThanOrEqualTo(0));

    await gen.submit(
      const GenerationParams(prompt: 'again'),
      WorkflowDef(name: 'w', graph: const {}, builtin: true),
    );
    expect(socket.opened.length, 1);
  });

  test('full lifecycle: progress, executed, images, history', () async {
    final api = FakeComfyApi();
    final socket = FakeSocket();
    final history = await HistoryStore.load((await testState()).prefs);
    final images = PrefsImageStore((await testState()).prefs);
    final gen = await controller(api, socket, history: history, images: images);

    final job = await gen.submit(
      const GenerationParams(prompt: 'cat', seed: 7),
      WorkflowDef(name: 'w', graph: const {}, builtin: true),
    );
    socket.controller.add(
      jsonEncode({
        'type': 'executing',
        'data': {'node': '3', 'prompt_id': job.promptId},
      }),
    );
    socket.controller.add(
      jsonEncode({
        'type': 'progress',
        'data': {'value': 10, 'max': 20},
      }),
    );
    await Future<void>.delayed(Duration.zero);
    expect(job.status, JobStatus.running);
    expect(job.progress, 0.5);

    socket.controller.add(
      jsonEncode({
        'type': 'executed',
        'data': {'prompt_id': job.promptId},
      }),
    );
    await Future<void>.delayed(Duration.zero);
    await Future<void>.delayed(Duration.zero);
    expect(job.status, JobStatus.done);
    expect(job.imageKeys.single, contains(job.promptId));
    expect(history.entries.single.params.prompt, 'cat');
    expect(await images.read(job.imageKeys.single), isNotNull);
    expect(job.params.seed, 7);
  });

  test('status event with empty queue completes running jobs', () async {
    final api = FakeComfyApi()
      ..queueSnapshot = const QueueSnapshot(running: 0, pending: 0);
    final socket = FakeSocket();
    final gen = await controller(api, socket);
    final job = await gen.submit(
      const GenerationParams(prompt: 'x'),
      WorkflowDef(name: 'w', graph: const {}, builtin: true),
    );
    socket.controller.add(
      jsonEncode({
        'type': 'executing',
        'data': {'node': '3', 'prompt_id': job.promptId},
      }),
    );
    await Future<void>.delayed(Duration.zero);
    socket.controller.add(
      jsonEncode({
        'type': 'status',
        'data': {
          'exec_info': {'queue_remaining': 0},
        },
      }),
    );
    await Future<void>.delayed(Duration.zero);
    await Future<void>.delayed(Duration.zero);
    expect(job.status, JobStatus.done);
    expect(gen.queueSnapshot.pending, 0);
  });

  test('queuePrompt failure records a failed job', () async {
    final api = FakeComfyApi()..queueError = Exception('offline');
    final gen = await controller(api, FakeSocket());
    final job = await gen.submit(
      const GenerationParams(prompt: 'x'),
      WorkflowDef(name: 'w', graph: const {}, builtin: true),
    );
    expect(job.status, JobStatus.failed);
    expect(job.error, contains('offline'));
    expect(gen.activeJob, isNull);
  });

  test('completion failure marks the job failed', () async {
    final api = FakeComfyApi()..imagesResult = const [];
    final socket = FakeSocket();
    final gen = await controller(api, socket);
    final job = await gen.submit(
      const GenerationParams(prompt: 'x'),
      WorkflowDef(name: 'w', graph: const {}, builtin: true),
    );
    api.queueError = null;
    socket.controller.add(
      jsonEncode({
        'type': 'executed',
        'data': {'prompt_id': job.promptId},
      }),
    );
    await Future<void>.delayed(Duration.zero);
    await Future<void>.delayed(Duration.zero);
    expect(job.status, JobStatus.done);
    expect(job.imageKeys, isEmpty);
  });

  test('interrupt and clearQueue call the api', () async {
    final api = FakeComfyApi();
    final gen = await controller(api, FakeSocket());
    final job = await gen.submit(
      const GenerationParams(prompt: 'x'),
      WorkflowDef(name: 'w', graph: const {}, builtin: true),
    );
    await gen.interrupt();
    expect(api.interrupted, 1);
    expect(job.status, JobStatus.interrupted);
    await gen.interrupt();
    await gen.clearQueue();
    expect(api.cleared, 1);
    expect(gen.queueSnapshot.running, 1);
  });

  test('api errors on queue/interrupt are swallowed', () async {
    final api = FakeComfyApi();
    final gen = await controller(api, FakeSocket());
    final throwing = _ThrowingComfyApi();
    final gen2 = GenerateController(
      api: () => throwing,
      connect: (uri) => const Stream.empty(),
      images: PrefsImageStore((await testState()).prefs),
      history: HistoryStore(),
      prefs: (await testState()).prefs,
    );
    await gen2.refreshQueue();
    await gen2.interrupt();
    await gen2.clearQueue();
    await gen.testConnection();
    expect(gen.stats, isNotNull);
  });

  test('testConnection failure records the error', () async {
    final api = FakeComfyApi()..statsError = Exception('nope');
    final gen = await controller(api, FakeSocket());
    await gen.testConnection();
    expect(gen.stats, isNull);
    expect(gen.serverError, isNotNull);
    // second call allowed again
    api.statsError = null;
    await gen.testConnection();
    expect(gen.stats, isNotNull);
    expect(gen.models, contains('flux.safetensors'));
  });

  test('concurrent testConnection calls de-dupe', () async {
    final api = FakeComfyApi();
    final gen = await controller(api, FakeSocket());
    final a = gen.testConnection();
    final b = gen.testConnection();
    await Future.wait([a, b]);
    expect(gen.stats, isNotNull);
  });

  test('custom workflow graphs get params applied', () async {
    final api = FakeComfyApi();
    final gen = await controller(api, FakeSocket());
    final custom = WorkflowDef.tryParse(
      jsonEncode({
        '1': {
          'class_type': 'KSampler',
          'inputs': {'seed': 0, 'steps': 1},
        },
      }),
      name: 'c',
    )!;
    final job = await gen.submit(
      const GenerationParams(prompt: 'p', steps: 33),
      custom,
    );
    expect(api.lastGraph!['1']['inputs']['steps'], 33);
    expect(job.workflowName, 'c');
  });

  test('keepSeed negative seed draws a random one', () async {
    final api = FakeComfyApi();
    final gen = await controller(api, FakeSocket());
    final a = await gen.submit(
      const GenerationParams(seed: -1),
      WorkflowDef(name: 'w', graph: const {}, builtin: true),
    );
    final b = await gen.submit(
      const GenerationParams(seed: -1),
      WorkflowDef(name: 'w', graph: const {}, builtin: true),
    );
    expect(a.params.seed, greaterThanOrEqualTo(0));
    expect(a.params.seed, isNot(b.params.seed));
  });

  test('imageBytes reads through the store', () async {
    final images = PrefsImageStore((await testState()).prefs);
    final gen = await controller(FakeComfyApi(), FakeSocket(), images: images);
    await images.save('k', testPng);
    expect(await gen.imageBytes('k'), testPng);
  });

  test('socket errors do not crash the controller', () async {
    final socket = FakeSocket();
    final gen = await controller(FakeComfyApi(), socket);
    await gen.submit(
      const GenerationParams(prompt: 'x'),
      WorkflowDef(name: 'w', graph: const {}, builtin: true),
    );
    socket.controller.addError(Exception('ws died'));
    socket.controller.add('{"type":"nope"}');
    await Future<void>.delayed(Duration.zero);
    expect(gen.jobs, isNotEmpty);
    gen.dispose();
  });
}

class _ThrowingComfyApi extends FakeComfyApi {
  @override
  Future<QueueSnapshot> queue() async => throw Exception('down');

  @override
  Future<void> interrupt() async => throw Exception('down');

  @override
  Future<void> clearQueue() async => throw Exception('down');
}
