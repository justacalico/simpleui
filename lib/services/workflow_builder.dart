import 'dart:convert';

import '../models/comfy.dart';

const samplers = [
  'euler',
  'euler_ancestral',
  'heun',
  'dpm_2',
  'dpm_2_ancestral',
  'lms',
  'dpm_fast',
  'dpm_adaptive',
  'dpmpp_2s_ancestral',
  'dpmpp_sde',
  'dpmpp_2m',
  'dpmpp_2m_sde',
  'dpmpp_3m_sde',
  'ddim',
  'uni_pc',
  'uni_pc_bh2',
];

const schedulers = [
  'normal',
  'karras',
  'exponential',
  'sgm_uniform',
  'simple',
  'ddim_uniform',
  'beta',
];

const builtinTxt2ImgName = 'txt2img';

Map<String, dynamic> txt2imgGraph(GenerationParams params) => {
  '3': {
    'class_type': 'KSampler',
    'inputs': {
      'seed': params.seed < 0 ? 0 : params.seed,
      'steps': params.steps,
      'cfg': params.cfg,
      'sampler_name': params.sampler,
      'scheduler': params.scheduler,
      'denoise': 1.0,
      'model': ['4', 0],
      'positive': ['6', 0],
      'negative': ['7', 0],
      'latent_image': ['5', 0],
    },
  },
  '4': {
    'class_type': 'CheckpointLoaderSimple',
    'inputs': {'ckpt_name': params.model},
  },
  '5': {
    'class_type': 'EmptyLatentImage',
    'inputs': {
      'width': params.width,
      'height': params.height,
      'batch_size': params.batchSize,
    },
  },
  '6': {
    'class_type': 'CLIPTextEncode',
    'inputs': {
      'text': params.prompt,
      'clip': ['4', 1],
    },
  },
  '7': {
    'class_type': 'CLIPTextEncode',
    'inputs': {
      'text': params.negativePrompt,
      'clip': ['4', 1],
    },
  },
  '8': {
    'class_type': 'VAEDecode',
    'inputs': {
      'samples': ['3', 0],
      'vae': ['4', 2],
    },
  },
  '9': {
    'class_type': 'SaveImage',
    'inputs': {
      'filename_prefix': 'simpleui',
      'images': ['8', 0],
    },
  },
};

Map<String, dynamic> _deepCopy(Map<String, dynamic> graph) =>
    jsonDecode(jsonEncode(graph)) as Map<String, dynamic>;

String? _nodeOfType(Map<String, dynamic> graph, String classType) {
  for (final entry in graph.entries) {
    final node = entry.value;
    if (node is Map && node['class_type'] == classType) return entry.key;
  }
  return null;
}

Map<String, dynamic>? _node(Map<String, dynamic> graph, String? id) {
  if (id == null) return null;
  final node = graph[id];
  return node is Map<String, dynamic> ? node : null;
}

Map<String, dynamic>? _inputs(Map<String, dynamic> graph, String? id) {
  final inputs = _node(graph, id)?['inputs'];
  return inputs is Map<String, dynamic> ? inputs : null;
}

String? _linkTarget(Map<String, dynamic> graph, String nodeId, String input) {
  final link = _inputs(graph, nodeId)?[input];
  return link is List && link.isNotEmpty ? '${link[0]}' : null;
}

Map<String, dynamic> applyParams(
  Map<String, dynamic> graph,
  GenerationParams params,
) {
  final out = _deepCopy(graph);
  final samplerId =
      _nodeOfType(out, 'KSampler') ?? _nodeOfType(out, 'KSamplerAdvanced');
  final samplerInputs = _inputs(out, samplerId);
  if (samplerInputs != null) {
    if (samplerInputs.containsKey('seed')) {
      samplerInputs['seed'] = params.seed < 0 ? 0 : params.seed;
    }
    if (samplerInputs.containsKey('steps')) {
      samplerInputs['steps'] = params.steps;
    }
    if (samplerInputs.containsKey('cfg')) samplerInputs['cfg'] = params.cfg;
    if (samplerInputs.containsKey('sampler_name')) {
      samplerInputs['sampler_name'] = params.sampler;
    }
    if (samplerInputs.containsKey('scheduler')) {
      samplerInputs['scheduler'] = params.scheduler;
    }
  }

  final latentId = _nodeOfType(out, 'EmptyLatentImage');
  final latentInputs = _inputs(out, latentId);
  if (latentInputs != null) {
    if (latentInputs.containsKey('width')) latentInputs['width'] = params.width;
    if (latentInputs.containsKey('height')) {
      latentInputs['height'] = params.height;
    }
    if (latentInputs.containsKey('batch_size')) {
      latentInputs['batch_size'] = params.batchSize;
    }
  }

  final ckptId = _nodeOfType(out, 'CheckpointLoaderSimple');
  final ckptInputs = _inputs(out, ckptId);
  if (ckptInputs != null && ckptInputs.containsKey('ckpt_name')) {
    ckptInputs['ckpt_name'] = params.model;
  }

  if (samplerId != null) {
    final positiveId = _linkTarget(out, samplerId, 'positive');
    final negativeId = _linkTarget(out, samplerId, 'negative');
    for (final entry in out.entries) {
      final node = entry.value;
      if (node is! Map || node['class_type'] != 'CLIPTextEncode') continue;
      final inputs = node['inputs'];
      if (inputs is! Map || !inputs.containsKey('text')) continue;
      if (entry.key == positiveId) {
        inputs['text'] = params.prompt;
      } else if (entry.key == negativeId) {
        inputs['text'] = params.negativePrompt;
      }
    }
  }
  return out;
}
