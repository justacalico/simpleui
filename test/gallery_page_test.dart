import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:simpleui/models/comfy.dart';
import 'package:simpleui/ui/pages/gallery_page.dart';

import 'fakes.dart';

void main() {
  testWidgets('empty gallery shows a message', (tester) async {
    final state = await testState();
    await pumpPage(tester, state, const GalleryPage());
    expect(find.text('No generations yet'), findsOneWidget);
  });

  testWidgets('grid opens detail, save and delete work', (tester) async {
    final saved = <String>[];
    final state = await testState(
      saveImage: (name, bytes) async {
        saved.add(name);
        return true;
      },
    );
    final key = 'e1-img.png';
    await state.imageStore.save(key, testPng);
    await state.history.add(
      GenerationEntry(
        id: 'e1',
        params: const GenerationParams(
          prompt: 'a fox',
          negativePrompt: 'bad',
          model: 'm',
        ),
        imageKeys: [key],
        createdAt: DateTime.utc(2026, 1, 1),
      ),
      state.prefs,
    );

    await pumpPage(
      tester,
      state,
      const GalleryPage(),
      size: const Size(900, 700),
    );
    await tester.pumpAndSettle();
    expect(find.byType(GridView), findsOneWidget);

    await tester.tap(find.byType(InkWell).first);
    await tester.pumpAndSettle();
    expect(find.text('a fox'), findsOneWidget);
    expect(find.text('bad'), findsOneWidget);

    await tester.tap(find.byKey(const Key('detail.save')));
    await tester.pumpAndSettle();
    expect(saved.single, 'e1-img.png.png');

    await tester.tap(find.byKey(const Key('detail.delete')));
    await tester.pumpAndSettle();
    expect(state.history.isEmpty, true);
    expect(find.text('No generations yet'), findsOneWidget);
  });

  testWidgets('entry without images renders a placeholder', (tester) async {
    final state = await testState();
    await state.history.add(
      GenerationEntry(
        id: 'e2',
        params: const GenerationParams(prompt: 'x'),
        imageKeys: const [],
        createdAt: DateTime.utc(2026),
      ),
      state.prefs,
    );
    await pumpPage(tester, state, const GalleryPage());
    await tester.pumpAndSettle();
    expect(find.byIcon(Icons.image_outlined), findsWidgets);
  });

  testWidgets('corrupt bytes render broken image icon', (tester) async {
    final state = await testState();
    await state.imageStore.save('bad', testPng.sublist(0, 10));
    await state.history.add(
      GenerationEntry(
        id: 'e3',
        params: const GenerationParams(prompt: 'x'),
        imageKeys: const ['bad'],
        createdAt: DateTime.utc(2026),
      ),
      state.prefs,
    );
    await pumpPage(tester, state, const GalleryPage());
    await tester.pumpAndSettle();
    expect(find.byIcon(Icons.broken_image_outlined), findsWidgets);
  });
}
