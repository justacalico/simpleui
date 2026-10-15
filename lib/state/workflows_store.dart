import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/comfy.dart';
import '../services/workflow_builder.dart';

class WorkflowsStore extends ChangeNotifier {
  static const _key = 'workflows';

  List<WorkflowDef> _custom;

  WorkflowsStore([List<WorkflowDef>? custom]) : _custom = custom ?? const [];

  static Future<WorkflowsStore> load(SharedPreferences prefs) async {
    final raw = prefs.getString(_key);
    if (raw == null || raw.isEmpty) return WorkflowsStore();
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! List) return WorkflowsStore();
      return WorkflowsStore([
        for (final e in decoded)
          if (e is Map<String, dynamic>) WorkflowDef.fromJson(e),
      ]);
    } catch (_) {
      return WorkflowsStore();
    }
  }

  List<WorkflowDef> get custom => List.unmodifiable(_custom);

  List<WorkflowDef> get all => [
    WorkflowDef(
      name: builtinTxt2ImgName,
      graph: txt2imgGraph(const GenerationParams()),
      builtin: true,
    ),
    ..._custom,
  ];

  WorkflowDef? named(String name) {
    for (final w in all) {
      if (w.name == name) return w;
    }
    return null;
  }

  WorkflowDef active(String name) => named(name) ?? all.first;

  Future<void> add(WorkflowDef workflow, SharedPreferences prefs) async {
    _custom = [..._custom.where((w) => w.name != workflow.name), workflow];
    notifyListeners();
    await _save(prefs);
  }

  Future<void> remove(String name, SharedPreferences prefs) async {
    _custom = _custom.where((w) => w.name != name).toList();
    notifyListeners();
    await _save(prefs);
  }

  Future<void> reload(SharedPreferences prefs) async {
    final fresh = await load(prefs);
    _custom = fresh._custom;
    notifyListeners();
  }

  Future<void> _save(SharedPreferences prefs) async {
    await prefs.setString(
      _key,
      jsonEncode([for (final w in _custom) w.toJson()]),
    );
  }
}
