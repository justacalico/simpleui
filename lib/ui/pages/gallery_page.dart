import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../l10n/app_localizations.dart';
import '../../models/comfy.dart';
import '../../state/app_state.dart';
import '../widgets/generation_image.dart';

class GalleryPage extends StatelessWidget {
  const GalleryPage({super.key});

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    final l10n = AppLocalizations.of(context);

    return ListenableBuilder(
      listenable: state.history,
      builder: (context, _) {
        final entries = state.history.entries;
        if (entries.isEmpty) {
          return Center(child: Text(l10n.galleryEmpty));
        }
        return GridView.builder(
          padding: const EdgeInsets.all(20),
          gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
            maxCrossAxisExtent: 220,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
          ),
          itemCount: entries.length,
          itemBuilder: (context, i) {
            final entry = entries[i];
            return GenerationImage(
              imageKey: entry.imageKeys.isEmpty ? '' : entry.imageKeys.first,
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => GenerationDetailPage(entry: entry),
                ),
              ),
            );
          },
        );
      },
    );
  }
}

class GenerationDetailPage extends StatelessWidget {
  final GenerationEntry entry;

  const GenerationDetailPage({super.key, required this.entry});

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    final l10n = AppLocalizations.of(context);
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(DateFormat.yMMMd().add_Hm().format(entry.createdAt)),
        actions: [
          if (state.saveImage != null)
            IconButton(
              key: const Key('detail.save'),
              tooltip: l10n.saveImage,
              icon: const Icon(Icons.save_alt),
              onPressed: () async {
                for (final key in entry.imageKeys) {
                  final bytes = await state.imageStore.read(key);
                  if (bytes == null) continue;
                  await state.saveImage!('$key.png', bytes);
                }
              },
            ),
          IconButton(
            key: const Key('detail.delete'),
            tooltip: l10n.delete,
            icon: const Icon(Icons.delete_outline),
            onPressed: () {
              state.history.remove(entry.id, state.prefs, state.imageStore);
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              for (final key in entry.imageKeys)
                ConstrainedBox(
                  constraints: const BoxConstraints(
                    maxWidth: 480,
                    maxHeight: 480,
                  ),
                  child: GenerationImage(imageKey: key, fit: BoxFit.contain),
                ),
            ],
          ),
          const SizedBox(height: 16),
          SelectableText(entry.params.prompt),
          if (entry.params.negativePrompt.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              l10n.negativePrompt,
              style: TextStyle(color: colors.onSurfaceVariant, fontSize: 12),
            ),
            SelectableText(entry.params.negativePrompt),
          ],
          const SizedBox(height: 8),
          Text(
            l10n.detailMeta(
              entry.params.model,
              entry.params.seed,
              entry.params.steps,
              entry.params.cfg,
              entry.params.sampler,
              entry.params.scheduler,
              '${entry.params.width}x${entry.params.height}',
            ),
            style: TextStyle(color: colors.onSurfaceVariant, fontSize: 12),
          ),
        ],
      ),
    );
  }
}
