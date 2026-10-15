import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:simpleui_landing/main.dart';
import 'package:simpleui_landing/releases.dart';
import 'package:simpleui_landing/showcase.dart';

void main() {
  testWidgets('landing renders hero and controls', (tester) async {
    SharedPreferences.setMockInitialValues({});
    await tester.binding.setSurfaceSize(const Size(1400, 900));
    final s = LandingState();
    await s.load();
    await tester.pumpWidget(LandingApp(state: s));
    await tester.pumpAndSettle();
    expect(find.text('Describe it. Get an image.'), findsOneWidget);
    expect(find.byType(PromptCard), findsOneWidget);
    expect(find.byKey(const Key('theme')), findsOneWidget);
    expect(find.byKey(const Key('language')), findsOneWidget);
  });

  test('releases throws when offline', () {
    expect(fetchReleases(client: _NoClient()), throwsException);
  });

  test('releases parses gitlab payload', () async {
    final r = await fetchReleases(
      client: _FakeClient(
        '[{"tag_name":"v1.0.0","name":"v1.0.0","released_at":"2026-01-01T00:00:00Z","assets":{"links":[{"name":"a.zip","url":"https://x/a.zip"}]}}]',
      ),
    );
    expect(r.single.tag, 'v1.0.0');
    expect(r.single.assets.single.name, 'a.zip');
  });
}

class _NoClient extends http.BaseClient {
  @override
  Future<http.StreamedResponse> send(http.BaseRequest r) =>
      throw Exception('offline');
}

class _FakeClient extends http.BaseClient {
  final String body;

  _FakeClient(this.body);

  @override
  Future<http.StreamedResponse> send(http.BaseRequest r) async {
    final bytes = body.codeUnits;
    return http.StreamedResponse(Stream.fromIterable([bytes]), 200, request: r);
  }
}
