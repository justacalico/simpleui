import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:simpleui/services/comfy_ws.dart';

void main() {
  test('parses progress events', () {
    final e = parseComfyMessage(
      jsonEncode({
        'type': 'progress',
        'data': {'value': 5, 'max': 20},
      }),
    );
    expect(e, isA<ProgressEvent>());
    expect((e as ProgressEvent).fraction, 0.25);
  });

  test('progress with zero max stays zero', () {
    final e = parseComfyMessage(
      jsonEncode({
        'type': 'progress',
        'data': {'value': 0, 'max': 0},
      }),
    ) as ProgressEvent;
    expect(e.fraction, 0);
  });

  test('parses executing with and without node', () {
    final e = parseComfyMessage(
      jsonEncode({
        'type': 'executing',
        'data': {'node': '3', 'prompt_id': 'p1'},
      }),
    ) as ExecutingEvent;
    expect(e.promptId, 'p1');
    expect(e.node, '3');

    final done = parseComfyMessage(
      jsonEncode({
        'type': 'executing',
        'data': {'node': null, 'prompt_id': 'p1'},
      }),
    ) as ExecutingEvent;
    expect(done.node, isNull);
  });

  test('parses executed and status', () {
    final e = parseComfyMessage(
      jsonEncode({
        'type': 'executed',
        'data': {'prompt_id': 'p1'},
      }),
    ) as ExecutedEvent;
    expect(e.promptId, 'p1');

    final s = parseComfyMessage(
      jsonEncode({
        'type': 'status',
        'data': {
          'exec_info': {'queue_remaining': 3},
        },
      }),
    ) as StatusEvent;
    expect(s.remaining, 3);
  });

  test('unknown and invalid payloads map to UnknownEvent', () {
    expect((parseComfyMessage(Uint8List(3)) as UnknownEvent).type, 'binary');
    expect((parseComfyMessage('not json') as UnknownEvent).type, 'invalid');
    expect((parseComfyMessage('[1,2]') as UnknownEvent).type, 'invalid');
    expect(
      (parseComfyMessage('{"type":"cry_cached"}') as UnknownEvent).type,
      'cry_cached',
    );
    expect((parseComfyMessage('{}') as UnknownEvent).type, 'unknown');
  });

  test('status without exec_info reports zero', () {
    final s = parseComfyMessage(
      jsonEncode({'type': 'status', 'data': {}}),
    ) as StatusEvent;
    expect(s.remaining, 0);
  });
}
