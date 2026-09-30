import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../app/pickle_theme.dart';

class WinnerDialog extends StatefulWidget {
  const WinnerDialog({super.key, required this.winner});

  final String winner;

  @override
  State<WinnerDialog> createState() => _WinnerDialogState();
}

class _WinnerDialogState extends State<WinnerDialog>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1800),
  )..forward();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Dialog(
    backgroundColor: Colors.white,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
    child: Stack(
      clipBehavior: Clip.none,
      alignment: Alignment.topCenter,
      children: [
        Positioned(
          top: -40,
          left: 0,
          right: 0,
          height: 100,
          child: IgnorePointer(
            child: AnimatedBuilder(
              animation: _controller,
              builder: (_, _) =>
                  CustomPaint(painter: _ConfettiPainter(_controller.value)),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 34, 24, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 62,
                height: 62,
                decoration: const BoxDecoration(
                  color: Color(0xFFEAF5D5),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.celebration,
                  color: PickleColors.forest,
                  size: 31,
                ),
              ),
              const SizedBox(height: 17),
              Text(
                'Your pickle is solved!',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: PickleColors.forest,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 7),
              Text(
                widget.winner,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: PickleColors.leaf,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 21),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () => Navigator.pop(context),
                  style: FilledButton.styleFrom(
                    backgroundColor: PickleColors.forest,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Lovely'),
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

class _ConfettiPainter extends CustomPainter {
  _ConfettiPainter(this.progress);

  final double progress;

  static const _colors = [
    PickleColors.lime,
    PickleColors.leaf,
    Color(0xFFFFB24A),
    Color(0xFFEF7471),
    Color(0xFF64B7B0),
  ];

  @override
  void paint(Canvas canvas, Size size) {
    for (var index = 0; index < 34; index++) {
      final seed = index * 2.399;
      final startX = (index * 47.0 + 13) % size.width;
      final x = startX + math.sin(seed + progress * 5) * 16;
      final y = ((index * 31.0 + progress * 120) % (size.height + 30)) - 15;
      final paint = Paint()..color = _colors[index % _colors.length];
      canvas.save();
      canvas.translate(x, y);
      canvas.rotate(seed + progress * 4);
      canvas.drawRect(
        Rect.fromCenter(center: Offset.zero, width: 6, height: 10),
        paint,
      );
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant _ConfettiPainter oldDelegate) =>
      oldDelegate.progress != progress;
}
