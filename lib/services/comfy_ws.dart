import 'dart:convert';

import 'package:web_socket_channel/web_socket_channel.dart';

typedef WsConnector = Stream<dynamic> Function(Uri uri);

// coverage:ignore-start
Stream<dynamic> defaultWsConnector(Uri uri) =>
    WebSocketChannel.connect(uri).stream;
// coverage:ignore-end

sealed class ComfyEvent {}

class ProgressEvent extends ComfyEvent {
  final int value;
  final int max;

  ProgressEvent(this.value, this.max);

  double get fraction => max <= 0 ? 0 : value / max;
}

class ExecutingEvent extends ComfyEvent {
  final String promptId;
  final String? node;

  ExecutingEvent(this.promptId, this.node);
}

class ExecutedEvent extends ComfyEvent {
  final String promptId;

  ExecutedEvent(this.promptId);
}

class StatusEvent extends ComfyEvent {
  final int remaining;

  StatusEvent(this.remaining);
}

class UnknownEvent extends ComfyEvent {
  final String type;

  UnknownEvent(this.type);
}

ComfyEvent parseComfyMessage(dynamic raw) {
  if (raw is! String) return UnknownEvent('binary');
  final Map<String, dynamic> decoded;
  try {
    final d = jsonDecode(raw);
    if (d is! Map<String, dynamic>) return UnknownEvent('invalid');
    decoded = d;
  } catch (_) {
    return UnknownEvent('invalid');
  }
  final data = decoded['data'];
  final map = data is Map<String, dynamic> ? data : const <String, dynamic>{};
  switch (decoded['type']) {
    case 'progress':
      return ProgressEvent(
        (map['value'] as num?)?.toInt() ?? 0,
        (map['max'] as num?)?.toInt() ?? 0,
      );
    case 'executing':
      final node = map['node'];
      return ExecutingEvent(
        '${map['prompt_id'] ?? ''}',
        node is String ? node : null,
      );
    case 'executed':
      return ExecutedEvent('${map['prompt_id'] ?? ''}');
    case 'status':
      final execInfo = map['exec_info'];
      final remaining = execInfo is Map
          ? (execInfo['queue_remaining'] as num?)?.toInt() ?? 0
          : 0;
      return StatusEvent(remaining);
    default:
      return UnknownEvent('${decoded['type'] ?? 'unknown'}');
  }
}
