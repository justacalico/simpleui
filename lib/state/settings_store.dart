import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/comfy.dart';

const supportedLocales = [
  Locale('en', 'GB'),
  Locale('zh', 'Hans'),
  Locale('ru'),
  Locale('ga'),
];

enum AppTheme { system, light, dark, oled }

class SettingsStore extends ChangeNotifier {
  static const _themeKey = 'theme';
  static const _accentColorKey = 'accent_color';
  static const _localeKey = 'locale';
  static const _serverUrlKey = 'server_url';
  static const _paramsKey = 'default_params';
  static const _activeWorkflowKey = 'active_workflow';
  static const _sidebarCollapsedKey = 'sidebar_collapsed';
  static const _keepSeedKey = 'keep_seed';
  static const _lastSeedKey = 'last_seed';

  AppTheme _theme;
  int _accentColor;
  Locale? _locale;
  String _serverUrl;
  GenerationParams _params;
  String _activeWorkflow;
  bool _sidebarCollapsed;
  bool _keepSeed;
  int _lastSeed;

  SettingsStore({
    this._theme = AppTheme.system,
    this._accentColor = 0xFF6C5CE7,
    this._locale,
    this._serverUrl = 'http://127.0.0.1:8188',
    GenerationParams? params,
    this._activeWorkflow = '',
    this._sidebarCollapsed = false,
    this._keepSeed = false,
    this._lastSeed = -1,
  }) : _params = params ?? const GenerationParams();

  static Future<SettingsStore> load(SharedPreferences prefs) async {
    return SettingsStore(
      theme:
          AppTheme.values.asNameMap()[prefs.getString(_themeKey)] ??
          AppTheme.system,
      accentColor: prefs.getInt(_accentColorKey) ?? 0xFF6C5CE7,
      locale: _parseLocale(prefs.getString(_localeKey)),
      serverUrl: prefs.getString(_serverUrlKey) ?? 'http://127.0.0.1:8188',
      params: _parseParams(prefs.getString(_paramsKey)),
      activeWorkflow: prefs.getString(_activeWorkflowKey) ?? '',
      sidebarCollapsed: prefs.getBool(_sidebarCollapsedKey) ?? false,
      keepSeed: prefs.getBool(_keepSeedKey) ?? false,
      lastSeed: prefs.getInt(_lastSeedKey) ?? -1,
    );
  }

  static String _localeTag(Locale locale) => locale.countryCode == null
      ? locale.languageCode
      : '${locale.languageCode}_${locale.countryCode}';

  static Locale? _parseLocale(String? raw) {
    if (raw == null || raw.isEmpty) return null;
    for (final locale in supportedLocales) {
      if (_localeTag(locale) == raw) return locale;
    }
    return null;
  }

  static GenerationParams? _parseParams(String? raw) {
    if (raw == null || raw.isEmpty) return null;
    try {
      final decoded = Uri.splitQueryString(raw);
      return GenerationParams(
        prompt: '',
        negativePrompt: decoded['negative'] ?? '',
        model: decoded['model'] ?? '',
        steps: int.tryParse(decoded['steps'] ?? '') ?? 20,
        cfg: double.tryParse(decoded['cfg'] ?? '') ?? 7.0,
        sampler: decoded['sampler'] ?? 'euler',
        scheduler: decoded['scheduler'] ?? 'normal',
        width: int.tryParse(decoded['width'] ?? '') ?? 1024,
        height: int.tryParse(decoded['height'] ?? '') ?? 1024,
        batchSize: int.tryParse(decoded['batch'] ?? '') ?? 1,
      );
    } catch (_) {
      return null;
    }
  }

  Future<void> reload(SharedPreferences prefs) async {
    final fresh = await load(prefs);
    _theme = fresh._theme;
    _accentColor = fresh._accentColor;
    _locale = fresh._locale;
    _serverUrl = fresh._serverUrl;
    _params = fresh._params;
    _activeWorkflow = fresh._activeWorkflow;
    _sidebarCollapsed = fresh._sidebarCollapsed;
    _keepSeed = fresh._keepSeed;
    _lastSeed = fresh._lastSeed;
    notifyListeners();
  }

  AppTheme get theme => _theme;
  int get accentColor => _accentColor;
  Locale? get locale => _locale;
  String get serverUrl => _serverUrl;
  GenerationParams get params => _params;
  String get activeWorkflow => _activeWorkflow;
  bool get sidebarCollapsed => _sidebarCollapsed;
  bool get keepSeed => _keepSeed;
  int get lastSeed => _lastSeed;

  Future<void> setTheme(AppTheme theme, SharedPreferences prefs) async {
    _theme = theme;
    notifyListeners();
    await prefs.setString(_themeKey, theme.name);
  }

  Future<void> setAccentColor(int color, SharedPreferences prefs) async {
    _accentColor = color;
    notifyListeners();
    await prefs.setInt(_accentColorKey, color);
  }

  Future<void> setLocale(Locale? locale, SharedPreferences prefs) async {
    _locale = locale;
    notifyListeners();
    if (locale == null) {
      await prefs.remove(_localeKey);
    } else {
      await prefs.setString(_localeKey, _localeTag(locale));
    }
  }

  Future<void> setServerUrl(String url, SharedPreferences prefs) async {
    _serverUrl = url;
    notifyListeners();
    await prefs.setString(_serverUrlKey, url);
  }

  Future<void> setParams(
    GenerationParams params,
    SharedPreferences prefs,
  ) async {
    _params = params;
    notifyListeners();
    await prefs.setString(
      _paramsKey,
      Uri(
        queryParameters: {
          'negative': params.negativePrompt,
          'model': params.model,
          'steps': '${params.steps}',
          'cfg': '${params.cfg}',
          'sampler': params.sampler,
          'scheduler': params.scheduler,
          'width': '${params.width}',
          'height': '${params.height}',
          'batch': '${params.batchSize}',
        },
      ).query,
    );
  }

  Future<void> setActiveWorkflow(String name, SharedPreferences prefs) async {
    _activeWorkflow = name;
    notifyListeners();
    await prefs.setString(_activeWorkflowKey, name);
  }

  Future<void> setSidebarCollapsed(
    bool collapsed,
    SharedPreferences prefs,
  ) async {
    _sidebarCollapsed = collapsed;
    notifyListeners();
    await prefs.setBool(_sidebarCollapsedKey, collapsed);
  }

  Future<void> setKeepSeed(bool keep, SharedPreferences prefs) async {
    _keepSeed = keep;
    notifyListeners();
    await prefs.setBool(_keepSeedKey, keep);
  }

  Future<void> setLastSeed(int seed, SharedPreferences prefs) async {
    _lastSeed = seed;
    await prefs.setInt(_lastSeedKey, seed);
  }
}
