import 'dart:typed_data';

import 'package:flutter/widgets.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/app_update.dart';
import '../services/image_store.dart';
import '../services/launcher.dart';
import '../services/version_checker.dart';
import '../services/window_actions.dart';
import 'generate_controller.dart';
import 'history_store.dart';
import 'settings_store.dart';
import 'workflows_store.dart';

class AppState extends ChangeNotifier {
  final SharedPreferences prefs;
  final WindowActions? windowActions;
  final SettingsStore settings;
  final HistoryStore history;
  final WorkflowsStore workflows;
  final GenerateController generator;
  final UrlLaunch launch;
  final Future<PackageInfo> Function() packageInfo;
  final ImageStore imageStore;
  final Future<String?> Function()? pickWorkflowFile;
  final Future<bool> Function(String name, Uint8List bytes)? saveImage;
  final bool isWeb;

  int _tabIndex = 0;
  AppUpdate? _update;
  Future<AppUpdate?>? _updateCheck;
  VersionChecker? _versionChecker;

  AppState({
    required this.prefs,
    required this.settings,
    required this.history,
    required this.workflows,
    required this.generator,
    required this.launch,
    required this.packageInfo,
    required this.imageStore,
    this.windowActions,
    this.pickWorkflowFile,
    this.saveImage,
    this.isWeb = false,
    this._versionChecker,
  });

  int get tabIndex => _tabIndex;

  void selectTab(int index) {
    if (index == _tabIndex) return;
    _tabIndex = index;
    notifyListeners();
  }

  AppUpdate? get update => _update;

  Future<AppUpdate?> checkForUpdate() {
    final existing = _updateCheck;
    if (existing != null) return existing;
    return _updateCheck = _runUpdateCheck().whenComplete(
      () => _updateCheck = null,
    );
  }

  Future<AppUpdate?> _runUpdateCheck() async {
    try {
      _versionChecker ??= VersionChecker();
      final info = await packageInfo();
      final update = await _versionChecker!.check(info.version);
      if (_update != update) {
        _update = update;
        notifyListeners();
      }
      return update;
    } catch (_) {
      return null;
    }
  }
}

class AppScope extends InheritedNotifier<AppState> {
  const AppScope({super.key, required AppState state, required super.child})
    : super(notifier: state);

  static AppState of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<AppScope>()!.notifier!;

  static AppState read(BuildContext context) =>
      (context.getElementForInheritedWidgetOfExactType<AppScope>()!.widget
              as AppScope)
          .notifier!;
}
