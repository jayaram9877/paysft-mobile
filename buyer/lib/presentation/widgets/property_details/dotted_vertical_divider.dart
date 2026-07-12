import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

class DottedVerticalDivider extends StatelessWidget {
  final double height;
  final Color color;
  final double strokeWidth;
  final double dashLength;
  final double dashGap;

  const DottedVerticalDivider({
    super.key,
    this.height = 40,
    this.color = AppColors.gray400,
    this.strokeWidth = 1,
    this.dashLength = 8,
    this.dashGap = 2,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      width: strokeWidth,
      child: CustomPaint(
        painter: _DottedLinePainter(color: color, strokeWidth: strokeWidth, dashLength: dashLength, dashGap: dashGap),
      ),
    );
  }
}

class _DottedLinePainter extends CustomPainter {
  final Color color;
  final double strokeWidth;
  final double dashLength;
  final double dashGap;

  _DottedLinePainter({required this.color, required this.strokeWidth, required this.dashLength, required this.dashGap});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth;

    double startY = 0;
    while (startY < size.height) {
      canvas.drawLine(Offset(0, startY), Offset(0, startY + dashLength), paint);
      startY += dashLength + dashGap;
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
