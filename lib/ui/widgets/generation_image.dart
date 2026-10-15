import 'package:flutter/material.dart';

import '../../state/app_state.dart';

class GenerationImage extends StatelessWidget {
  final String imageKey;
  final BoxFit fit;
  final VoidCallback? onTap;

  const GenerationImage({
    super.key,
    required this.imageKey,
    this.fit = BoxFit.cover,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    final image = ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: FutureBuilder(
        future: state.imageStore.read(imageKey),
        builder: (context, snapshot) {
          final bytes = snapshot.data;
          if (bytes == null) {
            return ColoredBox(
              color: Theme.of(context).colorScheme.surfaceContainerHigh,
              child: const Center(child: Icon(Icons.image_outlined, size: 32)),
            );
          }
          return Image.memory(
            bytes,
            fit: fit,
            gaplessPlayback: true,
            errorBuilder: (context, error, stack) => ColoredBox(
              color: Theme.of(context).colorScheme.surfaceContainerHigh,
              child: const Center(
                child: Icon(Icons.broken_image_outlined, size: 32),
              ),
            ),
          );
        },
      ),
    );
    if (onTap == null) return image;
    return InkWell(onTap: onTap, child: image);
  }
}
