import 'package:flutter_test/flutter_test.dart';
import 'package:simpleui/models/comfy.dart';
import 'package:simpleui/services/workflow_builder.dart';

void main() {
  const params = GenerationParams(
    prompt: 'a cat',
    negativePrompt: 'blurry',
    model: 'sdxl.safetensors',
    seed: 42,
    steps: 30,
    cfg: 5.5,
    sampler: 'dpmpp_2m',
    scheduler: 'karras',
    width: 832,
    height: 1216,
    batchSize: 4,
  );

  test('txt2imgGraph wires the standard nodes', () {
    final g = txt2imgGraph(params);
    expect(g['3']['inputs']['steps'], 30);
    expect(g['3']['inputs']['cfg'], 5.5);
    expect(g['3']['inputs']['seed'], 42);
    expect(g['4']['inputs']['ckpt_name'], 'sdxl.safetensors');
    expect(g['5']['inputs']['width'], 832);
    expect(g['5']['inputs']['batch_size'], 4);
    expect(g['6']['inputs']['text'], 'a cat');
    expect(g['7']['inputs']['text'], 'blurry');
    expect(g['9']['inputs']['filename_prefix'], 'simpleui');
  });

  test('negative seed becomes zero in the graph', () {
    final g = txt2imgGraph(const GenerationParams(seed: -1));
    expect(g['3']['inputs']['seed'], 0);
  });

  test('applyParams patches an imported graph', () {
    final base = txt2imgGraph(const GenerationParams());
    final out = applyParams(base, params);
    expect(out['3']['inputs']['seed'], 42);
    expect(out['3']['inputs']['sampler_name'], 'dpmpp_2m');
    expect(out['5']['inputs']['height'], 1216);
    expect(out['4']['inputs']['ckpt_name'], 'sdxl.safetensors');
    expect(out['6']['inputs']['text'], 'a cat');
    expect(out['7']['inputs']['text'], 'blurry');
    // original untouched
    expect(base['6']['inputs']['text'], '');
  });

  test('applyParams ignores graphs without matching nodes', () {
    final out = applyParams({
      '1': {
        'class_type': 'SomethingElse',
        'inputs': {'text': 'keep'},
      },
    }, params);
    expect(out['1']['inputs']['text'], 'keep');
  });

  test('applyParams patches KSamplerAdvanced too', () {
    final out = applyParams({
      's': {
        'class_type': 'KSamplerAdvanced',
        'inputs': {'seed': 0, 'steps': 1, 'cfg': 1.0},
      },
    }, params);
    expect(out['s']['inputs']['steps'], 30);
  });

  test('applyParams leaves mismatched clip nodes alone', () {
    final g = txt2imgGraph(const GenerationParams());
    g['10'] = {
      'class_type': 'CLIPTextEncode',
      'inputs': {
        'text': 'style',
        'clip': ['4', 1],
      },
    };
    final out = applyParams(g, params);
    expect(out['10']['inputs']['text'], 'style');
  });

  test('applyParams handles nodes without maps', () {
    final out = applyParams({
      'x': 'not a node',
      'y': {'class_type': 'KSampler'},
      'z': {'class_type': 'CLIPTextEncode', 'inputs': 'bad'},
    }, params);
    expect(out['x'], 'not a node');
  });
}
