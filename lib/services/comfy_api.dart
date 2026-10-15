import 'dart:convert';
import 'dart:typed_data';

import 'package:http/http.dart' as http;

import '../models/comfy.dart';

class ComfyApiException implements Exception {
  final String message;

  const ComfyApiException(this.message);

  @override
  String toString() => 'ComfyApiException: $message';
}

abstract class ComfyApi {
  Uri get baseUri;
  Future<SystemStats> systemStats();
  Future<List<String>> checkpoints();
  Future<String> queuePrompt(Map<String, dynamic> graph, String clientId);
  Future<List<ComfyImage>> historyImages(String promptId);
  Future<QueueSnapshot> queue();
  Future<Uint8List> image(ComfyImage image);
  Future<void> interrupt();
  Future<void> clearQueue();
}

class HttpComfyApi implements ComfyApi {
  @override
  final Uri baseUri;
  final http.Client client;

  HttpComfyApi(this.baseUri, {http.Client? client})
    : client = client ?? http.Client();

  Uri _u(String path, [Map<String, String>? query]) =>
      baseUri.replace(path: '${baseUri.path}$path', queryParameters: query);

  Future<http.Response> _get(Uri uri) async {
    final http.Response response;
    try {
      response = await client
          .get(uri, headers: {'Accept': 'application/json'})
          .timeout(const Duration(seconds: 15));
    } catch (e) {
      throw ComfyApiException('$e');
    }
    if (response.statusCode != 200) {
      throw ComfyApiException('HTTP ${response.statusCode}');
    }
    return response;
  }

  Future<http.Response> _post(Uri uri, Object body) async {
    final http.Response response;
    try {
      response = await client
          .post(
            uri,
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode(body),
          )
          .timeout(const Duration(seconds: 15));
    } catch (e) {
      throw ComfyApiException('$e');
    }
    if (response.statusCode != 200) {
      throw ComfyApiException('HTTP ${response.statusCode}');
    }
    return response;
  }

  @override
  Future<SystemStats> systemStats() async {
    final response = await _get(_u('/system_stats'));
    final decoded = jsonDecode(response.body);
    if (decoded is! Map<String, dynamic>) {
      throw const ComfyApiException('unexpected response shape');
    }
    return SystemStats.fromJson(decoded);
  }

  @override
  Future<List<String>> checkpoints() async {
    final response = await _get(_u('/models/checkpoints'));
    final decoded = jsonDecode(response.body);
    if (decoded is! List) {
      throw const ComfyApiException('unexpected response shape');
    }
    return [for (final m in decoded) '$m']..sort();
  }

  @override
  Future<String> queuePrompt(
    Map<String, dynamic> graph,
    String clientId,
  ) async {
    final response = await _post(_u('/prompt'), {
      'prompt': graph,
      'client_id': clientId,
    });
    final decoded = jsonDecode(response.body);
    if (decoded is! Map<String, dynamic> || decoded['prompt_id'] is! String) {
      throw const ComfyApiException('unexpected response shape');
    }
    return decoded['prompt_id'] as String;
  }

  @override
  Future<List<ComfyImage>> historyImages(String promptId) async {
    final response = await _get(_u('/history/$promptId'));
    final decoded = jsonDecode(response.body);
    if (decoded is! Map<String, dynamic>) {
      throw const ComfyApiException('unexpected response shape');
    }
    final prompt = decoded[promptId];
    if (prompt is! Map<String, dynamic>) return const [];
    final outputs = prompt['outputs'];
    if (outputs is! Map<String, dynamic>) return const [];
    final images = <ComfyImage>[];
    for (final node in outputs.values) {
      if (node is! Map<String, dynamic>) continue;
      final list = node['images'];
      if (list is! List) continue;
      for (final img in list) {
        if (img is Map<String, dynamic>) images.add(ComfyImage.fromJson(img));
      }
    }
    return images;
  }

  @override
  Future<QueueSnapshot> queue() async {
    final response = await _get(_u('/queue'));
    final decoded = jsonDecode(response.body);
    if (decoded is! Map<String, dynamic>) {
      throw const ComfyApiException('unexpected response shape');
    }
    return QueueSnapshot.fromJson(decoded);
  }

  @override
  Future<Uint8List> image(ComfyImage image) async {
    final response = await _get(
      _u('/view', {
        'filename': image.filename,
        'subfolder': image.subfolder,
        'type': image.type,
      }),
    );
    return response.bodyBytes;
  }

  @override
  Future<void> interrupt() => _post(_u('/interrupt'), {}).then((_) {});

  @override
  Future<void> clearQueue() =>
      _post(_u('/queue'), {'clear': true}).then((_) {});
}

Uri? parseServerUri(String raw) {
  final trimmed = raw.trim();
  if (trimmed.isEmpty) return null;
  final withScheme = trimmed.contains('://') ? trimmed : 'http://$trimmed';
  final uri = Uri.tryParse(withScheme);
  if (uri == null || uri.host.isEmpty) return null;
  if (uri.scheme != 'http' && uri.scheme != 'https') return null;
  return uri;
}

Uri wsUriFor(Uri httpUri, String clientId) => httpUri.replace(
  scheme: httpUri.scheme == 'https' ? 'wss' : 'ws',
  path: '${httpUri.path}/ws',
  queryParameters: {'clientId': clientId},
);
