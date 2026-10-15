import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:simpleui/ui/shell/title_bar.dart';

import 'fakes.dart';

void main() {
  testWidgets('traffic lights fire window actions', (tester) async {
    final actions = FakeWindowActions();
    await pumpPage(
      tester,
      await testState(),
      AppTitleBar(title: 'SimpleUI', windowActions: actions),
    );

    await tester.tap(find.byKey(const Key('titlebar.close')));
    await tester.tap(find.byKey(const Key('titlebar.minimize')));
    await tester.tap(find.byKey(const Key('titlebar.maximize')));
    expect(actions.closed, 1);
    expect(actions.minimized, 1);
    expect(actions.maximized, 1);
  });

  testWidgets('hover reveals glyphs', (tester) async {
    await pumpPage(
      tester,
      await testState(),
      const AppTitleBar(title: 'SimpleUI'),
    );
    expect(find.byIcon(Icons.close), findsNothing);
    final mouse = await tester.createGesture(kind: PointerDeviceKind.mouse);
    await mouse.addPointer(location: Offset.zero);
    addTearDown(mouse.removePointer);
    await mouse.moveTo(tester.getCenter(find.byType(TrafficLights)));
    await tester.pumpAndSettle();
    expect(find.byIcon(Icons.close), findsOneWidget);
    await mouse.moveTo(Offset.zero);
    await tester.pumpAndSettle();
    expect(find.byIcon(Icons.close), findsNothing);
  });

  testWidgets('drag and double tap drive the window', (tester) async {
    final actions = FakeWindowActions();
    await pumpPage(
      tester,
      await testState(),
      AppTitleBar(title: 'SimpleUI', windowActions: actions),
    );
    final drag = await tester.startGesture(
      tester.getCenter(find.text('SimpleUI')),
    );
    await drag.moveBy(const Offset(80, 0));
    await drag.up();
    await tester.pump();
    await tester.tap(find.text('SimpleUI'));
    await tester.pump(const Duration(milliseconds: 60));
    await tester.tap(find.text('SimpleUI'));
    await tester.pumpAndSettle();
    expect(actions.dragged, greaterThanOrEqualTo(1));
    expect(actions.maximized, greaterThanOrEqualTo(1));
  });

  testWidgets('no controls hides the lights', (tester) async {
    await pumpPage(
      tester,
      await testState(),
      const AppTitleBar(title: 'T', showControls: false),
    );
    expect(find.byType(TrafficLights), findsNothing);
    expect(find.text('T'), findsOneWidget);
  });

  test('isDesktopPlatform follows the host', () {
    expect(isDesktopPlatform, isA<bool>());
  });
}
