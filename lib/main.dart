import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:window_manager/window_manager.dart';

import 'app.dart';
import 'services/comfy_api.dart';
import 'services/comfy_ws.dart';
import 'services/file_picker_stub.dart'
    if (dart.library.io) 'services/file_picker_io.dart';
import 'services/image_store.dart';
import 'services/launcher.dart';
import 'services/window_actions_impl.dart';
import 'state/app_state.dart';
import 'state/generate_controller.dart';
import 'state/history_store.dart';
import 'state/settings_store.dart';
import 'state/workflows_store.dart';
import 'ui/shell/title_bar.dart' show isDesktopPlatform;

// coverage:ignore-start
Future<void> _initWindow() async {
  await windowManager.ensureInitialized();
  const options = WindowOptions(
    titleBarStyle: TitleBarStyle.hidden,
    windowButtonVisibility: false,
  );
  await windowManager.waitUntilReadyToShow(options, () async {
    await windowManager.show();
    await windowManager.focus();
  });
}
// coverage:ignore-end

Future<AppState> createAppState(SharedPreferences prefs) async {
  final settings = await SettingsStore.load(prefs);
  final images = PrefsImageStore(prefs);
  final history = await HistoryStore.load(prefs);
  final httpClient = http.Client();
  return AppState(
    prefs: prefs,
    settings: settings,
    history: history,
    workflows: await WorkflowsStore.load(prefs),
    generator: GenerateController(
      api: () => HttpComfyApi(
        parseServerUri(settings.serverUrl) ??
            Uri.parse('http://127.0.0.1:8188'),
        client: httpClient,
      ),
      connect: defaultWsConnector,
      images: images,
      history: history,
      prefs: prefs,
    ),
    launch: defaultLaunch,
    packageInfo: PackageInfo.fromPlatform,
    imageStore: images,
    windowActions: isDesktopPlatform ? WindowManagerActions() : null,
    pickWorkflowFile: kIsWeb ? null : pickWorkflowFile, // coverage:ignore-line
    saveImage: kIsWeb ? null : saveImageFile, // coverage:ignore-line
    isWeb: kIsWeb,
  );
}

// coverage:ignore-start
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (isDesktopPlatform) {
    await _initWindow();
  }
  final prefs = await SharedPreferences.getInstance();
  final state = await createAppState(prefs);
  runApp(AppScope(state: state, child: const SimpleuiApp()));
}
// coverage:ignore-end
