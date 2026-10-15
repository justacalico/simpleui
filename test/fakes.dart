import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:simpleui/l10n/app_localizations.dart';
import 'package:simpleui/models/app_update.dart';
import 'package:simpleui/models/comfy.dart';
import 'package:simpleui/services/comfy_api.dart';
import 'package:simpleui/services/image_store.dart';
import 'package:simpleui/services/version_checker.dart';
import 'package:simpleui/services/window_actions.dart';
import 'package:simpleui/state/app_state.dart';
import 'package:simpleui/state/generate_controller.dart';
import 'package:simpleui/state/history_store.dart';
import 'package:simpleui/state/settings_store.dart';
import 'package:simpleui/state/workflows_store.dart';

const testPngBase64 =
    'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mP8z8BQDwAEhQGAhKmMIQAAAABJRU5ErkJggg==';

final testPng = Uint8List.fromList(
  const Base64Decoder().convert(testPngBase64),
);

class FakeComfyApi implements ComfyApi {
  @override
  Uri baseUri = Uri.parse('http://127.0.0.1:8188');

  SystemStats stats = const SystemStats(
    comfyVersion: '0.3.0',
    pythonVersion: '3.12',
    deviceName: 'Test GPU',
    vramTotal: 100,
    vramFree: 90,
  );
  List<String> checkpointsList = const ['sdxl.safetensors', 'flux.safetensors'];
  List<ComfyImage> imagesResult = const [ComfyImage(filename: 'img_0001.png')];
  Uint8List imageBytesValue = testPng;
  QueueSnapshot queueSnapshot = const QueueSnapshot(running: 1, pending: 2);
  int queued = 0;
  int interrupted = 0;
  int cleared = 0;
  Map<String, dynamic>? lastGraph;
  Object? queueError;
  Object? statsError;

  @override
  Future<SystemStats> systemStats() async {
    if (statsError != null) throw statsError!;
    return stats;
  }

  @override
  Future<List<String>> checkpoints() async => checkpointsList;

  @override
  Future<String> queuePrompt(
    Map<String, dynamic> graph,
    String clientId,
  ) async {
    if (queueError != null) throw queueError!;
    lastGraph = graph;
    return 'pid-${++queued}';
  }

  @override
  Future<List<ComfyImage>> historyImages(String promptId) async => imagesResult;

  @override
  Future<QueueSnapshot> queue() async => queueSnapshot;

  @override
  Future<Uint8List> image(ComfyImage image) async => imageBytesValue;

  @override
  Future<void> interrupt() async {
    interrupted++;
  }

  @override
  Future<void> clearQueue() async {
    cleared++;
  }
}

class FakeSocket {
  final controller = StreamController<dynamic>(sync: true);
  final List<Uri> opened = [];

  Stream<dynamic> connect(Uri uri) {
    opened.add(uri);
    return controller.stream;
  }
}

class FakeWindowActions implements WindowActions {
  int minimized = 0;
  int maximized = 0;
  int closed = 0;
  int dragged = 0;

  @override
  Future<void> minimize() async => minimized++;

  @override
  Future<void> toggleMaximize() async => maximized++;

  @override
  Future<void> close() async => closed++;

  @override
  Future<void> startDrag() async => dragged++;
}

class FakeVersionChecker extends VersionChecker {
  AppUpdate? result;
  Object? error;
  int calls = 0;
  Completer<void>? gate;

  @override
  Future<AppUpdate> check(String currentVersion) async {
    calls++;
    await gate?.future;
    if (error != null) throw error!;
    return result ?? AppUpdate(currentVersion: currentVersion);
  }
}

Future<AppState> testState({
  Map<String, Object>? prefs,
  ComfyApi? api,
  FakeSocket? socket,
  ImageStore? imageStore,
  HistoryStore? history,
  WorkflowsStore? workflows,
  SettingsStore? settings,
  WindowActions? windowActions,
  FakeVersionChecker? versionChecker,
  List<Uri>? launches,
  Future<String?> Function()? pickWorkflowFile,
  Future<bool> Function(String, Uint8List)? saveImage,
  String version = '1.0.0',
  bool isWeb = false,
}) async {
  SharedPreferences.setMockInitialValues(prefs ?? {});
  final shared = await SharedPreferences.getInstance();
  final store = settings ?? await SettingsStore.load(shared);
  final hist = history ?? await HistoryStore.load(shared);
  final fakeApi = api ?? FakeComfyApi();
  return AppState(
    prefs: shared,
    settings: store,
    history: hist,
    workflows: workflows ?? await WorkflowsStore.load(shared),
    generator: GenerateController(
      api: () => fakeApi,
      connect: socket?.connect ?? (uri) => const Stream<dynamic>.empty(),
      images: imageStore ?? PrefsImageStore(shared),
      history: hist,
      prefs: shared,
      clientId: 'test-client',
    ),
    launch: (uri) async {
      launches?.add(uri);
      return true;
    },
    packageInfo: () async => PackageInfo(
      appName: 'simpleui',
      packageName: 'gitlab.httpanimations.simpleui',
      version: version,
      buildNumber: '1',
    ),
    imageStore: imageStore ?? PrefsImageStore(shared),
    windowActions: windowActions,
    pickWorkflowFile: pickWorkflowFile,
    saveImage: saveImage,
    isWeb: isWeb,
    versionChecker: versionChecker,
  );
}

Future<void> pumpPage(
  WidgetTester tester,
  AppState state,
  Widget child, {
  Size? size,
  Locale? locale,
  Brightness brightness = Brightness.dark,
}) async {
  if (size != null) {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
  }
  await tester.pumpWidget(
    AppScope(
      state: state,
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        locale: locale,
        supportedLocales: AppLocalizations.supportedLocales,
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        theme: ThemeData(fontFamily: 'Inter', brightness: brightness),
        home: Scaffold(body: child),
      ),
    ),
  );
}

class TestHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) => _FakeHttpClient();
}

class _FakeHttpClient extends Fake implements HttpClient {
  @override
  Future<HttpClientRequest> getUrl(Uri url) async => _FakeRequest();
}

class _FakeRequest extends Fake implements HttpClientRequest {
  final _response = _FakeResponse();

  @override
  Future<HttpClientResponse> close() async => _response;

  @override
  Future<HttpClientResponse> get done async => _response;
}

class _FakeResponse extends Fake implements HttpClientResponse {
  @override
  int get statusCode => HttpStatus.ok;

  @override
  int get contentLength => testPng.length;

  @override
  StreamSubscription<List<int>> listen(
    void Function(List<int> event)? onData, {
    Function? onError,
    void Function()? onDone,
    bool? cancelOnError,
  }) => Stream<List<int>>.value(testPng).listen(
    onData,
    onError: onError,
    onDone: onDone,
    cancelOnError: cancelOnError,
  );
}

http.Client mockHttp(Map<String, http.Response Function(Uri)> routes) =>
    MockClient((request) async {
      final key = '${request.method} ${request.url.path}';
      final handler = routes[key] ?? routes['${request.method} *'];
      if (handler == null) {
        return http.Response('not found', 404);
      }
      return handler(request.url);
    });
