import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:simpleui/ui/shell/app_shell.dart';
import 'package:simpleui/ui/shell/side_nav.dart';

import 'fakes.dart';

void main() {
  testWidgets('wide layout shows sidebar and switches pages', (tester) async {
    final state = await testState();
    await pumpPage(
      tester,
      state,
      const AppShell(),
      size: const Size(1100, 700),
    );
    expect(find.byType(SideNav), findsOneWidget);

    await tester.tap(find.text('Gallery'));
    await tester.pumpAndSettle();
    expect(state.tabIndex, 1);

    await tester.tap(find.text('Queue'));
    await tester.pumpAndSettle();
    expect(state.tabIndex, 2);

    await tester.tap(find.text('Workflows'));
    await tester.pumpAndSettle();
    expect(state.tabIndex, 3);

    await tester.tap(find.text('Settings'));
    await tester.pumpAndSettle();
    expect(state.tabIndex, 4);
  });

  testWidgets('collapse toggle flips the sidebar width', (tester) async {
    final state = await testState();
    await pumpPage(
      tester,
      state,
      const AppShell(),
      size: const Size(1100, 700),
    );
    await tester.tap(find.byIcon(Icons.keyboard_double_arrow_left));
    await tester.pumpAndSettle();
    expect(state.settings.sidebarCollapsed, true);
    await tester.tap(find.byIcon(Icons.keyboard_double_arrow_right));
    await tester.pumpAndSettle();
    expect(state.settings.sidebarCollapsed, false);
  });

  testWidgets('narrow layout uses bottom nav and drawer', (tester) async {
    final state = await testState();
    await pumpPage(tester, state, const AppShell(), size: const Size(400, 800));
    expect(find.byType(NavigationBar), findsOneWidget);

    await tester.tap(find.text('Gallery'));
    await tester.pumpAndSettle();
    expect(state.tabIndex, 1);

    await tester.tap(find.text('More'));
    await tester.pumpAndSettle();
    expect(find.byType(Drawer), findsOneWidget);

    await tester.tap(find.text('Settings').last);
    await tester.pumpAndSettle();
    expect(state.tabIndex, 4);
  });

  testWidgets('drawer selects a middle destination', (tester) async {
    final state = await testState();
    await pumpPage(tester, state, const AppShell(), size: const Size(400, 800));
    await tester.tap(find.text('More'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Workflows').last);
    await tester.pumpAndSettle();
    expect(state.tabIndex, 3);
  });
}
