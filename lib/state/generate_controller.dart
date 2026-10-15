import 'dart:async';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/comfy.dart';
import '../services/comfy_api.dart';
import '../services/comfy_ws.dart';
import '../services/image_store.dart';
import '../services/workflow_builder.dart';
import 'history_store.dart';

enum JobStatus { queued, running, done, failed, interrupted }

class GenerateJob {
  final String id;
  final String promptId;
  final GenerationParams params;
  final String workflowName;

  JobStatus status;
  double progress;
  String? error;
  List<String> imageKeys;
  bool completing;

  GenerateJob({
    required this.id,
    required this.promptId,
    required this.params,
    required this.workflowName,
    this.status = JobStatus.queued,
    this.progress = 0,
    this.error,
    this.imageKeys = const [],
    this.completing = false,
  });
}

class GenerateController extends ChangeNotifier {
  final ComfyApi Function() api;
  final WsConnector connect;
  final ImageStore images;
  final HistoryStore history;
  final SharedPreferences prefs;
  final Random _random;
  final String clientId;

  final List<GenerateJob> _jobs = [];
  StreamSubscription<dynamic>? _socket;
  Uri? _socketUri;
  int _seedCounter = 0;
  bool _checkingServer = false;
  SystemStats? _stats;
  Object? _serverError;
  List<String> _models = const [];
  QueueSnapshot _queue = const QueueSnapshot();

  GenerateController({
    required this.api,
    required this.connect,
    required this.images,
    required this.history,
    required this.prefs,
    Random? random,
    String? clientId,
  }) : _random = random ?? Random(),
       clientId = clientId ?? 'simpleui-${Random().nextInt(1 << 32)}';

  List<GenerateJob> get jobs => List.unmodifiable(_jobs);

  GenerateJob? get activeJob {
    for (final job in _jobs.reversed) {
      if (job.status == JobStatus.queued || job.status == JobStatus.running) {
        return job;
      }
    }
    return null;
  }

  bool get checkingServer => _checkingServer;
  SystemStats? get stats => _stats;
  Object? get serverError => _serverError;
  List<String> get models => _models;
  QueueSnapshot get queueSnapshot => _queue;

  int nextSeed() => _random.nextInt(1 << 31) + _seedCounter++;

  Future<void> testConnection() async {
    if (_checkingServer) return;
    _checkingServer = true;
    _serverError = null;
    notifyListeners();
    try {
      _stats = await api().systemStats();
      _models = await api().checkpoints();
    } catch (e) {
      _stats = null;
      _serverError = e;
    } finally {
      _checkingServer = false;
      notifyListeners();
    }
  }

  Future<void> refreshQueue() async {
    try {
      _queue = await api().queue();
      notifyListeners();
    } catch (_) {}
  }

  Future<void> interrupt() async {
    final job = activeJob;
    if (job != null) {
      job.status = JobStatus.interrupted;
      notifyListeners();
    }
    try {
      await api().interrupt();
    } catch (_) {}
    await refreshQueue();
  }

  Future<void> clearQueue() async {
    try {
      await api().clearQueue();
    } catch (_) {}
    await refreshQueue();
  }

  Future<GenerateJob> submit(
    GenerationParams params,
    WorkflowDef workflow,
  ) async {
    final seed = params.seed < 0 ? nextSeed() : params.seed;
    final effective = params.copyWith(seed: seed);
    final graph = workflow.builtin
        ? txt2imgGraph(effective)
        : applyParams(workflow.graph, effective);
    try {
      final promptId = await api().queuePrompt(graph, clientId);
      final job = GenerateJob(
        id: promptId,
        promptId: promptId,
        params: effective,
        workflowName: workflow.name,
      );
      _jobs.add(job);
      notifyListeners();
      _openSocket();
      unawaited(refreshQueue());
      return job;
    } catch (e) {
      final job = GenerateJob(
        id: 'local-${_jobs.length}',
        promptId: '',
        params: effective,
        workflowName: workflow.name,
        status: JobStatus.failed,
        error: '$e',
      );
      _jobs.add(job);
      notifyListeners();
      return job;
    }
  }

  void _openSocket() {
    final uri = wsUriFor(api().baseUri, clientId);
    if (_socketUri == uri && _socket != null) return;
    _socketUri = uri;
    unawaited(_socket?.cancel());
    _socket = connect(uri).listen(_onEvent, onError: (_) {});
  }

  bool jobFinished(GenerateJob job) =>
      job.status == JobStatus.done ||
      job.status == JobStatus.failed ||
      job.status == JobStatus.interrupted;

  void _onEvent(dynamic raw) {
    final event = parseComfyMessage(raw);
    switch (event) {
      case ProgressEvent(:final fraction):
        final job = activeJob;
        if (job != null) {
          job.status = JobStatus.running;
          job.progress = fraction;
          notifyListeners();
        }
      case ExecutingEvent(:final promptId):
        for (final job in _jobs) {
          if (job.promptId == promptId) {
            job.status = JobStatus.running;
            notifyListeners();
          }
        }
      case ExecutedEvent(:final promptId):
        for (final job in _jobs) {
          if (job.promptId == promptId && !jobFinished(job)) {
            unawaited(_complete(job));
          }
        }
      case StatusEvent(:final remaining):
        _queue = QueueSnapshot(running: _queue.running, pending: remaining);
        if (remaining == 0) {
          for (final job in _jobs) {
            if (job.status == JobStatus.running) unawaited(_complete(job));
          }
        }
        notifyListeners();
      case UnknownEvent():
        break;
    }
  }

  Future<void> _complete(GenerateJob job) async {
    if (job.completing) return;
    job.completing = true;
    try {
      final outputs = await api().historyImages(job.promptId);
      final keys = <String>[];
      for (final image in outputs) {
        final bytes = await api().image(image);
        final key = '${job.id}-${image.filename}';
        await images.save(key, bytes);
        keys.add(key);
      }
      job.imageKeys = keys;
      job.status = JobStatus.done;
      job.progress = 1;
      await history.add(
        GenerationEntry(
          id: job.id,
          params: job.params,
          imageKeys: keys,
          createdAt: DateTime.now(),
          workflowName: job.workflowName,
        ),
        prefs,
      );
    } catch (e) {
      job.status = JobStatus.failed;
      job.error = '$e';
    }
    notifyListeners();
    unawaited(refreshQueue());
  }

  Future<Uint8List?> imageBytes(String key) => images.read(key);

  @override
  void dispose() {
    unawaited(_socket?.cancel());
    super.dispose();
  }
}
