import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:simpleui/models/comfy.dart';
import 'package:simpleui/services/comfy_api.dart';

import 'fakes.dart';

void main() {
  final base = Uri.parse('http://127.0.0.1:8188');

  group('parseServerUri', () {
    test('accepts bare host and full urls', () {
      expect(parseServerUri('127.0.0.1:8188')!.host, '127.0.0.1');
      expect(parseServerUri('https://gpu.lan:8188')!.scheme, 'https');
      expect(parseServerUri(''), isNull);
      expect(parseServerUri('   '), isNull);
      expect(parseServerUri('ftp://x'), isNull);
    });
  });

  test('wsUriFor maps schemes and adds clientId', () {
    expect(
      wsUriFor(Uri.parse('http://h:8188'), 'c1').toString(),
      'ws://h:8188/ws?clientId=c1',
    );
    expect(wsUriFor(Uri.parse('https://h'), 'c2').scheme, 'wss');
  });

  group('HttpComfyApi', () {
    test('systemStats parses device info', () async {
      final api = HttpComfyApi(
        base,
        client: mockHttp({
          'GET /system_stats': (_) => http.Response(
            jsonEncode({
              'system': {
                'comfyui_version': '0.3.1',
                'python_version': '3.12.1',
              },
              'devices': [
                {'name': 'cuda:0', 'vram_total': 16000, 'vram_free': 8000},
              ],
            }),
            200,
          ),
        }),
      );
      final stats = await api.systemStats();
      expect(stats.comfyVersion, '0.3.1');
      expect(stats.deviceName, 'cuda:0');
      expect(stats.vramTotal, 16000);
      expect(stats.vramFree, 8000);
    });

    test('systemStats tolerates missing fields', () async {
      final api = HttpComfyApi(
        base,
        client: mockHttp({
          'GET /system_stats': (_) => http.Response('{}', 200),
        }),
      );
      final stats = await api.systemStats();
      expect(stats.comfyVersion, '');
      expect(stats.deviceName, '');
    });

    test('systemStats rejects non-map responses', () async {
      final api = HttpComfyApi(
        base,
        client: mockHttp({
          'GET /system_stats': (_) => http.Response('[]', 200),
        }),
      );
      expect(api.systemStats, throwsA(isA<ComfyApiException>()));
    });

    test('checkpoints sorts model names', () async {
      final api = HttpComfyApi(
        base,
        client: mockHttp({
          'GET /models/checkpoints': (_) =>
              http.Response('["b.safetensors","a.safetensors"]', 200),
        }),
      );
      expect(await api.checkpoints(), ['a.safetensors', 'b.safetensors']);
    });

    test('checkpoints rejects non-list responses', () async {
      final api = HttpComfyApi(
        base,
        client: mockHttp({
          'GET /models/checkpoints': (_) => http.Response('{}', 200),
        }),
      );
      expect(api.checkpoints, throwsA(isA<ComfyApiException>()));
    });

    test('queuePrompt posts the graph and returns the id', () async {
      http.Response handler(Uri uri) =>
          http.Response(jsonEncode({'prompt_id': 'abc', 'number': 1}), 200);
      final api = HttpComfyApi(
        base,
        client: MockClient((request) async {
          expect(request.method, 'POST');
          expect(request.url.path, '/prompt');
          final body = jsonDecode(request.body);
          expect(body['client_id'], 'cid');
          expect(body['prompt']['1']['class_type'], 'X');
          return handler(request.url);
        }),
      );
      expect(
        await api.queuePrompt({
          '1': {'class_type': 'X'},
        }, 'cid'),
        'abc',
      );
    });

    test('queuePrompt rejects malformed responses', () async {
      final api = HttpComfyApi(
        base,
        client: mockHttp({'POST /prompt': (_) => http.Response('{}', 200)}),
      );
      expect(api.queuePrompt({}, 'c'), throwsA(isA<ComfyApiException>()));
    });

    test('historyImages collects node outputs', () async {
      final api = HttpComfyApi(
        base,
        client: mockHttp({
          'GET /history/p1': (_) => http.Response(
            jsonEncode({
              'p1': {
                'outputs': {
                  '9': {
                    'images': [
                      {'filename': 'a.png', 'subfolder': '', 'type': 'output'},
                      {'filename': 'b.png', 'type': 'temp'},
                    ],
                  },
                  '10': {'other': true},
                },
              },
            }),
            200,
          ),
        }),
      );
      final images = await api.historyImages('p1');
      expect(images.length, 2);
      expect(images[0].filename, 'a.png');
      expect(images[1].type, 'temp');
    });

    test('historyImages handles missing prompt and outputs', () async {
      final api = HttpComfyApi(
        base,
        client: mockHttp({
          'GET /history/p1': (_) => http.Response(jsonEncode({'p1': {}}), 200),
          'GET /history/p2': (_) =>
              http.Response(jsonEncode({'other': {}}), 200),
          'GET /history/bad': (_) => http.Response('[]', 200),
        }),
      );
      expect(await api.historyImages('p1'), isEmpty);
      expect(await api.historyImages('p2'), isEmpty);
      expect(api.historyImages('bad'), throwsA(isA<ComfyApiException>()));
    });

    test('queue parses running and pending', () async {
      final api = HttpComfyApi(
        base,
        client: mockHttp({
          'GET /queue': (_) => http.Response(
            jsonEncode({
              'queue_running': [1, 2],
              'queue_pending': [3],
            }),
            200,
          ),
        }),
      );
      final q = await api.queue();
      expect(q.running, 2);
      expect(q.pending, 1);
    });

    test('queue rejects non-map responses', () async {
      final api = HttpComfyApi(
        base,
        client: mockHttp({'GET /queue': (_) => http.Response('[]', 200)}),
      );
      expect(api.queue, throwsA(isA<ComfyApiException>()));
    });

    test('image returns bytes with query params', () async {
      final api = HttpComfyApi(
        base,
        client: MockClient((request) async {
          expect(request.url.path, '/view');
          expect(request.url.queryParameters['filename'], 'x.png');
          expect(request.url.queryParameters['subfolder'], 'sub');
          expect(request.url.queryParameters['type'], 'temp');
          return http.Response.bytes(testPng, 200);
        }),
      );
      final bytes = await api.image(
        const ComfyImage(filename: 'x.png', subfolder: 'sub', type: 'temp'),
      );
      expect(bytes, testPng);
    });

    test('interrupt and clearQueue post', () async {
      var posts = 0;
      final api = HttpComfyApi(
        base,
        client: MockClient((request) async {
          posts++;
          expect(request.method, 'POST');
          return http.Response('{}', 200);
        }),
      );
      await api.interrupt();
      await api.clearQueue();
      expect(posts, 2);
    });

    test('non-200 responses raise', () async {
      final api = HttpComfyApi(
        base,
        client: MockClient((_) async => http.Response('nope', 500)),
      );
      expect(api.systemStats, throwsA(isA<ComfyApiException>()));
      expect(api.queue, throwsA(isA<ComfyApiException>()));
      expect(api.interrupt, throwsA(isA<ComfyApiException>()));
      expect(
        api.image(const ComfyImage(filename: 'x')),
        throwsA(isA<ComfyApiException>()),
      );
    });

    test('client errors are wrapped', () async {
      final api = HttpComfyApi(
        base,
        client: MockClient((_) async => throw Exception('offline')),
      );
      expect(api.systemStats, throwsA(isA<ComfyApiException>()));
      expect(api.interrupt, throwsA(isA<ComfyApiException>()));
    });

    test('ComfyApiException prints message', () {
      expect(
        const ComfyApiException('boom').toString(),
        'ComfyApiException: boom',
      );
    });
  });
}
