import 'dart:convert';

class GenerationParams {
  final String prompt;
  final String negativePrompt;
  final String model;
  final int seed;
  final int steps;
  final double cfg;
  final String sampler;
  final String scheduler;
  final int width;
  final int height;
  final int batchSize;

  const GenerationParams({
    this.prompt = '',
    this.negativePrompt = '',
    this.model = '',
    this.seed = -1,
    this.steps = 20,
    this.cfg = 7.0,
    this.sampler = 'euler',
    this.scheduler = 'normal',
    this.width = 1024,
    this.height = 1024,
    this.batchSize = 1,
  });

  GenerationParams copyWith({
    String? prompt,
    String? negativePrompt,
    String? model,
    int? seed,
    int? steps,
    double? cfg,
    String? sampler,
    String? scheduler,
    int? width,
    int? height,
    int? batchSize,
  }) {
    return GenerationParams(
      prompt: prompt ?? this.prompt,
      negativePrompt: negativePrompt ?? this.negativePrompt,
      model: model ?? this.model,
      seed: seed ?? this.seed,
      steps: steps ?? this.steps,
      cfg: cfg ?? this.cfg,
      sampler: sampler ?? this.sampler,
      scheduler: scheduler ?? this.scheduler,
      width: width ?? this.width,
      height: height ?? this.height,
      batchSize: batchSize ?? this.batchSize,
    );
  }

  Map<String, dynamic> toJson() => {
    'prompt': prompt,
    'negativePrompt': negativePrompt,
    'model': model,
    'seed': seed,
    'steps': steps,
    'cfg': cfg,
    'sampler': sampler,
    'scheduler': scheduler,
    'width': width,
    'height': height,
    'batchSize': batchSize,
  };

  static GenerationParams fromJson(Map<String, dynamic> json) =>
      GenerationParams(
        prompt: json['prompt'] as String? ?? '',
        negativePrompt: json['negativePrompt'] as String? ?? '',
        model: json['model'] as String? ?? '',
        seed: json['seed'] as int? ?? -1,
        steps: json['steps'] as int? ?? 20,
        cfg: (json['cfg'] as num?)?.toDouble() ?? 7.0,
        sampler: json['sampler'] as String? ?? 'euler',
        scheduler: json['scheduler'] as String? ?? 'normal',
        width: json['width'] as int? ?? 1024,
        height: json['height'] as int? ?? 1024,
        batchSize: json['batchSize'] as int? ?? 1,
      );

  @override
  bool operator ==(Object other) =>
      other is GenerationParams &&
      other.prompt == prompt &&
      other.negativePrompt == negativePrompt &&
      other.model == model &&
      other.seed == seed &&
      other.steps == steps &&
      other.cfg == cfg &&
      other.sampler == sampler &&
      other.scheduler == scheduler &&
      other.width == width &&
      other.height == height &&
      other.batchSize == batchSize;

  @override
  int get hashCode => Object.hash(
    prompt,
    negativePrompt,
    model,
    seed,
    steps,
    cfg,
    sampler,
    scheduler,
    width,
    height,
    batchSize,
  );
}

class ComfyImage {
  final String filename;
  final String subfolder;
  final String type;

  const ComfyImage({
    required this.filename,
    this.subfolder = '',
    this.type = 'output',
  });

  static ComfyImage fromJson(Map<String, dynamic> json) => ComfyImage(
    filename: json['filename'] as String? ?? '',
    subfolder: json['subfolder'] as String? ?? '',
    type: json['type'] as String? ?? 'output',
  );

  Map<String, dynamic> toJson() => {
    'filename': filename,
    'subfolder': subfolder,
    'type': type,
  };

  @override
  bool operator ==(Object other) =>
      other is ComfyImage &&
      other.filename == filename &&
      other.subfolder == subfolder &&
      other.type == type;

  @override
  int get hashCode => Object.hash(filename, subfolder, type);
}

