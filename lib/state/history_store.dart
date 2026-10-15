import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/comfy.dart';
import '../services/image_store.dart';

class HistoryStore extends ChangeNotifier {
  static const _key = 'generation_history';
  static const _maxEntries = 200;

  List<GenerationEntry> _entries;

  HistoryStore([List<GenerationEntry>? entries])
    : _entries = entries ?? const [];

  static Future<HistoryStore> load(SharedPreferences prefs) async {
    final raw = prefs.getString(_key);
    if (raw == null || raw.isEmpty) return HistoryStore();
    try {
      return HistoryStore(GenerationEntry.decodeList(raw));
    } catch (_) {
      return HistoryStore();
    }
  }

  List<GenerationEntry> get entries => List.unmodifiable(_entries);
  bool get isEmpty => _entries.isEmpty;

  Future<void> add(GenerationEntry entry, SharedPreferences prefs) async {
    _entries = [entry, ..._entries];
    if (_entries.length > _maxEntries) {
      _entries = _entries.sublist(0, _maxEntries);
    }
    notifyListeners();
    await _save(prefs);
  }

  Future<void> remove(
    String id,
    SharedPreferences prefs,
    ImageStore images,
  ) async {
    final entry = _entries.where((e) => e.id == id).firstOrNull;
    _entries = _entries.where((e) => e.id != id).toList();
    notifyListeners();
    await _save(prefs);
    if (entry != null) {
      for (final key in entry.imageKeys) {
        await images.delete(key);
      }
    }
  }

  Future<void> clear(SharedPreferences prefs, ImageStore images) async {
    final keys = {for (final e in _entries) ...e.imageKeys};
    _entries = const [];
    notifyListeners();
    await _save(prefs);
    for (final key in keys) {
      await images.delete(key);
    }
  }

  Future<void> reload(SharedPreferences prefs) async {
    final fresh = await load(prefs);
    _entries = fresh._entries;
    notifyListeners();
  }

  Future<void> _save(SharedPreferences prefs) async {
    await prefs.setString(
      _key,
      jsonEncode([for (final e in _entries) e.toJson()]),
    );
  }
}
