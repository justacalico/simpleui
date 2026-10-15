import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:simpleui/models/comfy.dart';
import 'package:simpleui/services/image_store.dart';
import 'package:simpleui/state/history_store.dart';
import 'package:simpleui/state/settings_store.dart';
import 'package:simpleui/state/workflows_store.dart';

Future<SharedPreferences> prefs([Map<String, Object> values = const {}]) {
  SharedPreferences.setMockInitialValues(values);
  return SharedPreferences.getInstance();
}

void main() {
  group('SettingsStore', () {
    test('defaults', () async {
      final p = await prefs();
      final s = await SettingsStore.load(p);
      expect(s.theme, AppTheme.system);
      expect(s.accentColor, 0xFF6C5CE7);
      expect(s.locale, isNull);
      expect(s.serverUrl, 'http://127.0.0.1:8188');
      expect(s.activeWorkflow, '');
      expect(s.sidebarCollapsed, false);
      expect(s.keepSeed, false);
      expect(s.lastSeed, -1);
      expect(s.params.model, '');
    });

    test('persists and reloads every field', () async {
      final p = await prefs();
      final s = await SettingsStore.load(p);
      await s.setTheme(AppTheme.oled, p);
      await s.setAccentColor(0xFF112233, p);
      await s.setLocale(const Locale('ru'), p);
      await s.setServerUrl('https://gpu.lan', p);
      await s.setParams(
        const GenerationParams(
          negativePrompt: 'bad',
          model: 'm.ckpt',
          steps: 30,
          cfg: 4.5,
          sampler: 'ddim',
          scheduler: 'karras',
          width: 512,
          height: 768,
          batchSize: 4,
        ),
        p,
      );
      await s.setActiveWorkflow('wf', p);
      await s.setSidebarCollapsed(true, p);
      await s.setKeepSeed(true, p);
      await s.setLastSeed(123, p);

      final fresh = await SettingsStore.load(p);
      expect(fresh.theme, AppTheme.oled);
      expect(fresh.accentColor, 0xFF112233);
      expect(fresh.locale, const Locale('ru'));
      expect(fresh.serverUrl, 'https://gpu.lan');
      expect(fresh.params.model, 'm.ckpt');
      expect(fresh.params.negativePrompt, 'bad');
      expect(fresh.params.batchSize, 4);
      expect(fresh.activeWorkflow, 'wf');
      expect(fresh.sidebarCollapsed, true);
      expect(fresh.keepSeed, true);
      expect(fresh.lastSeed, 123);
    });

    test('clearing locale removes the pref', () async {
      final p = await prefs();
      final s = await SettingsStore.load(p);
      await s.setLocale(const Locale('ga'), p);
      await s.setLocale(null, p);
      expect((await SettingsStore.load(p)).locale, isNull);
    });

    test('locale with country persists', () async {
      final p = await prefs();
      final s = await SettingsStore.load(p);
      await s.setLocale(const Locale('en', 'GB'), p);
      expect((await SettingsStore.load(p)).locale, const Locale('en', 'GB'));
    });

    test('garbage stored values fall back', () async {
      final p = await prefs({
        'theme': 'nope',
        'locale': 'xx_YY',
        'default_params': '%%%',
      });
      final s = await SettingsStore.load(p);
      expect(s.theme, AppTheme.system);
      expect(s.locale, isNull);
      expect(s.params.steps, 20);
    });

    test('locale parse accepts each supported locale', () async {
      for (final locale in supportedLocales) {
        final code = locale.countryCode == null
            ? locale.languageCode
            : '${locale.languageCode}_${locale.countryCode}';
        final p = await prefs({'locale': code});
        expect((await SettingsStore.load(p)).locale, locale);
      }
    });

    test('reload repopulates from prefs', () async {
      final p = await prefs();
      final s = await SettingsStore.load(p);
      await p.setString('server_url', 'http://x:1');
      await s.reload(p);
      expect(s.serverUrl, 'http://x:1');
    });
  });

  group('HistoryStore', () {
    test('add/remove/clear keep prefs in sync', () async {
      final p = await prefs();
      final images = PrefsImageStore(p);
      final h = await HistoryStore.load(p);
      expect(h.isEmpty, true);
      await images.save('k1', Uint8List(4));
      await h.add(
        GenerationEntry(
          id: 'e1',
          params: const GenerationParams(prompt: 'p'),
          imageKeys: const ['k1'],
          createdAt: DateTime.utc(2026),
        ),
        p,
      );
      expect(h.entries.first.id, 'e1');
      expect((await HistoryStore.load(p)).entries.length, 1);

      await h.remove('e1', p, images);
      expect(h.isEmpty, true);
      expect(await images.read('k1'), isNull);

      await h.add(
        GenerationEntry(
          id: 'e2',
          params: const GenerationParams(),
          imageKeys: const [],
          createdAt: DateTime.utc(2026),
        ),
        p,
      );
      await h.clear(p, images);
      expect(h.isEmpty, true);
      expect(p.getString('generation_history'), '[]');
    });

    test('caps at 200 entries', () async {
      final p = await prefs();
      final h = await HistoryStore.load(p);
      for (var i = 0; i < 205; i++) {
        await h.add(
          GenerationEntry(
            id: 'e$i',
            params: const GenerationParams(),
            imageKeys: const [],
            createdAt: DateTime.utc(2026),
          ),
          p,
        );
      }
      expect(h.entries.length, 200);
      expect(h.entries.first.id, 'e204');
    });

    test('corrupt or missing pref starts empty', () async {
      final p = await prefs({'generation_history': 'not json'});
      expect((await HistoryStore.load(p)).isEmpty, true);
      final empty = await prefs();
      expect((await HistoryStore.load(empty)).isEmpty, true);
      final blank = await prefs({'generation_history': ''});
      expect((await HistoryStore.load(blank)).isEmpty, true);
    });

    test('reload refreshes entries', () async {
      final p = await prefs();
      final h = await HistoryStore.load(p);
      await p.setString(
        'generation_history',
        jsonEncode([
          {'id': 'x', 'params': {}, 'imageKeys': [], 'createdAt': '2026-01-01'},
        ]),
      );
      await h.reload(p);
      expect(h.entries.single.id, 'x');
    });
  });

  group('WorkflowsStore', () {
    test('always exposes the builtin workflow first', () async {
      final p = await prefs();
      final w = await WorkflowsStore.load(p);
      expect(w.all.first.builtin, true);
      expect(w.all.first.name, 'txt2img');
      expect(w.named('missing'), isNull);
      expect(w.active('missing').builtin, true);
      expect(w.active('txt2img').builtin, true);
    });

    test('add persists, dedupes by name, remove deletes', () async {
      final p = await prefs();
      final w = await WorkflowsStore.load(p);
      final wf = WorkflowDef.tryParse(
        '{"1": {"class_type": "X"}}',
        name: 'w1',
      )!;
      await w.add(wf, p);
      await w.add(wf.copyNamed('w1'), p);
      expect(w.custom.length, 1);
      expect((await WorkflowsStore.load(p)).custom.length, 1);
      await w.remove('w1', p);
      expect(w.custom, isEmpty);
      expect((await WorkflowsStore.load(p)).custom, isEmpty);
    });

    test('corrupt pref starts empty, reload refreshes', () async {
      final p = await prefs({'workflows': 'junk'});
      final w = await WorkflowsStore.load(p);
      expect(w.custom, isEmpty);
      final list = await prefs({'workflows': '[{}]'});
      final w2 = await WorkflowsStore.load(list);
      expect(w2.custom.length, 1);
      final p3 = await prefs();
      final w3 = await WorkflowsStore.load(p3);
      expect(w3.custom, isEmpty);
      final blank = await prefs({'workflows': ''});
      expect((await WorkflowsStore.load(blank)).custom, isEmpty);
      final notList = await prefs({'workflows': '{}'});
      expect((await WorkflowsStore.load(notList)).custom, isEmpty);
      await p3.setString('workflows', '[{"name":"z","graph":{}}]');
      await w3.reload(p3);
      expect(w3.custom.single.name, 'z');
    });
  });

  group('PrefsImageStore', () {
    test('save/read/delete round-trip', () async {
      final p = await prefs();
      final store = PrefsImageStore(p);
      final bytes = Uint8List.fromList([1, 2, 3, 4]);
      expect(await store.read('missing'), isNull);
      await store.save('k', bytes);
      expect(await store.read('k'), bytes);
      await store.delete('k');
      expect(await store.read('k'), isNull);
    });

    test('corrupt base64 reads as null', () async {
      final p = await prefs({'img_bad': '!!!not-base64'});
      expect(await PrefsImageStore(p).read('bad'), isNull);
    });
  });
}

extension on WorkflowDef {
  WorkflowDef copyNamed(String name) =>
      WorkflowDef(name: name, graph: graph, builtin: builtin);
}