class GenerationEntry {
  final String id;
  final GenerationParams params;
  final List<String> imageKeys;
  final DateTime createdAt;
  final String workflowName;

  const GenerationEntry({
    required this.id,
    required this.params,
    required this.imageKeys,
    required this.createdAt,
    this.workflowName = '',
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'params': params.toJson(),
    'imageKeys': imageKeys,
    'createdAt': createdAt.toIso8601String(),
    'workflowName': workflowName,
  };

  static GenerationEntry fromJson(Map<String, dynamic> json) => GenerationEntry(
    id: json['id'] as String? ?? '',
    params: json['params'] is Map<String, dynamic>
        ? GenerationParams.fromJson(json['params'] as Map<String, dynamic>)
        : const GenerationParams(),
    imageKeys: [for (final k in json['imageKeys'] as List? ?? const []) '$k'],
    createdAt:
        DateTime.tryParse(json['createdAt'] as String? ?? '') ??
        DateTime.fromMillisecondsSinceEpoch(0),
    workflowName: json['workflowName'] as String? ?? '',
  );

  static List<GenerationEntry> decodeList(String raw) {
    final decoded = jsonDecode(raw);
    if (decoded is! List) return const [];
    return [
      for (final e in decoded)
        if (e is Map<String, dynamic>) GenerationEntry.fromJson(e),
    ];
  }
}

class SystemStats {
  final String comfyVersion;
  final String pythonVersion;
  final String deviceName;
  final int vramTotal;
  final int vramFree;

  const SystemStats({
    this.comfyVersion = '',
    this.pythonVersion = '',
    this.deviceName = '',
    this.vramTotal = 0,
    this.vramFree = 0,
  });

  static SystemStats fromJson(Map<String, dynamic> json) {
    final system = json['system'];
    final devices = json['devices'];
    final first = devices is List && devices.isNotEmpty
        ? devices.first
        : const <String, dynamic>{};
    final device = first is Map<String, dynamic> ? first : const {};
    return SystemStats(
      comfyVersion: system is Map ? '${system['comfyui_version'] ?? ''}' : '',
      pythonVersion: system is Map ? '${system['python_version'] ?? ''}' : '',
      deviceName: '${device['name'] ?? ''}',
      vramTotal: (device['vram_total'] as num?)?.toInt() ?? 0,
      vramFree: (device['vram_free'] as num?)?.toInt() ?? 0,
    );
  }
}

class QueueSnapshot {
  final int running;
  final int pending;

  const QueueSnapshot({this.running = 0, this.pending = 0});

  static QueueSnapshot fromJson(Map<String, dynamic> json) => QueueSnapshot(
    running: json['queue_running'] is List
        ? (json['queue_running'] as List).length
        : 0,
    pending: json['queue_pending'] is List
        ? (json['queue_pending'] as List).length
        : 0,
  );
}

class WorkflowDef {
  final String name;
  final Map<String, dynamic> graph;
  final bool builtin;

  const WorkflowDef({
    required this.name,
    required this.graph,
    this.builtin = false,
  });

  Map<String, dynamic> toJson() => {
    'name': name,
    'graph': graph,
    'builtin': builtin,
  };

  static WorkflowDef? tryParse(String raw, {String? name}) {
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! Map<String, dynamic>) return null;
      final isApi = decoded.values.every(
        (v) => v is Map && v['class_type'] is String,
      );
      if (!isApi || decoded.isEmpty) return null;
      return WorkflowDef(name: name ?? 'custom', graph: decoded);
    } catch (_) {
      return null;
    }
  }

  static WorkflowDef fromJson(Map<String, dynamic> json) => WorkflowDef(
    name: json['name'] as String? ?? 'custom',
    graph: json['graph'] is Map<String, dynamic>
        ? json['graph'] as Map<String, dynamic>
        : const {},
    builtin: json['builtin'] as bool? ?? false,
  );
}
