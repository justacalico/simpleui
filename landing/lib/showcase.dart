import 'dart:math' as math;

import 'package:flutter/material.dart';

class PromptCard extends StatelessWidget {
  const PromptCard({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return CustomPaint(
      painter: _SparklePainter(seed: scheme.primary),
      child: Container(
        width: 560,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: scheme.surfaceContainer,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: scheme.outlineVariant),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: scheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  Icon(Icons.auto_awesome, color: scheme.primary, size: 18),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'a fox in the snow, soft light',
                      style: TextStyle(color: scheme.onSurfaceVariant),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: const _GeneratedTile(),
            ),
          ],
        ),
      ),
    );
  }
}

class _GeneratedTile extends StatelessWidget {
  const _GeneratedTile();

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _ImagePainter(),
      child: const SizedBox(height: 300, width: double.infinity),
    );
  }
}

class _ImagePainter extends CustomPainter {
  const _ImagePainter();

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final sky = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: const [Color(0xFF2B2D5C), Color(0xFFB4643E)],
      ).createShader(rect);
    canvas.drawRect(rect, sky);
    final ground = Paint()..color = const Color(0xFFEDEFF7);
    canvas.drawRect(
      Rect.fromLTWH(0, size.height * 0.72, size.width, size.height * 0.28),
      ground,
    );
    final sun = Paint()..color = const Color(0xFFF5C982);
    canvas.drawCircle(
      Offset(size.width * 0.72, size.height * 0.42),
      size.height * 0.14,
      sun,
    );
    final tree = Paint()..color = const Color(0xFF1B1E33);
    for (var i = 0; i < 9; i++) {
      final x = size.width * (0.05 + i * 0.11);
      final h = size.height * (0.14 + (i % 3) * 0.05);
      final path = Path()
        ..moveTo(x, size.height * 0.72)
        ..lineTo(x + h * 0.35, size.height * 0.72)
        ..lineTo(x + h * 0.17, size.height * 0.72 - h)
        ..close();
      canvas.drawPath(path, tree);
    }
    final fox = Paint()..color = const Color(0xFFD06A35);
    canvas.drawCircle(
      Offset(size.width * 0.3, size.height * 0.68),
      size.height * 0.045,
      fox,
    );
    final tail = Path()
      ..moveTo(size.width * 0.27, size.height * 0.7)
      ..quadraticBezierTo(
        size.width * 0.2,
        size.height * 0.62,
        size.width * 0.24,
        size.height * 0.58,
      )
      ..quadraticBezierTo(
        size.width * 0.28,
        size.height * 0.62,
        size.width * 0.29,
        size.height * 0.68,
      )
      ..close();
    canvas.drawPath(tail, fox);
  }

  @override
  bool shouldRepaint(covariant _ImagePainter old) => false;
}

class _SparklePainter extends CustomPainter {
  final Color seed;

  const _SparklePainter({required this.seed});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = seed.withValues(alpha: 0.25);
    final rng = math.Random(7);
    for (var i = 0; i < 14; i++) {
      final cx = rng.nextDouble() * size.width;
      final cy = rng.nextDouble() * size.height;
      final r = 2.0 + rng.nextDouble() * 5;
      canvas.drawCircle(Offset(cx, cy), r, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _SparklePainter old) => old.seed != seed;
}
