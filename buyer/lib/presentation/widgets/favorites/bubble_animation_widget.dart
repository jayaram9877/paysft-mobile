import 'dart:math';
import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

class BubbleAnimationWidget extends StatefulWidget {
  static const int maxBubbles = 15;

  final Duration duration;

  const BubbleAnimationWidget({
    super.key,
    this.duration = const Duration(seconds: 3),
  });

  @override
  State<BubbleAnimationWidget> createState() => _BubbleAnimationWidgetState();
}

class _BubbleAnimationWidgetState extends State<BubbleAnimationWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final List<Bubble> _bubbles = [];
  final Random _random = Random();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );

    // Create bubbles with different sizes and colors
    final colors = [
      AppColors.primaryBlueIOS.withOpacity(0.2),
      AppColors.primaryPurple.withOpacity(0.15),
      AppColors.primaryBlue.withOpacity(0.1),
      AppColors.primaryCyan.withOpacity(0.12),
      AppColors.textWhite.withOpacity(0.3),
    ];

    for (int i = 0; i < BubbleAnimationWidget.maxBubbles; i++) {
      _bubbles.add(Bubble(
        size: 20 + _random.nextDouble() * 80, // 20-100
        x: _random.nextDouble(),
        // start phase used to desynchronise vertical motion, 0–1
        y: _random.nextDouble(),
        color: colors[_random.nextInt(colors.length)],
        // speed controls how fast bubbles traverse bottom→top
        speed: 0.3 + _random.nextDouble() * 0.5, // 0.3-0.8
      ));
    }

    _controller.repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return CustomPaint(
          painter: BubblePainter(
            bubbles: _bubbles,
            progress: _controller.value,
          ),
          child: Container(),
        );
      },
    );
  }
}

class Bubble {
  final double size;
  final double x;
  final double y;
  final Color color;
  final double speed;
  // y is used as a phase offset (0–1) so bubbles are staggered vertically

  Bubble({
    required this.size,
    required this.x,
    required this.y,
    required this.color,
    required this.speed,
  });
}

class BubblePainter extends CustomPainter {
  final List<Bubble> bubbles;
  final double progress;

  BubblePainter({
    required this.bubbles,
    required this.progress,
  });

  @override
  void paint(Canvas canvas, Size size) {
    for (final bubble in bubbles) {
      final paint = Paint()
        ..color = bubble.color
        ..style = PaintingStyle.fill;

      // Continuous bottom-to-top motion:
      // progress goes 0→1 in a loop; combine with bubble.y as a phase offset
      final totalTravel = size.height + bubble.size * 2;
      final t = (progress * bubble.speed + bubble.y) % 1.0;
      // Start just below the bottom and move upwards
      final offsetY = size.height + bubble.size - t * totalTravel;
      final offsetX = bubble.x * size.width;

      // Draw bubble
      canvas.drawCircle(
        Offset(offsetX, offsetY),
        bubble.size / 2,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(BubblePainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}

