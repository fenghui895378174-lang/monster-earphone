import 'dart:math';
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class SignalRadar extends StatefulWidget {
  final int rssi;
  final double size;

  const SignalRadar({
    super.key,
    required this.rssi,
    this.size = 120,
  });

  @override
  State<SignalRadar> createState() => _SignalRadarState();
}

class _SignalRadarState extends State<SignalRadar> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  double get normalizedRssi {
    // RSSI -30(最强) 到 -100(最弱) 映射到 0-1
    return ((widget.rssi + 100) / 70).clamp(0.0, 1.0);
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return SizedBox(
          width: widget.size,
          height: widget.size,
          child: CustomPaint(
            painter: _RadarPainter(
              progress: _controller.value,
              strength: normalizedRssi,
              rssi: widget.rssi,
            ),
          ),
        );
      },
    );
  }
}

class _RadarPainter extends CustomPainter {
  final double progress;
  final double strength;
  final int rssi;

  _RadarPainter({
    required this.progress,
    required this.strength,
    required this.rssi,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 4;

    // 同心圆
    for (int i = 1; i <= 3; i++) {
      final circlePaint = Paint()
        ..color = AppColors.primaryCyan.withOpacity(0.1 * i)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1;

      canvas.drawCircle(center, radius * i / 3, circlePaint);
    }

    // 十字线
    final linePaint = Paint()
      ..color = AppColors.primaryCyan.withOpacity(0.15)
      ..strokeWidth = 0.5;

    canvas.drawLine(
      Offset(center.dx - radius, center.dy),
      Offset(center.dx + radius, center.dy),
      linePaint,
    );
    canvas.drawLine(
      Offset(center.dx, center.dy - radius),
      Offset(center.dx, center.dy + radius),
      linePaint,
    );

    // 信号点
    final dotRadius = 4.0 + strength * 4;
    final dotPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          AppColors.primaryCyan,
          AppColors.primaryCyan.withOpacity(0.3),
          Colors.transparent,
        ],
      ).createShader(Rect.fromCircle(center: center, radius: radius))
      ..style = PaintingStyle.fill;

    canvas.drawCircle(center, dotRadius, dotPaint);

    // 扫描线
    final sweepAngle = 2 * pi * progress;
    final scanPaint = Paint()
      ..shader = SweepGradient(
        colors: [
          AppColors.primaryCyan.withOpacity(0.6),
          AppColors.primaryCyan.withOpacity(0.0),
        ],
      ).createShader(Rect.fromCircle(center: center, radius: radius))
      ..style = PaintingStyle.fill;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -pi / 2,
      sweepAngle,
      true,
      scanPaint,
    );

    // 信号强度脉冲
    final pulseRadius = radius * (0.3 + 0.7 * strength) * (1 + 0.2 * sin(progress * 2 * pi));
    final pulsePaint = Paint()
      ..color = AppColors.primaryCyan.withOpacity(0.08)
      ..style = PaintingStyle.fill;

    canvas.drawCircle(center, pulseRadius, pulsePaint);
  }

  @override
  bool shouldRepaint(covariant _RadarPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.strength != strength ||
        oldDelegate.rssi != rssi;
  }
}
