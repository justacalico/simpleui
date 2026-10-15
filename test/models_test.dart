import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:simpleui/models/comfy.dart';

void main() {
  test('GenerationParams round-trips through json', () {
    const p = GenerationParams(
      prompt: 'p',
      negativePrompt: 'n',
      model: 'm',
      seed: 7,
      steps: 11,
      cfg: 4.5,
      sampler: 'euler_ancestral',
      scheduler: 'karras',
      width: 512,
      height: 768,
      batchSize: 3,
    );
    expect(GenerationParams.fromJson(p.toJson()), p);
    expect(p.hashCode, GenerationParams.fromJson(p.toJson()).hashCode);
  });

  test('GenerationParams defaults and copyWith', () {
    const p = GenerationParams();
    expect(p.seed, -1);
    expect(p.steps, 20);
    final copy = p.copyWith(prompt: 'x', batchSize: 2);
    expect(copy.prompt, 'x');
    expect(copy.batchSize, 2);
    expect(copy.steps, 20);
    expect(GenerationParams.fromJson(const {}), p);
  });

  test('ComfyImage json and equality', () {
    const img = ComfyImage(filename: 'a.png', subfolder: 's', type: 'temp');
    expect(ComfyImage.fromJson(img.toJson()), img);
    expect(img.hashCode, ComfyImage.fromJson(img.toJson()).hashCode);
    const minimal = ComfyImage(filename: 'b.png');
    expect(minimal.subfolder, '');
    expect(ComfyImage.fromJson(const {'filename': 'x'}).type, 'output');
  });

  test('GenerationEntry json round-trip', () {
    final e = GenerationEntry(
      id: 'id1',
      params: const GenerationParams(prompt: 'p'),
      imageKeys: const ['k1', 'k2'],
      createdAt: DateTime.utc(2026, 1, 2, 3, 4),
      workflowName: 'wf',
    );
    final decoded = GenerationEntry.fromJson(e.toJson());
    expect(decoded.id, 'id1');
    expect(decoded.imageKeys, ['k1', 'k2']);
    expect(decoded.createdAt, DateTime.utc(2026, 1, 2, 3, 4));
    expect(decoded.workflowName, 'wf');
  });

  test('GenerationEntry tolerates missing fields', () {
    final e = GenerationEntry.fromJson(const {});
    expect(e.id, '');
    expect(e.imageKeys, isEmpty);
    expect(e.createdAt, DateTime.fromMillisecondsSinceEpoch(0));
  });

  test('decodeList skips non-maps and rejects non-lists', () {
    expect(GenerationEntry.decodeList('[]'), isEmpty);
    expect(GenerationEntry.decodeList('{}'), isEmpty);
    final list = GenerationEntry.decodeList(
      jsonEncode([
        {'id': 'a'},
        'junk',
      ]),
    );
    expect(list.length, 1);
    expect(list.first.id, 'a');
  });

  test('SystemStats parses the comfy payload', () {
    final s = SystemStats.fromJson({
      'system': {'comfyui_version': '0.3', 'python_version': '3.12'},
      'devices': [
        {'name': 'cuda:0', 'vram_total': 8, 'vram_free': 4},
      ],
    });
    expect(s.comfyVersion, '0.3');
    expect(s.deviceName, 'cuda:0');
    expect(s.vramFree, 4);
    expect(SystemStats.fromJson(const {}).deviceName, '');
    expect(SystemStats.fromJson(const {'devices': 'nope'}).vramTotal, 0);
    expect(
      SystemStats.fromJson(const {
        'devices': ['junk'],
      }).deviceName,
      '',
    );
  });

  test('QueueSnapshot counts lists only', () {
    final q = QueueSnapshot.fromJson({
      'queue_running': [1],
      'queue_pending': [1, 2],
    });
    expect(q.running, 1);
    expect(q.pending, 2);
    expect(QueueSnapshot.fromJson(const {}).running, 0);
    expect(QueueSnapshot.fromJson(const {'queue_running': 9}).running, 0);
  });

  group('WorkflowDef', () {
    test('tryParse accepts API-format json', () {
      final w = WorkflowDef.tryParse(
        '{"1": {"class_type": "X", "inputs": {}}}',
        name: 'mine',
      );
      expect(w, isNotNull);
      expect(w!.name, 'mine');
      expect(w.graph['1']['class_type'], 'X');
    });

    test('tryParse rejects ui-format and garbage', () {
      expect(WorkflowDef.tryParse('{"nodes": []}'), isNull);
      expect(WorkflowDef.tryParse('not json'), isNull);
      expect(WorkflowDef.tryParse('{}'), isNull);
      expect(WorkflowDef.tryParse('[1]'), isNull);
      expect(WorkflowDef.tryParse('{"1": {"inputs": {}}}'), isNull);
    });

    test('json round-trip', () {
      final w = WorkflowDef.tryParse('{"1": {"class_type": "X"}}', name: 'n')!;
      final decoded = WorkflowDef.fromJson(w.toJson());
      expect(decoded.name, 'n');
      expect(decoded.graph['1']['class_type'], 'X');
      expect(WorkflowDef.fromJson(const {}).graph, isEmpty);
    });
  });
}
