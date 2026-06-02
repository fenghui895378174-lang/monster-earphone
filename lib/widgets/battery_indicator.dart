import 'dart:math';
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

class BatteryIndicator extends StatelessWidget {
  final int percentage;
  final String label;
  final double size;

  const BatteryIndicator({
    super.key,
    required this.percentage,
    required this.label,
    this.size = 90,
  });

  Color get _color {
    if (percentage > 70) return AppColors.batteryHigh;
    if (percentage > 30) return AppColors.batteryMid;
    return AppColors.batteryLow;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: size,
          height: size,
          child: CustomPaint(
            painter: _BatteryPainter(
              percentage: percentage / 100.0,
              color: _color,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          '$percentage%',
          style: AppTextStyles.valueDisplay.copyWith(
            color: _color,
            fontSize: 18,
          ),
        ),
        Text(
          label,
          style: AppTextStyles.bodySmall.copyWith(fontSize: 11),
        ),
      ],
    );
  }
}

class _BatteryPainter extends CustomPainter {
  final double percentage;
  final Color color;

  _BatteryPainter({required this.percentage, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 8;

    // 背景圆环
    final bgPaint = Paint()
      ..color = AppColors.borderGlow.withOpacity(0.4)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 8
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, bgPaint);

    // 电量圆弧
    final arcPaint = Paint()
      ..shader = SweepGradient(
        colors: [
          color.withOpacity(0.6),
          color,
          color.withOpacity(0.8),
        ],
        stops: const [0.0, 0.5, 1.0],
      ).createShader(Rect.fromCircle(center: center, radius: radius))
      ..style = PaintingStyle.stroke
      ..strokeWidth = 8
      ..strokeCap = StrokeCap.round;

    final sweepAngle = 2 * pi * percentage;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -pi / 2,
      sweepAngle,
      false,
      arcPaint,
    );

    // 发光效果
    final glowPaint = Paint()
      ..color = color.withOpacity(0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 14
      ..strokeCap = StrokeCap.round
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -pi / 2,
      sweepAngle,
      false,
      glowPaint,
    );

    // 中心图标
    final iconPaint = Paint()
      ..color = color.withOpacity(0.8)
      ..style = PaintingStyle.fill;

    final iconPath = Path()
      ..moveTo(center.dx - 8, center.dy - 6)
      ..lineTo(center.dx + 8, center.dy - 6)
      ..lineTo(center.dx + 8, center.dy + 4)
      ..lineTo(center.dx + 10, center.dy + 4)
      ..lineTo(center.dx + 10, center.dy + 8)
      ..lineTo(center.dx - 10, center.dy + 8)
      ..lineTo(center.dx - 10, center.dy + 4)
      ..lineTo(center.dx - 8, center.dy + 4)
      ..close();

    canvas.drawPath(iconPath, iconPaint);
  }

  @override
  bool shouldRepaint(covariant _BatteryPainter oldDelegate) {
    return oldDelegate.percentage != percentage || oldDelegate.color != color;
  }
}
