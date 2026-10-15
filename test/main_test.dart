import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:simpleui/main.dart';

void main() {
  test('createAppState wires a working AppState', () async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final state = await createAppState(prefs);
    expect(state.settings.serverUrl, isNotEmpty);
    expect(state.workflows.all, isNotEmpty);
    expect(state.history.isEmpty, true);
    expect(state.generator.clientId, startsWith('simpleui-'));
    expect(state.generator.api(), isNotNull);
    state.dispose();
  });

  test('createAppState falls back on bad server url', () async {
    SharedPreferences.setMockInitialValues({'server_url': 'ftp://x'});
    final prefs = await SharedPreferences.getInstance();
    final state = await createAppState(prefs);
    expect(state.generator.api().baseUri.toString(), 'http://127.0.0.1:8188');
    state.dispose();
  });
}
